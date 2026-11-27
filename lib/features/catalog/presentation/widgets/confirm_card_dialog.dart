import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/item_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/catalog_repository.dart';

class ConfirmCardSelection {
  const ConfirmCardSelection({
    required this.condition,
    required this.isFoil,
    this.estimatedPrice,
    this.purchaseCost,
    this.tradeStatus = ItemTradeStatus.none,
    this.slabGrader,
    this.slabScore,
    this.slabCert,
  });

  final String condition;
  final bool isFoil;
  final double? estimatedPrice;
  final double? purchaseCost;
  final String tradeStatus;
  final String? slabGrader;
  final String? slabScore;
  final String? slabCert;
}

Future<ConfirmCardSelection?> showConfirmCardDialog(
  BuildContext context, {
  required CatalogResult result,
  bool fromApiSearch = false,
}) {
  return showDialog<ConfirmCardSelection>(
    context: context,
    builder: (context) => _ConfirmCardDialog(
      result: result,
      fromApiSearch: fromApiSearch,
    ),
  );
}

class _ConfirmCardDialog extends ConsumerStatefulWidget {
  const _ConfirmCardDialog({
    required this.result,
    required this.fromApiSearch,
  });

  final CatalogResult result;
  final bool fromApiSearch;

  @override
  ConsumerState<_ConfirmCardDialog> createState() => _ConfirmCardDialogState();
}

class _ConfirmCardDialogState extends ConsumerState<_ConfirmCardDialog> {
  String _condition = 'NM';
  bool _isFoil = false;
  late String _tradeStatus;
  String? _slabGrader;
  late final TextEditingController _priceController;
  final _costController = TextEditingController();
  final _slabScoreController = TextEditingController(text: '10');
  final _slabCertController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isFoil = widget.result.metadata['foil_hint'] == true;
    _tradeStatus = widget.fromApiSearch
        ? ItemTradeStatus.wishlistApi
        : ItemTradeStatus.none;
    _priceController = TextEditingController(
      text: widget.result.estimatedPrice?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _costController.dispose();
    _slabScoreController.dispose();
    _slabCertController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatUsd = ref.watch(formatUsdProvider);
    final parsedPrice = double.tryParse(
      _priceController.text.trim().replaceAll(',', '.'),
    );

    return AlertDialog(
      backgroundColor: AuraColors.smokedCharcoal,
      title: Text(l10n.confirmAddCardTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardPreviewHeader(result: widget.result, formatUsd: formatUsd),
            if (widget.fromApiSearch) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AuraColors.psychicMagenta.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AuraColors.psychicMagenta.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.cloud_outlined,
                          size: 15,
                          color: AuraColors.psychicMagenta,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.apiConfirmWarningTitle,
                            style: const TextStyle(
                              color: AuraColors.psychicMagenta,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.apiConfirmWarningBody,
                      style: const TextStyle(
                        color: AuraColors.creamText,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              isDense: true,
              decoration: InputDecoration(labelText: l10n.conditionLabel),
              items: [
                DropdownMenuItem(value: 'NM', child: Text(l10n.conditionNm)),
                DropdownMenuItem(value: 'LP', child: Text(l10n.conditionLp)),
                DropdownMenuItem(value: 'MP', child: Text(l10n.conditionMp)),
                DropdownMenuItem(value: 'HP', child: Text(l10n.conditionHp)),
                DropdownMenuItem(
                  value: 'SEALED',
                  child: Text(l10n.conditionSealed),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _condition = value ?? _condition),
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(l10n.isFoilQuestion),
              value: _isFoil,
              onChanged: (value) => setState(() => _isFoil = value),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: '${l10n.estimatedPriceLabel} (USD)',
                      prefixText: '\$ ',
                      helperText: parsedPrice != null && parsedPrice > 0
                          ? formatUsd(parsedPrice)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _costController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.purchaseCostLabel,
                      prefixText: '\$ ',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (!widget.fromApiSearch) ...[
              DropdownButtonFormField<String>(
                initialValue: _tradeStatus,
                isDense: true,
                decoration: InputDecoration(labelText: l10n.tradeStatusLabel),
                items: [
                  DropdownMenuItem(
                    value: ItemTradeStatus.none,
                    child: Text(l10n.tradeStatusNone),
                  ),
                  DropdownMenuItem(
                    value: ItemTradeStatus.forTrade,
                    child: Text(l10n.tradeStatusForTrade),
                  ),
                  DropdownMenuItem(
                    value: ItemTradeStatus.forSale,
                    child: Text(l10n.tradeStatusForSale),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _tradeStatus = value ?? _tradeStatus),
              ),
              const SizedBox(height: 10),
            ],
            DropdownButtonFormField<String?>(
              initialValue: _slabGrader,
              isDense: true,
              decoration: InputDecoration(labelText: l10n.slabGraderLabel),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.slabNoneOption)),
                const DropdownMenuItem(value: 'PSA', child: Text('PSA')),
                const DropdownMenuItem(value: 'BGS', child: Text('BGS')),
                const DropdownMenuItem(value: 'CGC', child: Text('CGC')),
              ],
              onChanged: (value) => setState(() => _slabGrader = value),
            ),
            if (_slabGrader != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _slabScoreController,
                      decoration: InputDecoration(
                        labelText: l10n.slabScoreLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _slabCertController,
                      decoration: InputDecoration(
                        labelText: l10n.slabCertLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            ConfirmCardSelection(
              condition: _condition,
              isFoil: _isFoil,
              estimatedPrice: parsedPrice,
              purchaseCost: double.tryParse(
                _costController.text.trim().replaceAll(',', '.'),
              ),
              tradeStatus: widget.fromApiSearch
                  ? ItemTradeStatus.wishlistApi
                  : _tradeStatus,
              slabGrader: _slabGrader,
              slabScore: _slabGrader != null ? _slabScoreController.text : null,
              slabCert: _slabGrader != null ? _slabCertController.text : null,
            ),
          ),
          child: Text(l10n.addItemButton),
        ),
      ],
    );
  }
}

class _CardPreviewHeader extends StatelessWidget {
  const _CardPreviewHeader({required this.result, required this.formatUsd});

  final CatalogResult result;
  final String Function(double) formatUsd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 46,
            height: 64,
            child: Image.network(
              result.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.style, color: AuraColors.champagneGold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (result.metadata['expansion'] != null)
                Text(
                  result.metadata['expansion'].toString(),
                  style: const TextStyle(
                    color: AuraColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              if (result.estimatedPrice != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    formatUsd(result.estimatedPrice!),
                    style: const TextStyle(
                      color: AuraColors.solarGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
