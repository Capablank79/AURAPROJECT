import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/deck_model.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../providers/deck_providers.dart';

Future<void> showDeckPullListSheet(
  BuildContext context, {
  required DeckModel deck,
  required DeckInventoryMatch inventoryMatch,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AuraColors.obsidianVoid,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      side: BorderSide(color: AuraColors.emeraldAura.withValues(alpha: 0.35)),
    ),
    builder: (_) => _DeckPullListSheet(
      deck: deck,
      inventoryMatch: inventoryMatch,
    ),
  );
}

class _DeckPullListSheet extends StatelessWidget {
  const _DeckPullListSheet({
    required this.deck,
    required this.inventoryMatch,
  });

  final DeckModel deck;
  final DeckInventoryMatch inventoryMatch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pulls = <(String cardName, OwnedCardLocation loc)>[];

    for (final entry in deck.entries) {
      final matches = inventoryMatch.lookup(entry.name);
      for (final loc in matches.take(entry.quantity)) {
        pulls.add((entry.name, loc));
      }
    }
    pulls.sort((a, b) {
      final binderCmp = a.$2.binderTitle.compareTo(b.$2.binderTitle);
      if (binderCmp != 0) return binderCmp;
      return a.$2.pocketNumber.compareTo(b.$2.pocketNumber);
    });

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    color: AuraColors.emeraldAura,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.pullListTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AuraColors.emeraldAura,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Text(
                l10n.pullListSubtitle,
                style: const TextStyle(
                  color: AuraColors.silverMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              if (pulls.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    l10n.pullListEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AuraColors.mutedText),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: pulls.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final (cardName, loc) = pulls[index];
                      return Card(
                        color: AuraColors.smokedCharcoal,
                        child: ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.check_circle,
                            color: AuraColors.emeraldAura,
                            size: 20,
                          ),
                          title: Text(
                            cardName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            loc.formatted,
                            style: const TextStyle(
                              color: AuraColors.champagneGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: AuraColors.manaCyan,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            context.push(
                              '/binder/${loc.binderId}/item/${loc.itemId}',
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
