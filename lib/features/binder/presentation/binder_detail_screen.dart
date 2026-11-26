import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/collections/collection_l10n.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/binder_model.dart';
import '../../../core/models/item_model.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../core/widgets/aura_sigil_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/binder_providers.dart';
import 'widgets/binder_manage_sheet.dart';
import 'widgets/language_menu.dart';

class BinderDetailScreen extends ConsumerStatefulWidget {
  const BinderDetailScreen({
    required this.binderId,
    this.publicView = false,
    this.publicBasePath,
    super.key,
  });

  final String binderId;
  final bool publicView;
  final String? publicBasePath;

  @override
  ConsumerState<BinderDetailScreen> createState() => _BinderDetailScreenState();
}

class _BinderDetailScreenState extends ConsumerState<BinderDetailScreen> {
  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final targetProvider = widget.publicView
        ? publicBinderProvider(widget.binderId)
        : binderProvider(widget.binderId);
    final binderAsync = ref.watch(targetProvider);
    final profile = ref.watch(activeProfileProvider).valueOrNull;
    final username = profile?.username ?? 'coleccionista_aura';

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!widget.publicView) ...[
            if (binderAsync.value?.isPublic == true)
              IconButton(
                tooltip: l10n.publicPreviewButton,
                onPressed: () =>
                    context.push('/u/$username/${widget.binderId}'),
                icon: const Icon(Icons.visibility_outlined),
              ),
            IconButton(
              tooltip: l10n.shareBinder,
              onPressed: binderAsync.value?.isPublic == true
                  ? () => SharePlus.instance.share(
                      ShareParams(
                        text: l10n.shareBinderMessage(
                          'auradeck.app/u/$username/${widget.binderId}',
                        ),
                      ),
                    )
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.publicRestrictedMessage)),
                    ),
              icon: const Icon(Icons.ios_share),
            ),
            IconButton(
              tooltip: l10n.editBinderTitle,
              onPressed: binderAsync.value == null
                  ? null
                  : () async {
                      final binder = binderAsync.value!;
                      final items =
                          ref.read(binderItemsProvider(binder.id)).valueOrNull ??
                          const <ItemModel>[];
                      final deleted = await showBinderManageSheet(
                        context,
                        binder: binder,
                        occupiedCount: items.length,
                      );
                      if (deleted && context.mounted) {
                        context.pop();
                      }
                    },
              icon: const Icon(Icons.tune_outlined),
            ),
            const LanguageMenu(),
          ],
        ],
      ),
      body: AuraBackdrop(
        child: SafeArea(
          top: false,
          child: binderAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                _DetailError(onRetry: () => ref.invalidate(targetProvider)),
            data: (binder) {
              if (binder == null) {
                return _UnavailableBinder(publicView: widget.publicView);
              }
              return _BinderPages(
                binder: binder,
                publicView: widget.publicView,
                publicBasePath: widget.publicBasePath,
                page: _page,
                controller: _pageController,
                onPageChanged: (page) => setState(() => _page = page),
                onJump: () => _jumpToPage(binder.maxSlots),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _jumpToPage(int maxSlots) async {
    final l10n = AppLocalizations.of(context);
    final pages = (maxSlots / AppConstants.binderGridSize).ceil();
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AuraColors.obsidianVoid,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.jumpToPage)),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: pages,
                itemBuilder: (context, index) => ListTile(
                  selected: index == _page,
                  title: Text(l10n.pageNumber(index + 1)),
                  onTap: () => Navigator.pop(context, index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await _pageController.animateToPage(
        selected,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

class _BinderPages extends ConsumerWidget {
  const _BinderPages({
    required this.binder,
    required this.publicView,
    this.publicBasePath,
    required this.page,
    required this.controller,
    required this.onPageChanged,
    required this.onJump,
  });

  final BinderModel binder;
  final bool publicView;
  final String? publicBasePath;
  final int page;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onJump;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final itemsAsync = ref.watch(binderItemsProvider(binder.id));
    final rawPages = (binder.maxSlots / AppConstants.binderGridSize).ceil();
    final pageCount = rawPages < 1 ? 1 : rawPages;
    final collectionLabel = CollectionL10n.binderCollectionLabel(l10n, binder);

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _DetailError(
        onRetry: () => ref.invalidate(binderItemsProvider(binder.id)),
      ),
      data: (items) {
        final itemsByPosition = {
          for (final item in items) item.positionIndex: item,
        };
        final nextPosition = _findAvailablePosition(
          items: items,
          currentPage: page,
          maxSlots: binder.maxSlots,
        );

        return Column(
          children: [
            const AuraSigilLogo(size: 56, showAura: true),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AuraColors.champagneLight, AuraColors.champagneDark],
                ).createShader(bounds),
                child: Text(
                  binder.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '◆ $collectionLabel',
              style: const TextStyle(
                color: AuraColors.champagneGold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            if (binder.isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AuraColors.emeraldAura.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AuraColors.emeraldAura.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '✓ ${l10n.collectionCompleteBadge} (${items.length}/${binder.maxSlots})',
                  style: const TextStyle(
                    color: AuraColors.emeraldAura,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Text(
                l10n.remainingSlotsBanner(
                  (binder.maxSlots - items.length).clamp(0, binder.maxSlots),
                ),
                style: TextStyle(
                  color: (binder.maxSlots - items.length) <= 5
                      ? AuraColors.psychicMagenta
                      : AuraColors.silverMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                  l10n.emptyBinderMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AuraColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Row(
                children: [
                  Text(
                    l10n.pageIndicator(page + 1, pageCount),
                    style: const TextStyle(color: AuraColors.mutedText),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onJump,
                    icon: const Icon(
                      Icons.keyboard_double_arrow_right,
                      size: 18,
                    ),
                    label: Text(l10n.jumpButton),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: controller,
                onPageChanged: onPageChanged,
                itemCount: pageCount,
                itemBuilder: (context, pageIndex) => _PocketGrid(
                  binder: binder,
                  startIndex: pageIndex * AppConstants.binderGridSize,
                  itemsByPosition: itemsByPosition,
                  publicView: publicView,
                  publicBasePath: publicBasePath,
                ),
              ),
            ),
            if (!publicView)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: FilledButton.icon(
                  onPressed: nextPosition == null
                      ? null
                      : () => context.push(
                          '/binder/${binder.id}/catalog?position=$nextPosition',
                        ),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(
                    nextPosition == null
                        ? l10n.binderFullButton
                        : l10n.addItemButton,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  int? _findAvailablePosition({
    required List<ItemModel> items,
    required int currentPage,
    required int maxSlots,
  }) {
    final occupied = items.map((item) => item.positionIndex).toSet();
    final pageStart = currentPage * AppConstants.binderGridSize;
    final pageEnd = (pageStart + AppConstants.binderGridSize).clamp(
      0,
      maxSlots,
    );
    for (var position = pageStart; position < pageEnd; position++) {
      if (!occupied.contains(position)) {
        return position;
      }
    }
    for (var position = 0; position < maxSlots; position++) {
      if (!occupied.contains(position)) {
        return position;
      }
    }
    return null;
  }
}

class _PocketGrid extends StatelessWidget {
  const _PocketGrid({
    required this.binder,
    required this.startIndex,
    required this.itemsByPosition,
    required this.publicView,
    this.publicBasePath,
  });

  final BinderModel binder;
  final int startIndex;
  final Map<int, ItemModel> itemsByPosition;
  final bool publicView;
  final String? publicBasePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.72,
          mainAxisSpacing: 11,
          crossAxisSpacing: 11,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final position = startIndex + index;
          final item = itemsByPosition[position];
          if (item == null) {
            return _EmptyPocket(
              position: position,
              onTap: publicView
                  ? null
                  : () => context.push(
                      '/binder/${binder.id}/catalog?position=$position',
                    ),
            );
          }
          return _ItemPocket(
            item: item,
            onTap: () {
              final prefix = publicView
                  ? (publicBasePath ?? '/public/binder/${binder.id}')
                  : '/binder/${binder.id}';
              context.push('$prefix/item/${item.id}');
            },
          );
        },
      ),
    );
  }
}

class _EmptyPocket extends StatelessWidget {
  const _EmptyPocket({required this.position, this.onTap});

  final int position;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: onTap != null,
      label: l10n.emptySlot(position + 1),
      child: Material(
        color: AuraColors.smokedCharcoal.withValues(alpha: 0.65),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
          side: BorderSide(
            color: AuraColors.champagneGold.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Icon(
            Icons.add,
            color: AuraColors.champagneGold.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

class _ItemPocket extends StatelessWidget {
  const _ItemPocket({required this.item, required this.onTap});

  final ItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auraGlow = _auraColor(item);

    return Semantics(
      button: true,
      label: l10n.openItem(item.name),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: auraGlow.withValues(alpha: item.isFoil ? 0.36 : 0.18),
              blurRadius: item.isFoil ? 12 : 7,
            ),
          ],
        ),
        child: Material(
          color: AuraColors.smokedCharcoal,
          borderRadius: BorderRadius.circular(13),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (!item.imageUrl.startsWith('mock://'))
                  Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => AuraCardCrestPlaceholder(
                      name: item.name,
                      compact: true,
                    ),
                  )
                else
                  AuraCardCrestPlaceholder(name: item.name, compact: true),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: item.isFoil
                          ? AuraColors.champagneLight
                          : AuraColors.champagneDark,
                      width: item.isFoil ? 1.8 : 1.2,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AuraColors.obsidianVoid.withValues(alpha: 0.88),
                      ],
                      stops: const [0.55, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 7,
                  right: 7,
                  bottom: 7,
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AuraColors.creamText,
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                if (item.isFoil)
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AuraColors.solarGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.foilBadge,
                        style: const TextStyle(
                          color: AuraColors.obsidianVoid,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _auraColor(ItemModel item) {
    final rarity = item.metadata['rarity']?.toString().toLowerCase() ?? '';
    if (rarity.contains('mythic') || rarity.contains('special')) {
      return AuraColors.psychicMagenta;
    }
    if (rarity.contains('rare')) {
      return AuraColors.solarGold;
    }
    if (rarity.contains('uncommon')) {
      return AuraColors.manaCyan;
    }
    return item.isFoil ? AuraColors.solarGold : AuraColors.emeraldAura;
  }
}

class _UnavailableBinder extends StatelessWidget {
  const _UnavailableBinder({required this.publicView});

  final bool publicView;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 54,
              color: AuraColors.champagneGold,
            ),
            const SizedBox(height: 16),
            Text(
              publicView ? l10n.publicRestrictedTitle : l10n.unavailableBinder,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(l10n.publicRestrictedMessage, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.genericError),
          const SizedBox(height: 12),
          FilledButton.tonal(onPressed: onRetry, child: Text(l10n.retryButton)),
        ],
      ),
    );
  }
}
