import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/catalog_repository.dart';

class ConfirmCardSelection {
  const ConfirmCardSelection({
    required this.condition,
    required this.isFoil,
    this.estimatedPrice,
  });

  final String condition;
  final bool isFoil;
  final double? estimatedPrice;
}

Future<ConfirmCardSelection?> showConfirmCardDialog(
  BuildContext context, {
  required CatalogResult result,
}) {
  return showDialog<ConfirmCardSelection>(
    context: context,
    builder: (context) => _ConfirmCardDialog(result: result),
  );
}

class _ConfirmCardDialog extends ConsumerStatefulWidget {
  const _ConfirmCardDialog({required this.result});

  final CatalogResult result;

  @override
  ConsumerState<_ConfirmCardDialog> createState() => _ConfirmCardDialogState();
}

class _ConfirmCardDialogState extends ConsumerState<_ConfirmCardDialog> {
  String _condition = 'NM';
  bool _isFoil = false;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.result.estimatedPrice?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
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
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    height: 66,
                    child: Image.network(
                      widget.result.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.style,
                        color: AuraColors.champagneGold,
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
                        widget.result.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (widget.result.metadata['expansion'] != null)
                        Text(
                          widget.result.metadata['expansion'].toString(),
                          style: const TextStyle(
                            color: AuraColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      if (widget.result.estimatedPrice != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            formatUsd(widget.result.estimatedPrice!),
                            style: const TextStyle(
                              color: AuraColors.solarGold,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.result.metadata['oracleText'] != null &&
                widget.result.metadata['oracleText']
                    .toString()
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AuraColors.obsidianVoid.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AuraColors.champagneGold.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  widget.result.metadata['oracleText'].toString(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AuraColors.silverMuted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _condition,
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
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.isFoilQuestion),
              value: _isFoil,
              onChanged: (value) => setState(() => _isFoil = value),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: '${l10n.estimatedPriceLabel} (USD)',
                prefixText: '\$ ',
                helperText: parsedPrice != null && parsedPrice > 0
                    ? formatUsd(parsedPrice)
                    : null,
              ),
            ),
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
              estimatedPrice: double.tryParse(
                _priceController.text.trim().replaceAll(',', '.'),
              ),
            ),
          ),
          child: Text(l10n.addItemButton),
        ),
      ],
    );
  }
}
