import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../catalog/providers/catalog_providers.dart';

class ItemMetadataCard extends ConsumerStatefulWidget {
  const ItemMetadataCard({
    required this.metadata,
    this.estimatedPrice,
    super.key,
  });

  final Map<String, dynamic> metadata;
  final double? estimatedPrice;

  @override
  ConsumerState<ItemMetadataCard> createState() => _ItemMetadataCardState();
}

class _ItemMetadataCardState extends ConsumerState<ItemMetadataCard> {
  String? _translatedRules;
  bool _showTranslated = false;
  bool _translating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expansion = _readValue(['expansion', 'set_name']);
    final cardType = _readValue(['type', 'card_type']);
    final rarity = _readValue(['rarity']);
    final number = _readValue(['number', 'collector_number']);
    final rulesText = _readValue(['oracleText', 'oracle_text']);
    final slabGrader = _readValue(['slab_grader']);
    final slabScore = _readValue(['slab_score']) ?? '10';
    final slabCert = _readValue(['slab_cert']);
    final centering = _readValue(['centering_ratio']);
    final estGrade = _readValue(['estimated_grade']);
    final purchaseCost = (widget.metadata['purchase_cost'] as num?)?.toDouble();
    final formatUsd = ref.watch(formatUsdProvider);

    final slabSummary = slabGrader == null
        ? null
        : '$slabGrader $slabScore${slabCert != null ? ' · #$slabCert' : ''}';
    final roiDelta = (widget.estimatedPrice != null && purchaseCost != null)
        ? widget.estimatedPrice! - purchaseCost
        : null;

    final rows = <(String, String)>[
      if (widget.estimatedPrice != null)
        (l10n.estimatedPriceLabel, formatUsd(widget.estimatedPrice!)),
      if (purchaseCost != null)
        (l10n.purchaseCostLabel, formatUsd(purchaseCost)),
      if (roiDelta != null)
        (
          l10n.roiLabel,
          '${roiDelta >= 0 ? '+' : '-'}${formatUsd(roiDelta.abs())}',
        ),
      if (slabSummary != null) (l10n.slabGraderLabel, slabSummary),
      if (centering != null)
        (
          l10n
              .scannerCenteringLabel(centering, estGrade ?? 'PSA 10')
              .split('·')
              .first
              .trim(),
          estGrade != null ? '$centering ($estGrade)' : centering,
        ),
      if (expansion != null) (l10n.expansionLabel, expansion),
      if (cardType != null) (l10n.cardTypeLabel, cardType),
      if (rarity != null) (l10n.rarityLabel, rarity),
      if (number != null) (l10n.cardNumberLabel, number),
    ];

    if (rows.isEmpty && rulesText == null) {
      return const SizedBox.shrink();
    }

    final displayedRules = _showTranslated && _translatedRules != null
        ? _translatedRules!
        : rulesText;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.technicalSheetTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AuraColors.champagneGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (rows.isNotEmpty) const SizedBox(height: 12),
            for (final (label, value) in rows) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 118,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AuraColors.silverMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (displayedRules != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.rulesTextLabel,
                      style: const TextStyle(
                        color: AuraColors.silverMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _translating
                        ? null
                        : () => _toggleTranslate(rulesText!),
                    icon: _translating
                        ? const SizedBox.square(
                            dimension: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.translate, size: 16),
                    label: Text(
                      _showTranslated
                          ? l10n.showOriginalTextButton
                          : l10n.translateOfflineButton,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(displayedRules, style: const TextStyle(height: 1.45)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _toggleTranslate(String originalText) async {
    if (_showTranslated) {
      setState(() => _showTranslated = false);
      return;
    }
    if (_translatedRules != null) {
      setState(() => _showTranslated = true);
      return;
    }
    setState(() => _translating = true);
    try {
      final langCode = ref.read(appLocaleProvider).languageCode;
      final translated = await ref
          .read(mlKitServiceProvider)
          .translateTextOffline(originalText, langCode);
      if (mounted) {
        setState(() {
          _translatedRules = translated;
          _showTranslated = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _translating = false);
      }
    }
  }

  String? _readValue(List<String> keys) {
    for (final key in keys) {
      final raw = widget.metadata[key]?.toString().trim();
      if (raw != null && raw.isNotEmpty && raw != 'null') {
        return raw;
      }
    }
    return null;
  }
}
