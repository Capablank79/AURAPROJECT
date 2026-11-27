import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/item_model.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../catalog/providers/deck_providers.dart';

Future<void> showDeckPickerSheet(
  BuildContext context, {
  required ItemModel item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AuraColors.obsidianVoid,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: AuraColors.champagneGold.withValues(alpha: 0.3)),
    ),
    builder: (_) => _DeckPickerSheet(item: item),
  );
}

class _DeckPickerSheet extends ConsumerStatefulWidget {
  const _DeckPickerSheet({required this.item});

  final ItemModel item;

  @override
  ConsumerState<_DeckPickerSheet> createState() => _DeckPickerSheetState();
}

class _DeckPickerSheetState extends ConsumerState<_DeckPickerSheet> {
  final _newTitleController = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _newTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final decksAsync = ref.watch(decksProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.selectDeckTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AuraColors.champagneGold,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            decksAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Text(l10n.genericError),
              data: (decks) {
                if (decks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      l10n.noDecksYetMessage,
                      style: const TextStyle(color: AuraColors.silverMuted),
                    ),
                  );
                }
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: decks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final deck = decks[index];
                      return Card(
                        color: AuraColors.smokedCharcoal,
                        child: ListTile(
                          leading: const Icon(
                            Icons.layers_outlined,
                            color: AuraColors.manaCyan,
                          ),
                          title: Text(
                            deck.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${deck.format ?? deck.gameType.toUpperCase()} · ${deck.totalCards}',
                          ),
                          trailing: const Icon(
                            Icons.add_circle_outline,
                            color: AuraColors.champagneGold,
                          ),
                          onTap: () => _addToDeck(deck.id, deck.title),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTitleController,
                    decoration: InputDecoration(
                      labelText: l10n.deckNameLabel,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.tonal(
                  onPressed: _creating ? null : _createAndAdd,
                  child: Text(l10n.newDeckButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToDeck(String deckId, String deckTitle) async {
    final l10n = AppLocalizations.of(context);
    await ref.read(decksProvider.notifier).addCard(
      deckId: deckId,
      cardName: widget.item.name,
      cost: widget.item.manaOrEnergyCost,
      estimatedUnitUsd: widget.item.estimatedPrice ?? 4.5,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addedToDeckMessage(widget.item.name, deckTitle)),
        ),
      );
    }
  }

  Future<void> _createAndAdd() async {
    final title = _newTitleController.text.trim();
    if (title.isEmpty) {
      return;
    }
    setState(() => _creating = true);
    try {
      final created = await ref.read(decksProvider.notifier).createDeck(
        title: title,
        gameType: widget.item.collectionCode,
        format: 'Standard',
      );
      await _addToDeck(created.id, created.title);
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }
}
