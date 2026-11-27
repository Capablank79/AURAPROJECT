import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/collections/collection_l10n.dart';
import '../../../../core/models/binder_model.dart';
import '../../../../core/models/item_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../core/widgets/aura_sigil_logo.dart';
import '../../../../l10n/generated/app_localizations.dart';

Future<void> showQrPosterSheet(
  BuildContext context, {
  required BinderModel binder,
  required String username,
  required List<ItemModel> items,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AuraColors.obsidianVoid,
    builder: (_) => _QrPosterSheet(
      binder: binder,
      username: username,
      items: items,
    ),
  );
}

class _QrPosterSheet extends ConsumerWidget {
  const _QrPosterSheet({
    required this.binder,
    required this.username,
    required this.items,
  });

  final BinderModel binder;
  final String username;
  final List<ItemModel> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatUsd = ref.watch(formatUsdProvider);
    final verified = items.where((i) => i.isPhysicallyVerified).toList();
    final totalUsd = verified.fold<double>(
      0,
      (sum, item) => sum + (item.estimatedPrice ?? 0),
    );
    final topGems = List<ItemModel>.from(verified)
      ..sort(
        (a, b) => (b.estimatedPrice ?? 0).compareTo(a.estimatedPrice ?? 0),
      );
    final deepLink = 'auradeck.app/u/$username/${binder.id}';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.qrPosterTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AuraColors.solarGold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AuraColors.smokedCharcoal,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AuraColors.solarGold, width: 1.8),
                ),
                child: Column(
                  children: [
                    const AuraSigilLogo(size: 44, showAura: true),
                    const SizedBox(height: 8),
                    Text(
                      binder.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AuraColors.creamText,
                      ),
                    ),
                    Text(
                      '@$username · ${CollectionL10n.binderCollectionLabel(l10n, binder)}',
                      style: const TextStyle(
                        color: AuraColors.silverMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: CustomPaint(
                        size: const Size.square(138),
                        painter: _DeterministicQrPainter(data: deepLink),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      formatUsd(totalUsd),
                      style: const TextStyle(
                        color: AuraColors.solarGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    if (topGems.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.qrPosterTopGems,
                        style: const TextStyle(
                          color: AuraColors.manaCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final gem in topGems.take(3))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  gem.hasSlab
                                      ? '${gem.name} [${gem.slabGrader} ${gem.slabScore ?? '10'}]'
                                      : gem.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              if (gem.estimatedPrice != null)
                                Text(
                                  formatUsd(gem.estimatedPrice!),
                                  style: const TextStyle(
                                    color: AuraColors.emeraldAura,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      deepLink,
                      style: const TextStyle(
                        color: AuraColors.silverMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => SharePlus.instance.share(
                ShareParams(text: l10n.shareBinderMessage(deepLink)),
              ),
              icon: const Icon(Icons.qr_code_2),
              label: Text(l10n.shareQrLinkButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeterministicQrPainter extends CustomPainter {
  const _DeterministicQrPainter({required this.data});

  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    const cells = 21;
    final cell = size.width / cells;
    final paint = Paint()..color = AuraColors.obsidianVoid;

    var hash = 2166136261;
    for (final unit in data.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0x7fffffff;
    }

    for (var r = 0; r < cells; r++) {
      for (var c = 0; c < cells; c++) {
        final inFinder =
            (r < 7 && c < 7) ||
            (r < 7 && c >= cells - 7) ||
            (r >= cells - 7 && c < 7);
        if (inFinder) {
          final lr = r < 7 ? r : r - (cells - 7);
          final lc = c < 7 ? c : c - (cells - 7);
          final draw =
              lr == 0 ||
              lr == 6 ||
              lc == 0 ||
              lc == 6 ||
              (lr >= 2 && lr <= 4 && lc >= 2 && lc <= 4);
          if (draw) {
            canvas.drawRect(
              Rect.fromLTWH(c * cell, r * cell, cell + 0.4, cell + 0.4),
              paint,
            );
          }
        } else {
          final bit = ((hash >> ((r * 7 + c * 13) % 24)) ^ (r * 31 + c * 17)) & 1;
          if (bit == 1) {
            canvas.drawRect(
              Rect.fromLTWH(c * cell, r * cell, cell + 0.3, cell + 0.3),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DeterministicQrPainter oldDelegate) =>
      oldDelegate.data != data;
}
