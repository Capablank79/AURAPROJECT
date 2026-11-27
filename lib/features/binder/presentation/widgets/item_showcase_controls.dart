import 'package:flutter/material.dart';

import '../../../../core/models/item_model.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ItemShowcaseControls extends StatelessWidget {
  const ItemShowcaseControls({
    required this.item,
    required this.isFoil,
    required this.tradeStatus,
    required this.slabGrader,
    required this.priceController,
    required this.costController,
    required this.slabScoreController,
    required this.slabCertController,
    required this.notesController,
    required this.saving,
    required this.onFoilChanged,
    required this.onTradeStatusChanged,
    required this.onSlabGraderChanged,
    required this.onSave,
    required this.onAddToDeck,
    required this.onDelete,
    super.key,
  });

  final ItemModel item;
  final bool isFoil;
  final String tradeStatus;
  final String? slabGrader;
  final TextEditingController priceController;
  final TextEditingController costController;
  final TextEditingController slabScoreController;
  final TextEditingController slabCertController;
  final TextEditingController notesController;
  final bool saving;
  final ValueChanged<bool> onFoilChanged;
  final ValueChanged<String> onTradeStatusChanged;
  final ValueChanged<String?> onSlabGraderChanged;
  final VoidCallback onSave;
  final VoidCallback onAddToDeck;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final verified = item.isPhysicallyVerified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isFoil,
          title: Text(l10n.foilLabel),
          subtitle: Text(l10n.foilHint),
          onChanged: onFoilChanged,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: verified ? tradeStatus : ItemTradeStatus.wishlistApi,
          decoration: InputDecoration(
            labelText: l10n.tradeStatusLabel,
            helperText: verified ? null : l10n.apiCannotTradeMessage,
          ),
          items: verified
              ? [
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
                ]
              : [
                  DropdownMenuItem(
                    value: ItemTradeStatus.wishlistApi,
                    child: Text(l10n.tradeStatusWishlistApi),
                  ),
                ],
          onChanged: verified
              ? (val) {
                  if (val != null) {
                    onTradeStatusChanged(val);
                  }
                }
              : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: '${l10n.estimatedPriceLabel} (USD)',
                  prefixText: '\$ ',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: costController,
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
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          initialValue: slabGrader,
          decoration: InputDecoration(labelText: l10n.slabGraderLabel),
          items: [
            DropdownMenuItem(value: null, child: Text(l10n.slabNoneOption)),
            const DropdownMenuItem(value: 'PSA', child: Text('PSA')),
            const DropdownMenuItem(value: 'BGS', child: Text('BGS')),
            const DropdownMenuItem(value: 'CGC', child: Text('CGC')),
          ],
          onChanged: onSlabGraderChanged,
        ),
        if (slabGrader != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: slabScoreController,
                  decoration: InputDecoration(labelText: l10n.slabScoreLabel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: slabCertController,
                  decoration: InputDecoration(labelText: l10n.slabCertLabel),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: notesController,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: l10n.notesLabel,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: saving ? null : onSave,
          icon: const Icon(Icons.save_outlined),
          label: Text(l10n.saveChangesButton),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onAddToDeck,
          icon: const Icon(Icons.layers_outlined),
          label: Text(l10n.addToDeckButton),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: saving ? null : onDelete,
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.moveToTrashButton),
          style: OutlinedButton.styleFrom(
            foregroundColor: AuraColors.psychicMagenta,
          ),
        ),
      ],
    );
  }
}
