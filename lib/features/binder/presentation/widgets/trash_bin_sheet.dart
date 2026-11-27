import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/item_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../core/widgets/aura_sigil_logo.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../catalog/providers/deck_providers.dart';
import '../../data/repositories/binder_repository.dart';
import '../../providers/binder_providers.dart';

Future<void> showTrashBinSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AuraColors.obsidianVoid,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      side: BorderSide(
        color: AuraColors.psychicMagenta.withValues(alpha: 0.35),
      ),
    ),
    builder: (_) => const _TrashBinSheet(),
  );
}

class _TrashBinSheet extends ConsumerWidget {
  const _TrashBinSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trashAsync = ref.watch(trashedItemsProvider);
    final formatUsd = ref.watch(formatUsdProvider);

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
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
                    Icons.delete_sweep_outlined,
                    color: AuraColors.psychicMagenta,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.trashBinTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AuraColors.creamText,
                      ),
                    ),
                  ),
                  if ((trashAsync.valueOrNull?.isNotEmpty ?? false))
                    TextButton(
                      onPressed: () => _confirmEmptyTrash(
                        context,
                        ref,
                        trashAsync.valueOrNull!.length,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AuraColors.psychicMagenta,
                      ),
                      child: Text(l10n.emptyTrashButton),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.trashBinSubtitle,
                style: const TextStyle(
                  color: AuraColors.silverMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: trashAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Center(child: Text(l10n.genericError)),
                  data: (records) {
                    if (records.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 46,
                              color: AuraColors.silverMuted.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              l10n.trashBinEmptyMessage,
                              style: const TextStyle(
                                color: AuraColors.mutedText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: records.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _TrashedRecordTile(
                          record: record,
                          formatUsd: formatUsd,
                        );
                      },
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

  Future<void> _confirmEmptyTrash(
    BuildContext context,
    WidgetRef ref,
    int count,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AuraColors.smokedCharcoal,
        title: Text(l10n.emptyTrashButton),
        content: Text(l10n.emptyTrashConfirm(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.permanentDeleteButton),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    await ref.read(binderRepositoryProvider).emptyTrash();
    ref.invalidate(trashedItemsProvider);
  }
}

class _TrashedRecordTile extends ConsumerWidget {
  const _TrashedRecordTile({
    required this.record,
    required this.formatUsd,
  });

  final TrashedItemRecord record;
  final String Function(double) formatUsd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final item = record.item;

    return Card(
      color: AuraColors.smokedCharcoal,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 44,
                height: 60,
                child: item.imageUrl.startsWith('mock://')
                    ? AuraCardCrestPlaceholder(name: item.name, compact: true)
                    : Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => AuraCardCrestPlaceholder(
                          name: item.name,
                          compact: true,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.trashOriginLabel(
                      record.binderTitle,
                      item.positionIndex + 1,
                    ),
                    style: const TextStyle(
                      color: AuraColors.silverMuted,
                      fontSize: 11,
                    ),
                  ),
                  if (item.estimatedPrice != null)
                    Text(
                      formatUsd(item.estimatedPrice!),
                      style: const TextStyle(
                        color: AuraColors.solarGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _restore(context, ref),
              icon: const Icon(Icons.restore, size: 16),
              label: Text(l10n.restoreFromTrashButton),
            ),
            IconButton(
              tooltip: l10n.permanentDeleteButton,
              onPressed: () async {
                await ref
                    .read(binderRepositoryProvider)
                    .permanentlyDeleteFromTrash(item.id);
                ref.invalidate(trashedItemsProvider);
              },
              icon: const Icon(
                Icons.close,
                size: 18,
                color: AuraColors.psychicMagenta,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      final restored = await ref
          .read(binderRepositoryProvider)
          .restoreItemFromTrash(record.item.id);
      ref.invalidate(trashedItemsProvider);
      ref.invalidate(binderItemsProvider(restored.binderId));
      ref.invalidate(portfolioValuationProvider);
      ref.invalidate(deckInventoryMatchProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.restoredFromTrashMessage(
                restored.name,
                restored.positionIndex + 1,
              ),
            ),
          ),
        );
      }
    } on BinderCapacityException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.binderFullButton)));
      }
    } on BinderRepositoryException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    }
  }
}
