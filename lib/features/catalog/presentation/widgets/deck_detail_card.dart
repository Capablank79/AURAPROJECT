import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/deck_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../providers/deck_providers.dart';
import 'deck_pull_list_sheet.dart';

class DeckDetailCard extends ConsumerStatefulWidget {
  const DeckDetailCard({
    required this.deck,
    required this.inventoryMatch,
    required this.onOpenImportExport,
    required this.onDeleteDeck,
    super.key,
  });

  final DeckModel deck;
  final DeckInventoryMatch inventoryMatch;
  final VoidCallback onOpenImportExport;
  final VoidCallback onDeleteDeck;

  @override
  ConsumerState<DeckDetailCard> createState() => _DeckDetailCardState();
}

class _DeckDetailCardState extends ConsumerState<DeckDetailCard> {
  final _cardController = TextEditingController();
  String _filter = 'all';

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatUsd = ref.watch(formatUsdProvider);

    var ownedCopies = 0;
    var missingCost = 0.0;
    final curve = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final entry in widget.deck.entries) {
      final matches = widget.inventoryMatch.lookup(entry.name);
      final have = matches.length.clamp(0, entry.quantity);
      ownedCopies += have;
      final missing = entry.quantity - have;
      if (missing > 0) {
        missingCost += missing * entry.estimatedUnitUsd;
      }
      final bucket = entry.cost <= 1 ? 1 : (entry.cost >= 5 ? 5 : entry.cost);
      curve[bucket] = (curve[bucket] ?? 0) + entry.quantity;
    }

    final totalCards = widget.deck.totalCards;
    final maxBucket = curve.values.fold<int>(1, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.ownedVsTotalLabel,
                            style: const TextStyle(
                              color: AuraColors.silverMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$ownedCopies / $totalCards',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AuraColors.emeraldAura,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.missingCostLabel,
                            style: const TextStyle(
                              color: AuraColors.silverMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatUsd(missingCost),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AuraColors.solarGold,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.deleteDeckButton,
                      onPressed: widget.onDeleteDeck,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AuraColors.psychicMagenta,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => showDeckPullListSheet(
                        context,
                        deck: widget.deck,
                        inventoryMatch: widget.inventoryMatch,
                      ),
                      icon: const Icon(Icons.place_outlined, size: 17),
                      label: Text(l10n.pullListButton),
                    ),
                    OutlinedButton.icon(
                      onPressed: widget.onOpenImportExport,
                      icon: const Icon(Icons.import_export, size: 17),
                      label: Text(l10n.importExportDeckButton),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.manaCurveTitle,
                  style: const TextStyle(
                    color: AuraColors.champagneGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 64,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final bucket in [1, 2, 3, 4, 5])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${curve[bucket] ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AuraColors.silverMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  height:
                                      30 *
                                      ((curve[bucket] ?? 0) / maxBucket).clamp(
                                        0.08,
                                        1.0,
                                      ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        AuraColors.manaCyan,
                                        AuraColors.champagneGold,
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  bucket == 1
                                      ? '0-1'
                                      : (bucket == 5 ? '5+' : '$bucket'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final entry in {
                'all': l10n.deckFilterAll,
                'owned': l10n.deckFilterOwned,
                'missing': l10n.deckFilterMissing,
              }.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: _filter == entry.key,
                    onSelected: (_) => setState(() => _filter = entry.key),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _cardController,
          onSubmitted: (_) => _quickAddCard(),
          decoration: InputDecoration(
            hintText: l10n.addCardToDeckHint,
            isDense: true,
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: AuraColors.champagneGold,
              ),
              onPressed: _quickAddCard,
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < widget.deck.entries.length; i++)
          if (_matchesFilter(widget.deck.entries[i]))
            _DeckEntryTile(
              deckId: widget.deck.id,
              entryIndex: i,
              entry: widget.deck.entries[i],
              locations: widget.inventoryMatch.lookup(
                widget.deck.entries[i].name,
              ),
              formatUsd: formatUsd,
            ),
      ],
    );
  }

  bool _matchesFilter(DeckCardEntry entry) {
    if (_filter == 'all') return true;
    final owned = widget.inventoryMatch.lookup(entry.name).length;
    if (_filter == 'owned') return owned > 0;
    return owned < entry.quantity;
  }

  Future<void> _quickAddCard() async {
    final name = _cardController.text.trim();
    if (name.isEmpty) {
      return;
    }
    _cardController.clear();
    await ref.read(decksProvider.notifier).addCard(
      deckId: widget.deck.id,
      cardName: name,
    );
  }
}

class _DeckEntryTile extends ConsumerWidget {
  const _DeckEntryTile({
    required this.deckId,
    required this.entryIndex,
    required this.entry,
    required this.locations,
    required this.formatUsd,
  });

  final String deckId;
  final int entryIndex;
  final DeckCardEntry entry;
  final List<OwnedCardLocation> locations;
  final String Function(double) formatUsd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final owned = locations.length.clamp(0, entry.quantity);
    final missing = entry.quantity - owned;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AuraColors.champagneGold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entry.quantity}x',
                  style: const TextStyle(
                    color: AuraColors.champagneGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    if (owned > 0)
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          final first = locations.first;
                          final router = GoRouter.maybeOf(context);
                          router?.push(
                            '/binder/${first.binderId}/item/${first.itemId}',
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                l10n.ownedInShowcaseBadge(
                                  owned,
                                  locations.first.formatted,
                                ),
                                style: const TextStyle(
                                  color: AuraColors.emeraldAura,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Tooltip(
                              message: l10n.openInShowcaseTooltip,
                              child: const Icon(
                                Icons.open_in_new,
                                size: 12,
                                color: AuraColors.manaCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (missing > 0)
                      Text(
                        l10n.missingFromShowcasesBadge(
                          formatUsd(missing * entry.estimatedUnitUsd),
                        ),
                        style: const TextStyle(
                          color: AuraColors.psychicMagenta,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline, size: 19),
                onPressed: () => ref.read(decksProvider.notifier).updateQuantity(
                  deckId: deckId,
                  entryIndex: entryIndex,
                  delta: -1,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline, size: 19),
                onPressed: () => ref.read(decksProvider.notifier).updateQuantity(
                  deckId: deckId,
                  entryIndex: entryIndex,
                  delta: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
