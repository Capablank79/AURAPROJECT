import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/collections/collection_l10n.dart';
import '../../../core/models/binder_model.dart';
import '../../../core/models/item_model.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../core/widgets/aura_sigil_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/providers/deck_providers.dart';
import '../providers/binder_providers.dart';
import 'widgets/binder_manage_sheet.dart';
import 'widgets/binder_pocket_grid.dart';
import 'widgets/language_menu.dart';
import 'widgets/qr_poster_sheet.dart';
import 'widgets/trash_bin_sheet.dart';

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
  String _publicFilter = 'all';

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
          if (binderAsync.value != null)
            IconButton(
              tooltip: l10n.qrPosterButton,
              onPressed: () {
                final binder = binderAsync.value!;
                final items =
                    ref.read(binderItemsProvider(binder.id)).valueOrNull ??
                    const <ItemModel>[];
                showQrPosterSheet(
                  context,
                  binder: binder,
                  username: username,
                  items: items,
                );
              },
              icon: const Icon(Icons.qr_code_2),
            ),
          if (!widget.publicView) ...[
            Consumer(
              builder: (context, ref, _) {
                final count =
                    ref.watch(trashedItemsProvider).valueOrNull?.length ?? 0;
                return IconButton(
                  tooltip: l10n.trashBinTitle,
                  onPressed: () => showTrashBinSheet(context),
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    backgroundColor: AuraColors.psychicMagenta,
                    child: const Icon(Icons.delete_outline),
                  ),
                );
              },
            ),
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
                          ref
                              .read(binderItemsProvider(binder.id))
                              .valueOrNull ??
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
                publicFilter: _publicFilter,
                onFilterChanged: (f) => setState(() => _publicFilter = f),
                controller: _pageController,
                onPageChanged: (page) => setState(() => _page = page),
                onJump: () => _jumpToPage(binder),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _jumpToPage(BinderModel binder) async {
    final l10n = AppLocalizations.of(context);
    final perSheet = slotsPerSheetForFormat(binder.gridFormat);
    final pages = (binder.maxSlots / perSheet).ceil().clamp(1, 999);
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
    required this.publicFilter,
    required this.onFilterChanged,
    required this.controller,
    required this.onPageChanged,
    required this.onJump,
  });

  final BinderModel binder;
  final bool publicView;
  final String? publicBasePath;
  final int page;
  final String publicFilter;
  final ValueChanged<String> onFilterChanged;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onJump;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final itemsAsync = ref.watch(binderItemsProvider(binder.id));
    final perSheet = slotsPerSheetForFormat(binder.gridFormat);
    final rawPages = (binder.maxSlots / perSheet).ceil();
    final pageCount = rawPages < 1 ? 1 : rawPages;
    final collectionLabel = CollectionL10n.binderCollectionLabel(l10n, binder);

    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _DetailError(
        onRetry: () => ref.invalidate(binderItemsProvider(binder.id)),
      ),
      data: (allItems) {
        final unverifiedCount = allItems
            .where((it) => !it.isPhysicallyVerified)
            .length;
        final filtered = allItems.where((it) {
          if (!publicView || publicFilter == 'all') {
            return true;
          }
          if (publicFilter == 'physical') {
            return it.isPhysicallyVerified;
          }
          return it.isPhysicallyVerified && it.tradeStatus == publicFilter;
        }).toList();

        final itemsByPosition = {
          for (final item in filtered) item.positionIndex: item,
        };
        final nextPosition = _findAvailablePosition(
          items: allItems,
          currentPage: page,
          perSheet: perSheet,
          maxSlots: binder.maxSlots,
        );
        final startSlot = page * perSheet + 1;
        final endSlot = ((page + 1) * perSheet).clamp(1, binder.maxSlots);

        return Column(
          children: [
            const AuraSigilLogo(size: 48, showAura: true),
            const SizedBox(height: 4),
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
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                Text(
                  '◆ $collectionLabel · ${binder.gridFormat}',
                  style: const TextStyle(
                    color: AuraColors.champagneGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  unverifiedCount == 0
                      ? l10n.trustBadgeFullPhysical
                      : l10n.trustBadgeHasApi(unverifiedCount),
                  style: TextStyle(
                    color: unverifiedCount == 0
                        ? AuraColors.emeraldAura
                        : AuraColors.psychicMagenta,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (binder.isCompleted)
              Text(
                '✓ ${l10n.collectionCompleteBadge} (${allItems.length}/${binder.maxSlots})',
                style: const TextStyle(
                  color: AuraColors.emeraldAura,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              Text(
                l10n.remainingSlotsBanner(
                  (binder.maxSlots - allItems.length).clamp(0, binder.maxSlots),
                ),
                style: TextStyle(
                  color: (binder.maxSlots - allItems.length) <= 5
                      ? AuraColors.psychicMagenta
                      : AuraColors.silverMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (publicView)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                child: Row(
                  children: [
                    for (final entry in {
                      'all': l10n.filterAll,
                      'physical': l10n.filterPhysicalOnly,
                      ItemTradeStatus.forTrade: l10n.filterForTrade,
                      ItemTradeStatus.forSale: l10n.filterForSale,
                    }.entries)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(entry.value),
                          selected: publicFilter == entry.key,
                          onSelected: (_) => onFilterChanged(entry.key),
                        ),
                      ),
                    Builder(
                      builder: (context) {
                        final contact =
                            ref
                                .watch(activeProfileProvider)
                                .valueOrNull
                                ?.tradeContact;
                        if (contact == null || contact.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return ActionChip(
                          avatar: const Icon(
                            Icons.chat_bubble_outline,
                            size: 15,
                            color: AuraColors.manaCyan,
                          ),
                          label: Text(l10n.contactSellerButton(contact)),
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: contact),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.contactCopiedMessage(contact),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            if (allItems.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
              child: Row(
                children: [
                  Text(
                    '${l10n.pageIndicator(page + 1, pageCount)} · ${l10n.pocketRangeIndicator(startSlot, endSlot)}',
                    style: const TextStyle(
                      color: AuraColors.mutedText,
                      fontSize: 12,
                    ),
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
                itemBuilder: (context, pageIndex) => BinderPocketGrid(
                  binder: binder,
                  startIndex: pageIndex * perSheet,
                  itemsByPosition: itemsByPosition,
                  publicView: publicView,
                  onEmptyTap: publicView
                      ? null
                      : (pos) => context.push(
                          '/binder/${binder.id}/catalog?position=$pos',
                        ),
                  onItemTap: (item) {
                    final prefix = publicView
                        ? (publicBasePath ?? '/public/binder/${binder.id}')
                        : '/binder/${binder.id}';
                    context.push('$prefix/item/${item.id}');
                  },
                  onSwapPositions: publicView
                      ? null
                      : (fromPos, toPos) async {
                          await ref
                              .read(binderRepositoryProvider)
                              .swapItemPositions(
                                binderId: binder.id,
                                fromPosition: fromPos,
                                toPosition: toPos,
                              );
                          ref.invalidate(binderItemsProvider(binder.id));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.positionsSwappedMessage),
                              ),
                            );
                          }
                        },
                  onMoveToTrash: publicView
                      ? null
                      : (item) async {
                          await ref
                              .read(binderRepositoryProvider)
                              .moveItemToTrash(item.id);
                          ref.invalidate(binderItemsProvider(binder.id));
                          ref.invalidate(trashedItemsProvider);
                          ref.invalidate(portfolioValuationProvider);
                          ref.invalidate(deckInventoryMatchProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.movedToTrashMessage(item.name),
                                ),
                                action: SnackBarAction(
                                  label: l10n.undoButton,
                                  onPressed: () async {
                                    await ref
                                        .read(binderRepositoryProvider)
                                        .restoreItemFromTrash(item.id);
                                    ref.invalidate(
                                      binderItemsProvider(binder.id),
                                    );
                                    ref.invalidate(trashedItemsProvider);
                                    ref.invalidate(portfolioValuationProvider);
                                    ref.invalidate(deckInventoryMatchProvider);
                                  },
                                ),
                              ),
                            );
                          }
                        },
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
    required int perSheet,
    required int maxSlots,
  }) {
    final occupied = items.map((item) => item.positionIndex).toSet();
    final pageStart = currentPage * perSheet;
    final pageEnd = (pageStart + perSheet).clamp(0, maxSlots);
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
