-- =====================================================================
-- AuraDeck - schema_v2.sql
-- PostgreSQL / Supabase (sa-east-1). Idempotente: se puede re-ejecutar.
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ---------------------------------------------------------------------
-- 1. TABLAS
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id                      UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username                TEXT UNIQUE NOT NULL,
  display_name            TEXT,
  avatar_url              TEXT,
  preferred_language      VARCHAR(5) DEFAULT 'es',
  is_pro                  BOOLEAN DEFAULT FALSE,
  is_admin                BOOLEAN DEFAULT FALSE,
  extra_binder_credits    INTEGER DEFAULT 0,
  revenuecat_app_user_id  TEXT,
  created_at              TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.binders (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                 UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title                   TEXT NOT NULL,
  family                  TEXT NOT NULL CHECK (family IN ('cards', 'objects')) DEFAULT 'cards',
  collection_code         TEXT NOT NULL DEFAULT 'magic',
  custom_collection_name  TEXT,
  category                TEXT CHECK (category IN ('pokemon', 'magic', 'custom')) DEFAULT 'custom',
  grid_format             TEXT CHECK (grid_format IN ('2x2', '3x3', '4x3')) DEFAULT '3x3',
  max_slots               INTEGER DEFAULT 360,
  is_free_tier            BOOLEAN DEFAULT FALSE,
  theme                   TEXT DEFAULT 'obsidian_gold',
  is_public               BOOLEAN DEFAULT TRUE,
  created_at              TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT binders_custom_name_check CHECK (
    collection_code NOT IN ('other_card', 'other_object')
    OR (custom_collection_name IS NOT NULL AND btrim(custom_collection_name) <> '')
  )
);

CREATE TABLE IF NOT EXISTS public.items (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  binder_id        UUID NOT NULL REFERENCES public.binders(id) ON DELETE CASCADE,
  user_id          UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  collection_code  TEXT NOT NULL DEFAULT 'magic',
  source_type      TEXT NOT NULL CHECK (source_type IN ('api_scryfall', 'api_tcgdex', 'api_ygoprodeck', 'user_upload')),
  external_id      TEXT,
  name             TEXT NOT NULL,
  image_url        TEXT NOT NULL,
  is_foil          BOOLEAN DEFAULT FALSE,
  condition        TEXT DEFAULT 'NM',
  estimated_price  NUMERIC(10, 2),
  position_index   INTEGER NOT NULL,
  metadata         JSONB DEFAULT '{}'::jsonb,
  notes            TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (binder_id, position_index)
);

CREATE TABLE IF NOT EXISTS public.decks (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  game_type   TEXT NOT NULL CHECK (game_type IN ('pokemon', 'magic')),
  format      TEXT,
  card_ids    UUID[] DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.purchase_history (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  product_id      TEXT NOT NULL,
  transaction_id  TEXT UNIQUE NOT NULL,
  platform        TEXT NOT NULL CHECK (platform IN ('android', 'ios')),
  amount_usd      NUMERIC(10, 2),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.reports (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id      UUID NOT NULL REFERENCES public.items(id) ON DELETE CASCADE,
  reporter_id  UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  reason       TEXT NOT NULL,
  status       TEXT CHECK (status IN ('pending', 'reviewed', 'dismissed')) DEFAULT 'pending',
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- 2. ÍNDICES
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_binders_user_id         ON public.binders(user_id);
CREATE INDEX IF NOT EXISTS idx_binders_collection_code ON public.binders(collection_code);
CREATE INDEX IF NOT EXISTS idx_items_binder_id         ON public.items(binder_id);
CREATE INDEX IF NOT EXISTS idx_items_user_id           ON public.items(user_id);
CREATE INDEX IF NOT EXISTS idx_decks_user_id           ON public.decks(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_item_id         ON public.reports(item_id);
CREATE INDEX IF NOT EXISTS idx_reports_status          ON public.reports(status);
CREATE INDEX IF NOT EXISTS idx_purchase_history_user_id ON public.purchase_history(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_reporter_id      ON public.reports(reporter_id);

-- ---------------------------------------------------------------------
-- 3. FUNCIONES Y TRIGGERS (SECURITY DEFINER, search_path = public)
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    (SELECT p.is_admin FROM public.profiles p WHERE p.id = auth.uid()),
    FALSE
  );
$$;

-- 3.1 on_auth_user_created -------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  base_name  TEXT;
  final_name TEXT;
  lang       TEXT;
BEGIN
  base_name := COALESCE(
    NULLIF(NEW.raw_user_meta_data ->> 'username', ''),
    NULLIF(NEW.raw_user_meta_data ->> 'user_name', ''),
    NULLIF(split_part(COALESCE(NEW.email, ''), '@', 1), ''),
    'user'
  );
  base_name := regexp_replace(lower(base_name), '[^a-z0-9_.-]', '', 'g');
  IF base_name = '' THEN
    base_name := 'user';
  END IF;
  base_name := left(base_name, 24);

  final_name := base_name;
  IF EXISTS (SELECT 1 FROM public.profiles WHERE username = final_name) THEN
    final_name := base_name || '_' || substr(replace(NEW.id::text, '-', ''), 1, 6);
    IF EXISTS (SELECT 1 FROM public.profiles WHERE username = final_name) THEN
      final_name := base_name || '_' || replace(NEW.id::text, '-', '');
    END IF;
  END IF;

  lang := COALESCE(NULLIF(left(NEW.raw_user_meta_data ->> 'preferred_language', 5), ''), 'es');

  INSERT INTO public.profiles (id, username, display_name, avatar_url, preferred_language)
  VALUES (
    NEW.id,
    final_name,
    COALESCE(NULLIF(NEW.raw_user_meta_data ->> 'display_name', ''),
             NULLIF(NEW.raw_user_meta_data ->> 'full_name', ''),
             base_name),
    NULLIF(NEW.raw_user_meta_data ->> 'avatar_url', ''),
    lang
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3.2 before_insert_binder -------------------------------------------
CREATE OR REPLACE FUNCTION public.before_insert_binder()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  binder_count INTEGER;
  v_is_pro     BOOLEAN;
  v_is_admin   BOOLEAN;
  v_credits    INTEGER;
BEGIN
  SELECT is_pro, is_admin, extra_binder_credits
    INTO v_is_pro, v_is_admin, v_credits
    FROM public.profiles
   WHERE id = NEW.user_id
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Perfil no encontrado para el usuario %', NEW.user_id;
  END IF;

  -- Sincroniza columna legacy category a partir de collection_code
  IF NEW.collection_code IN ('pokemon', 'magic') THEN
    NEW.category := NEW.collection_code;
  ELSE
    NEW.category := 'custom';
  END IF;

  SELECT COUNT(*) INTO binder_count FROM public.binders WHERE user_id = NEW.user_id;

  IF binder_count = 0 THEN
    NEW.is_free_tier := TRUE;
    NEW.max_slots := COALESCE(NEW.max_slots, 360);
  ELSE
    NEW.is_free_tier := FALSE;
    NEW.max_slots := COALESCE(NEW.max_slots, 360);

    IF COALESCE(v_is_pro, FALSE) OR COALESCE(v_is_admin, FALSE) THEN
      NULL;
    ELSIF COALESCE(v_credits, 0) > 0 THEN
      PERFORM set_config('app.bypass_profile_guard', 'on', TRUE);
      UPDATE public.profiles
         SET extra_binder_credits = extra_binder_credits - 1
       WHERE id = NEW.user_id;
      PERFORM set_config('app.bypass_profile_guard', 'off', TRUE);
    ELSE
      RAISE EXCEPTION 'Límite de carpetas alcanzado: necesitas AuraDeck Pro o créditos extra para crear más carpetas.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS before_insert_binder ON public.binders;
CREATE TRIGGER before_insert_binder
  BEFORE INSERT ON public.binders
  FOR EACH ROW EXECUTE FUNCTION public.before_insert_binder();

-- 3.3 before_insert_item (capacidad + prohibición de mezcla de colecciones)
CREATE OR REPLACE FUNCTION public.before_insert_item()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_count           INTEGER;
  binder_max_slots        INTEGER;
  binder_collection_code  TEXT;
BEGIN
  SELECT max_slots, collection_code
    INTO binder_max_slots, binder_collection_code
    FROM public.binders
   WHERE id = NEW.binder_id
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Carpeta % no encontrada', NEW.binder_id;
  END IF;

  IF NEW.collection_code IS DISTINCT FROM binder_collection_code THEN
    RAISE EXCEPTION 'Colección incompatible: la carpeta solo admite % y se intentó guardar %.',
      binder_collection_code, NEW.collection_code;
  END IF;

  IF TG_OP = 'INSERT' THEN
    SELECT COUNT(*) INTO current_count FROM public.items WHERE binder_id = NEW.binder_id;
    IF current_count >= COALESCE(binder_max_slots, 360) THEN
      RAISE EXCEPTION 'La carpeta está llena (% / % espacios).', current_count, COALESCE(binder_max_slots, 360);
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS before_insert_item ON public.items;
CREATE TRIGGER before_insert_item
  BEFORE INSERT OR UPDATE ON public.items
  FOR EACH ROW EXECUTE FUNCTION public.before_insert_item();

-- 3.4 Guard de columnas privilegiadas de profiles ---------------------
CREATE OR REPLACE FUNCTION public.protect_profile_privileged_columns()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL OR COALESCE(current_setting('app.bypass_profile_guard', TRUE), 'off') = 'on' THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    NEW.is_pro := FALSE;
    NEW.is_admin := FALSE;
    NEW.extra_binder_credits := 0;
    NEW.revenuecat_app_user_id := NULL;
  ELSE
    NEW.is_pro := OLD.is_pro;
    NEW.is_admin := OLD.is_admin;
    NEW.extra_binder_credits := OLD.extra_binder_credits;
    NEW.revenuecat_app_user_id := OLD.revenuecat_app_user_id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS protect_profile_privileged_columns ON public.profiles;
CREATE TRIGGER protect_profile_privileged_columns
  BEFORE INSERT OR UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.protect_profile_privileged_columns();

-- ---------------------------------------------------------------------
-- 4. ROW LEVEL SECURITY
-- ---------------------------------------------------------------------
ALTER TABLE public.profiles         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.binders          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.items            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.decks            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports          ENABLE ROW LEVEL SECURITY;

-- profiles
DROP POLICY IF EXISTS "profiles_select_public" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert_own"    ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own"    ON public.profiles;
CREATE POLICY "profiles_select_public" ON public.profiles
  FOR SELECT USING (TRUE);
CREATE POLICY "profiles_insert_own" ON public.profiles
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- binders
DROP POLICY IF EXISTS "binders_select" ON public.binders;
DROP POLICY IF EXISTS "binders_insert" ON public.binders;
DROP POLICY IF EXISTS "binders_update" ON public.binders;
DROP POLICY IF EXISTS "binders_delete" ON public.binders;
CREATE POLICY "binders_select" ON public.binders
  FOR SELECT USING (is_public = TRUE OR auth.uid() = user_id OR public.is_admin());
CREATE POLICY "binders_insert" ON public.binders
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "binders_update" ON public.binders
  FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "binders_delete" ON public.binders
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- items
DROP POLICY IF EXISTS "items_select" ON public.items;
DROP POLICY IF EXISTS "items_insert" ON public.items;
DROP POLICY IF EXISTS "items_update" ON public.items;
DROP POLICY IF EXISTS "items_delete" ON public.items;
CREATE POLICY "items_select" ON public.items
  FOR SELECT USING (
    auth.uid() = user_id
    OR public.is_admin()
    OR EXISTS (SELECT 1 FROM public.binders b WHERE b.id = items.binder_id AND b.is_public = TRUE)
  );
CREATE POLICY "items_insert" ON public.items
  FOR INSERT TO authenticated WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (SELECT 1 FROM public.binders b WHERE b.id = binder_id AND b.user_id = auth.uid())
  );
CREATE POLICY "items_update" ON public.items
  FOR UPDATE TO authenticated USING (auth.uid() = user_id)
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (SELECT 1 FROM public.binders b WHERE b.id = binder_id AND b.user_id = auth.uid())
  );
CREATE POLICY "items_delete" ON public.items
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- decks
DROP POLICY IF EXISTS "decks_select" ON public.decks;
DROP POLICY IF EXISTS "decks_insert" ON public.decks;
DROP POLICY IF EXISTS "decks_update" ON public.decks;
DROP POLICY IF EXISTS "decks_delete" ON public.decks;
CREATE POLICY "decks_select" ON public.decks
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "decks_insert" ON public.decks
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "decks_update" ON public.decks
  FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "decks_delete" ON public.decks
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- purchase_history (inserciones solo vía service role / webhook)
DROP POLICY IF EXISTS "purchase_history_select" ON public.purchase_history;
CREATE POLICY "purchase_history_select" ON public.purchase_history
  FOR SELECT TO authenticated USING (auth.uid() = user_id OR public.is_admin());

-- reports
DROP POLICY IF EXISTS "reports_insert" ON public.reports;
DROP POLICY IF EXISTS "reports_select" ON public.reports;
DROP POLICY IF EXISTS "reports_update" ON public.reports;
CREATE POLICY "reports_insert" ON public.reports
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "reports_select" ON public.reports
  FOR SELECT TO authenticated USING (public.is_admin() OR auth.uid() = reporter_id);
CREATE POLICY "reports_update" ON public.reports
  FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

-- =====================================================================
-- FIN schema_v2.sql
-- =====================================================================
