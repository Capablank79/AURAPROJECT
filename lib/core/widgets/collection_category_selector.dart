import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../collections/collection_l10n.dart';
import '../collections/collection_registry.dart';
import '../theme/aura_colors.dart';

/// Paso de selección entre las 2 únicas familias: Cartas coleccionables vs Colección de objetos.
class CollectionFamilySelector extends StatelessWidget {
  const CollectionFamilySelector({
    required this.selectedFamily,
    required this.onSelected,
    super.key,
  });

  final CollectionFamily? selectedFamily;
  final ValueChanged<CollectionFamily> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FamilyCard(
          selected: selectedFamily == CollectionFamily.cards,
          title: l10n.familyCardsTitle,
          subtitle: l10n.familyCardsSubtitle,
          semanticLabel: l10n.selectCategorySemantic(l10n.familyCardsTitle),
          accentColor: AuraColors.champagneGold,
          leading: const _MiniCardsPreview(),
          onTap: () => onSelected(CollectionFamily.cards),
        ),
        const SizedBox(height: 14),
        _FamilyCard(
          selected: selectedFamily == CollectionFamily.objects,
          title: l10n.familyObjectsTitle,
          subtitle: l10n.familyObjectsSubtitle,
          semanticLabel: l10n.selectCategorySemantic(l10n.familyObjectsTitle),
          accentColor: AuraColors.manaCyan,
          leading: const _MiniObjectsPreview(),
          onTap: () => onSelected(CollectionFamily.objects),
        ),
      ],
    );
  }
}

class _FamilyCard extends StatelessWidget {
  const _FamilyCard({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.semanticLabel,
    required this.accentColor,
    required this.leading,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String semanticLabel;
  final Color accentColor;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: Material(
        color: selected
            ? accentColor.withValues(alpha: 0.11)
            : AuraColors.smokedCharcoal.withValues(alpha: 0.88),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected
                ? accentColor
                : AuraColors.champagneGold.withValues(alpha: 0.22),
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    leading,
                    const Spacer(),
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: selected ? accentColor : AuraColors.mutedText,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AuraColors.mutedText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniCardsPreview extends StatelessWidget {
  const _MiniCardsPreview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 44,
      child: Stack(
        children: [
          _miniTile(0, AuraColors.manaCyan, Icons.auto_fix_high),
          _miniTile(22, AuraColors.psychicMagenta, Icons.catching_pokemon),
          _miniTile(44, AuraColors.solarGold, Icons.auto_awesome),
        ],
      ),
    );
  }

  Widget _miniTile(double left, Color glow, IconData icon) {
    return Positioned(
      left: left,
      top: 0,
      bottom: 0,
      child: Container(
        width: 32,
        decoration: BoxDecoration(
          color: AuraColors.obsidianVoid,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AuraColors.champagneDark, width: 1.2),
          boxShadow: [
            BoxShadow(color: glow.withValues(alpha: 0.35), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 15, color: AuraColors.champagneGold),
      ),
    );
  }
}

class _MiniObjectsPreview extends StatelessWidget {
  const _MiniObjectsPreview();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.toys_outlined, color: AuraColors.psychicMagenta, size: 26),
        SizedBox(width: 8),
        Icon(Icons.menu_book_outlined, color: AuraColors.manaCyan, size: 24),
        SizedBox(width: 8),
        Icon(
          Icons.sports_esports_outlined,
          color: AuraColors.emeraldAura,
          size: 24,
        ),
      ],
    );
  }
}

/// Selector desplegable de colección específica dentro de una familia.
/// Para Cartas coleccionables muestra Magic en primer lugar, luego Pokémon, Yu-Gi-Oh!, etc.
class CollectionSpecSelector extends StatelessWidget {
  const CollectionSpecSelector({
    required this.family,
    required this.selectedCode,
    required this.onSelected,
    this.customNameController,
    this.onCustomNameChanged,
    super.key,
  });

  final CollectionFamily family;
  final String? selectedCode;
  final ValueChanged<CollectionSpec> onSelected;
  final TextEditingController? customNameController;
  final ValueChanged<String>? onCustomNameChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allSpecs = CollectionRegistry.forFamily(family);
    final currentSpec = selectedCode == null
        ? null
        : CollectionRegistry.byCode(selectedCode!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey('dropdown-${family.code}-$selectedCode'),
          initialValue: allSpecs.any((s) => s.code == selectedCode)
              ? selectedCode
              : null,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: family == CollectionFamily.cards
                ? l10n.selectCardGameLabel
                : l10n.selectObjectTypeLabel,
          ),
          items: allSpecs
              .map(
                (spec) => DropdownMenuItem<String>(
                  value: spec.code,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: spec.accentColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: spec.accentColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          spec.monogram,
                          style: TextStyle(
                            color: spec.accentColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          CollectionL10n.collectionName(l10n, spec.code),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (code) {
            if (code != null) {
              onSelected(CollectionRegistry.byCode(code));
            }
          },
        ),
        if (currentSpec != null) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (currentSpec.supportsApiSearch) ...[
                _CapabilityBadge(
                  label: l10n.capabilitySearchBadge,
                  enabled: true,
                ),
                _CapabilityBadge(
                  label: l10n.capabilityScannerBadge,
                  enabled: true,
                ),
              ] else
                _CapabilityBadge(
                  label: l10n.capabilityManualOnlyBadge,
                  enabled: false,
                ),
            ],
          ),
        ],
        if (currentSpec != null &&
            currentSpec.requiresCustomName &&
            customNameController != null) ...[
          const SizedBox(height: 12),
          TextField(
            controller: customNameController,
            maxLength: 50,
            onChanged: onCustomNameChanged,
            decoration: InputDecoration(
              labelText: l10n.customCollectionNameLabel,
              hintText: l10n.customCollectionNameHint,
            ),
          ),
        ],
      ],
    );
  }
}

class _CapabilityBadge extends StatelessWidget {
  const _CapabilityBadge({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = enabled
        ? AuraColors.emeraldAura.withValues(alpha: 0.45)
        : AuraColors.mutedText.withValues(alpha: 0.25);
    final textColor = enabled ? AuraColors.emeraldAura : AuraColors.mutedText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
