import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/collections/collection_l10n.dart';
import '../../../core/models/deck_model.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/deck_providers.dart';
import 'widgets/deck_detail_card.dart';

class DecksScreen extends ConsumerStatefulWidget {
  const DecksScreen({super.key});

  @override
  ConsumerState<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends ConsumerState<DecksScreen> {
  String? _selectedDeckId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final decksAsync = ref.watch(decksProvider);
    final matchAsync = ref.watch(deckInventoryMatchProvider);

    return decksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.genericError)),
      data: (decks) {
        final selected = decks.isEmpty
            ? null
            : decks.firstWhere(
                (d) => d.id == _selectedDeckId,
                orElse: () => decks.first,
              );
        final match =
            matchAsync.valueOrNull ??
            const DeckInventoryMatch(locationsByCardName: {});

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.decksTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.decksSubtitle,
                        style: const TextStyle(
                          color: AuraColors.mutedText,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _showCreateDeckDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.newDeckButton),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (decks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  l10n.noDecksYetMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AuraColors.mutedText),
                ),
              )
            else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final deck in decks)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('${deck.title} (${deck.totalCards})'),
                          selected: selected?.id == deck.id,
                          onSelected: (_) =>
                              setState(() => _selectedDeckId = deck.id),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (selected != null)
                DeckDetailCard(
                  key: ValueKey(selected.id),
                  deck: selected,
                  inventoryMatch: match,
                  onOpenImportExport: () =>
                      _showImportExportSheet(context, selected),
                  onDeleteDeck: () async {
                    await ref
                        .read(decksProvider.notifier)
                        .deleteDeck(selected.id);
                    if (mounted) {
                      setState(() => _selectedDeckId = null);
                    }
                  },
                ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _showCreateDeckDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final formatController = TextEditingController(text: 'Commander');
    var gameType = 'magic';

    final created = await showDialog<DeckModel>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AuraColors.smokedCharcoal,
          title: Text(l10n.createDeckTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.deckNameLabel),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: gameType,
                decoration: InputDecoration(labelText: l10n.deckGameTypeLabel),
                items: [
                  DropdownMenuItem(
                    value: 'magic',
                    child: Text(CollectionL10n.collectionName(l10n, 'magic')),
                  ),
                  DropdownMenuItem(
                    value: 'pokemon',
                    child: Text(CollectionL10n.collectionName(l10n, 'pokemon')),
                  ),
                  DropdownMenuItem(
                    value: 'yugioh',
                    child: Text(CollectionL10n.collectionName(l10n, 'yugioh')),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => gameType = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: formatController,
                decoration: InputDecoration(labelText: l10n.deckFormatLabel),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () async {
                final title = nameController.text.trim();
                if (title.isEmpty) {
                  return;
                }
                final deck = await ref.read(decksProvider.notifier).createDeck(
                  title: title,
                  gameType: gameType,
                  format: formatController.text.trim(),
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext, deck);
                }
              },
              child: Text(l10n.createButton),
            ),
          ],
        ),
      ),
    );
    if (created != null && mounted) {
      setState(() => _selectedDeckId = created.id);
    }
  }

  Future<void> _showImportExportSheet(
    BuildContext context,
    DeckModel deck,
  ) async {
    final l10n = AppLocalizations.of(context);
    final text = deck.entries
        .map((e) => '${e.quantity} ${e.name}')
        .join('\n');
    final controller = TextEditingController(text: text);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.obsidianVoid,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AuraColors.champagneGold.withValues(alpha: 0.3)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.importExportDeckButton,
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                  color: AuraColors.champagneGold,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.deckIoHint,
                style: const TextStyle(
                  color: AuraColors.silverMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                minLines: 5,
                maxLines: 9,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: controller.text),
                        );
                        if (sheetContext.mounted) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(content: Text(l10n.deckCopiedMessage)),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy_outlined, size: 18),
                      label: Text(l10n.copyDecklistButton),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await ref.read(decksProvider.notifier).importLines(
                          deckId: deck.id,
                          rawText: controller.text,
                        );
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l10n.applyDecklistButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
