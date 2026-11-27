import 'package:flutter/material.dart';

import '../../../../core/models/binder_model.dart';
import '../../../../core/models/item_model.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../core/widgets/aura_sigil_logo.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../providers/binder_providers.dart';

class BinderPocketGrid extends StatefulWidget {
  const BinderPocketGrid({
    required this.binder,
    required this.startIndex,
    required this.itemsByPosition,
    required this.publicView,
    required this.onEmptyTap,
    required this.onItemTap,
    this.onSwapPositions,
    this.onMoveToTrash,
    super.key,
  });

  final BinderModel binder;
  final int startIndex;
  final Map<int, ItemModel> itemsByPosition;
  final bool publicView;
  final ValueChanged<int>? onEmptyTap;
  final ValueChanged<ItemModel> onItemTap;
  final void Function(int fromPos, int toPos)? onSwapPositions;
  final ValueChanged<ItemModel>? onMoveToTrash;

  @override
  State<BinderPocketGrid> createState() => _BinderPocketGridState();
}

class _BinderPocketGridState extends State<BinderPocketGrid> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final perSheet = slotsPerSheetForFormat(widget.binder.gridFormat);
    final columns = gridCrossAxisCountForFormat(widget.binder.gridFormat);
    final remaining =
        (widget.binder.maxSlots - widget.startIndex).clamp(0, perSheet);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 0.72,
                mainAxisSpacing: columns == 4 ? 8 : 11,
                crossAxisSpacing: columns == 4 ? 8 : 11,
              ),
              itemCount: remaining,
              itemBuilder: (context, index) {
                final position = widget.startIndex + index;
                final item = widget.itemsByPosition[position];
                return DragTarget<int>(
                  onWillAcceptWithDetails: (details) =>
                      !widget.publicView &&
                      widget.onSwapPositions != null &&
                      details.data != position,
                  onAcceptWithDetails: (details) =>
                      widget.onSwapPositions?.call(details.data, position),
                  builder: (context, candidateData, _) {
                    final highlighted = candidateData.isNotEmpty;
                    if (item == null) {
                      return _EmptyPocketTile(
                        position: position,
                        highlighted: highlighted,
                        onTap: widget.onEmptyTap == null
                            ? null
                            : () => widget.onEmptyTap!(position),
                      );
                    }
                    final tile = _OccupiedPocketTile(
                      item: item,
                      highlighted: highlighted,
                      onTap: () => widget.onItemTap(item),
                    );
                    if (widget.publicView || widget.onSwapPositions == null) {
                      return tile;
                    }
                    return LongPressDraggable<int>(
                      data: position,
                      onDragStarted: () => setState(() => _dragging = true),
                      onDragEnd: (_) => setState(() => _dragging = false),
                      onDraggableCanceled: (_, _) =>
                          setState(() => _dragging = false),
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(width: 92, height: 128, child: tile),
                      ),
                      childWhenDragging: Opacity(opacity: 0.35, child: tile),
                      child: tile,
                    );
                  },
                );
              },
            ),
          ),
          if (_dragging && !widget.publicView && widget.onMoveToTrash != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: DragTarget<int>(
                onWillAcceptWithDetails: (_) => true,
                onAcceptWithDetails: (details) {
                  setState(() => _dragging = false);
                  final target = widget.itemsByPosition[details.data];
                  if (target != null) {
                    widget.onMoveToTrash!(target);
                  }
                },
                builder: (context, candidateData, _) {
                  final hovering = candidateData.isNotEmpty;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: hovering
                          ? AuraColors.psychicMagenta.withValues(alpha: 0.3)
                          : AuraColors.obsidianVoid.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AuraColors.psychicMagenta,
                        width: hovering ? 2.0 : 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.delete_sweep_outlined,
                          size: 18,
                          color: AuraColors.psychicMagenta,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.trashDropZoneHint,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AuraColors.psychicMagenta,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyPocketTile extends StatelessWidget {
  const _EmptyPocketTile({
    required this.position,
    required this.highlighted,
    this.onTap,
  });

  final int position;
  final bool highlighted;
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
            color: highlighted
                ? AuraColors.manaCyan
                : AuraColors.champagneGold.withValues(alpha: 0.25),
            width: highlighted ? 2.0 : 1.2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: AuraColors.champagneGold.withValues(alpha: 0.6),
              ),
              Text(
                '#${position + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AuraColors.silverMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OccupiedPocketTile extends StatelessWidget {
  const _OccupiedPocketTile({
    required this.item,
    required this.highlighted,
    required this.onTap,
  });

  final ItemModel item;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final verified = item.isPhysicallyVerified;
    final auraGlow = !verified ? AuraColors.psychicMagenta : _auraColor(item);

    return Semantics(
      button: true,
      label: l10n.openItem(item.name),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: auraGlow.withValues(
                alpha: item.isFoil && verified ? 0.36 : 0.16,
              ),
              blurRadius: item.isFoil && verified ? 12 : 6,
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
                      color: highlighted
                          ? AuraColors.manaCyan
                          : (!verified
                                ? AuraColors.psychicMagenta
                                : (item.isFoil
                                      ? AuraColors.champagneLight
                                      : AuraColors.champagneDark)),
                      width: highlighted || item.isFoil ? 1.8 : 1.2,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AuraColors.obsidianVoid.withValues(alpha: 0.9),
                      ],
                      stops: const [0.5, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 5,
                  top: 5,
                  child: _StatusCornerPill(item: item),
                ),
                if (item.hasSlab)
                  Positioned(
                    left: 5,
                    top: 23,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AuraColors.obsidianVoid.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AuraColors.solarGold,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${item.slabGrader} ${item.slabScore ?? '10'}',
                        style: const TextStyle(
                          color: AuraColors.solarGold,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                if (item.isFoil && verified)
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
                          fontSize: 8.5,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 7,
                  right: 7,
                  bottom: 6,
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AuraColors.creamText,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
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

class _StatusCornerPill extends StatelessWidget {
  const _StatusCornerPill({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!item.isPhysicallyVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
        decoration: BoxDecoration(
          color: AuraColors.psychicMagenta,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          l10n.apiUnverifiedBadge,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 7.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }
    if (item.tradeStatus == ItemTradeStatus.forTrade) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
        decoration: BoxDecoration(
          color: AuraColors.manaCyan,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          l10n.tradeBadgeShort,
          style: const TextStyle(
            color: AuraColors.obsidianVoid,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }
    if (item.tradeStatus == ItemTradeStatus.forSale) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
        decoration: BoxDecoration(
          color: AuraColors.emeraldAura,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          l10n.saleBadgeShort,
          style: const TextStyle(
            color: AuraColors.obsidianVoid,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
      decoration: BoxDecoration(
        color: AuraColors.obsidianVoid.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '#${item.positionIndex + 1}',
        style: const TextStyle(
          color: AuraColors.silverMuted,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
