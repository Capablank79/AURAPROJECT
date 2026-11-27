import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/collections/collection_registry.dart';
import '../../../../core/models/binder_model.dart';
import '../../../../core/models/item_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../binder/providers/binder_providers.dart';
import '../../data/catalog_repository.dart';
import '../../providers/catalog_providers.dart';
import '../card_scanner_screen.dart';

class _QueuedScanItem {
  _QueuedScanItem({required this.result});

  final CatalogResult result;
  bool isFoil = false;
}

Future<int> showBatchScannerSheet(
  BuildContext context, {
  required BinderModel binder,
  required String collectionLabel,
  CatalogProvider? provider,
}) async {
  final added = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AuraColors.obsidianVoid,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: AuraColors.manaCyan.withValues(alpha: 0.35)),
    ),
    builder: (_) => _BatchScannerSheet(
      binder: binder,
      collectionLabel: collectionLabel,
      provider: provider,
    ),
  );
  return added ?? 0;
}

class _BatchScannerSheet extends ConsumerStatefulWidget {
  const _BatchScannerSheet({
    required this.binder,
    required this.collectionLabel,
    this.provider,
  });

  final BinderModel binder;
  final String collectionLabel;
  final CatalogProvider? provider;

  @override
  ConsumerState<_BatchScannerSheet> createState() => _BatchScannerSheetState();
}

class _BatchScannerSheetState extends ConsumerState<_BatchScannerSheet> {
  final List<_QueuedScanItem> _queue = [];
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatUsd = ref.watch(formatUsdProvider);

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
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
                    Icons.filter_none_outlined,
                    color: AuraColors.manaCyan,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.batchScannerTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.batchScannerHint,
                style: const TextStyle(
                  color: AuraColors.silverMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _captureFromScanner,
                      icon: const Icon(Icons.document_scanner_outlined),
                      label: Text(l10n.batchScanNextButton),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _captureFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.galleryButton),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: _queue.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Text(
                            l10n.batchEmptyMessage,
                            style: const TextStyle(color: AuraColors.mutedText),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _queue.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final entry = _queue[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AuraColors.smokedCharcoal,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AuraColors.emeraldAura.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified_outlined,
                                  size: 18,
                                  color: AuraColors.emeraldAura,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.result.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (entry.result.estimatedPrice != null)
                                        Text(
                                          formatUsd(
                                            entry.result.estimatedPrice!,
                                          ),
                                          style: const TextStyle(
                                            color: AuraColors.solarGold,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                FilterChip(
                                  label: const Text('FOIL'),
                                  selected: entry.isFoil,
                                  onSelected: (val) =>
                                      setState(() => entry.isFoil = val),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _queue.removeAt(index)),
                                  icon: const Icon(Icons.close, size: 18),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: (_busy || _queue.isEmpty) ? null : _commitBatch,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l10n.batchCommitButton(_queue.length)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureFromScanner() async {
    final scanned = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (_) => CardScannerScreen(
          collectionLabel: widget.collectionLabel,
          provider: widget.provider,
        ),
      ),
    );
    if (!mounted || scanned == null) {
      return;
    }
    if (scanned is CatalogResult) {
      setState(() => _queue.add(_QueuedScanItem(result: scanned)));
    } else if (scanned is String && scanned.trim().isNotEmpty) {
      await _resolveAndEnqueueTitle(scanned.trim());
    }
  }

  Future<void> _captureFromGallery() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final image = await ref
          .read(imagePickerProvider)
          .pickImage(source: ImageSource.gallery, imageQuality: 95);
      if (image == null || !mounted) {
        return;
      }
      final title = await ref
          .read(cardTextExtractorProvider)
          .extractSuggestedTitle(image.path);
      if (!mounted) {
        return;
      }
      if (title != null && title.trim().isNotEmpty) {
        await _resolveAndEnqueueTitle(title.trim());
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.ocrNoTextDetected)));
      }
    } on PlatformException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.imagePermissionError)));
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _resolveAndEnqueueTitle(String title) async {
    final provider = widget.provider;
    if (provider != null) {
      final locale = Localizations.localeOf(context).languageCode;
      final matches = await ref
          .read(catalogRepositoryProvider)
          .search(provider: provider, query: title, languageCode: locale);
      if (matches.isNotEmpty && mounted) {
        setState(() => _queue.add(_QueuedScanItem(result: matches.first)));
        return;
      }
    }
    if (!mounted) {
      return;
    }
    setState(
      () => _queue.add(
        _QueuedScanItem(
          result: CatalogResult(
            collectionCode: widget.binder.collectionCode,
            sourceType: 'user_upload',
            externalId: 'scan-${DateTime.now().microsecondsSinceEpoch}',
            name: title,
            imageUrl: 'local://webp/scanned_card.webp',
            metadata: {'family': widget.binder.family},
          ),
        ),
      ),
    );
  }

  Future<void> _commitBatch() async {
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    try {
      final profile = await ref.read(activeProfileProvider.future);
      final existing = await ref.read(
        binderItemsProvider(widget.binder.id).future,
      );
      final occupied = existing.map((e) => e.positionIndex).toSet();
      var cursor = 0;
      var added = 0;

      for (final entry in _queue) {
        while (occupied.contains(cursor) && cursor < widget.binder.maxSlots) {
          cursor++;
        }
        if (cursor >= widget.binder.maxSlots) {
          break;
        }
        final item = entry.result
            .toItem(
              binderId: widget.binder.id,
              userId: profile.id,
              positionIndex: cursor,
              condition: 'NM',
              isFoil: entry.isFoil,
            )
            .withVaultMetadata(
              verificationOrigin: ItemVerificationOrigin.scanned,
            );
        await ref.read(binderRepositoryProvider).addItem(item);
        occupied.add(cursor);
        added++;
      }

      ref.invalidate(binderItemsProvider(widget.binder.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.batchCommittedMessage(added))),
        );
        Navigator.pop(context, added);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}
