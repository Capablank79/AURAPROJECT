import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/collections/collection_l10n.dart';
import '../../../core/models/item_model.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../core/widgets/aura_sigil_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../profile/data/report_repository.dart';
import '../providers/binder_providers.dart';
import 'widgets/aura_ai_strategy_tab.dart';
import 'widgets/holo_foil_card_widget.dart';
import 'widgets/item_metadata_card.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({
    required this.binderId,
    required this.itemId,
    this.publicView = false,
    super.key,
  });

  final String binderId;
  final String itemId;
  final bool publicView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final parameters = (binderId: binderId, itemId: itemId);
    final itemAsync = ref.watch(
      publicView ? publicItemProvider(parameters) : itemProvider(parameters),
    );

    return Scaffold(
      appBar: AppBar(
        title: itemAsync.when(
          data: (item) => Text(item?.name ?? l10n.itemUnavailable),
          loading: () => Text(l10n.loading),
          error: (_, _) => Text(l10n.itemUnavailable),
        ),
      ),
      body: AuraBackdrop(
        child: SafeArea(
          child: itemAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: FilledButton.tonal(
                onPressed: () => ref.invalidate(
                  publicView
                      ? publicItemProvider(parameters)
                      : itemProvider(parameters),
                ),
                child: Text(l10n.retryButton),
              ),
            ),
            data: (item) {
              if (item == null) {
                return Center(child: Text(l10n.itemUnavailable));
              }
              return _ItemDetailBody(
                binderId: binderId,
                item: item,
                publicView: publicView,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ItemDetailBody extends ConsumerStatefulWidget {
  const _ItemDetailBody({
    required this.binderId,
    required this.item,
    required this.publicView,
  });

  final String binderId;
  final ItemModel item;
  final bool publicView;

  @override
  ConsumerState<_ItemDetailBody> createState() => _ItemDetailBodyState();
}

class _ItemDetailBodyState extends ConsumerState<_ItemDetailBody> {
  late TextEditingController _notesController;
  late TextEditingController _priceController;
  late bool _isFoil;
  bool _saving = false;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.item.notes);
    _priceController = TextEditingController(
      text: widget.item.estimatedPrice?.toStringAsFixed(2) ?? '',
    );
    _isFoil = widget.item.isFoil;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sourceLabel = switch (widget.item.sourceType) {
      'api_tcgdex' => l10n.sourceTcgdex,
      'api_scryfall' => l10n.sourceScryfall,
      'api_ygoprodeck' => l10n.sourceYgoprodeck,
      _ => l10n.sourceUpload,
    };
    final collectionLabel = CollectionL10n.collectionName(
      l10n,
      widget.item.collectionCode,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        HolographicItemCard(item: widget.item, isFoil: _isFoil),
        const SizedBox(height: 20),
        Text(
          widget.item.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DetailChip(icon: Icons.style_outlined, label: collectionLabel),
            _DetailChip(
              icon: Icons.verified_outlined,
              label: l10n.conditionValue(widget.item.condition),
            ),
            _DetailChip(icon: Icons.cloud_outlined, label: sourceLabel),
            if (widget.item.estimatedPrice != null)
              _DetailChip(
                icon: Icons.attach_money,
                label: l10n.priceValue(
                  ref.watch(formatUsdProvider)(widget.item.estimatedPrice!),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        if (widget.publicView) ...[
          ItemMetadataCard(
            metadata: widget.item.metadata,
            estimatedPrice: widget.item.estimatedPrice,
          ),
          const SizedBox(height: 18),
          if (widget.item.notes?.isNotEmpty ?? false) ...[
            Text(
              l10n.notesLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(widget.item.notes!),
            const SizedBox(height: 20),
          ],
          OutlinedButton.icon(
            onPressed: _report,
            icon: const Icon(Icons.flag_outlined),
            label: Text(l10n.reportItemButton),
          ),
        ] else ...[
          SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 0, label: Text(l10n.tabSheetLabel)),
              ButtonSegment(value: 1, label: Text(l10n.tabAuraAiLabel)),
              ButtonSegment(value: 2, label: Text(l10n.tabShowcaseLabel)),
            ],
            selected: {_activeTab},
            onSelectionChanged: (values) =>
                setState(() => _activeTab = values.first),
          ),
          const SizedBox(height: 16),
          if (_activeTab == 0)
            ItemMetadataCard(
              metadata: widget.item.metadata,
              estimatedPrice: widget.item.estimatedPrice,
            ),
          if (_activeTab == 1) AuraAiStrategyTab(item: widget.item),
          if (_activeTab == 2) _buildMyShowcaseControls(l10n),
        ],
      ],
    );
  }

  Widget _buildMyShowcaseControls(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isFoil,
          title: Text(l10n.foilLabel),
          subtitle: Text(l10n.foilHint),
          onChanged: (value) => setState(() => _isFoil = value),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: '${l10n.estimatedPriceLabel} (USD)',
            prefixText: '\$ ',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: l10n.notesLabel,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(l10n.saveChangesButton),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.deckBuilderComingSoon)));
          },
          icon: const Icon(Icons.layers_outlined),
          label: Text(l10n.addToDeckButton),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _saving ? null : _delete,
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.deleteItemButton),
          style: OutlinedButton.styleFrom(
            foregroundColor: AuraColors.psychicMagenta,
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final parsedPrice = double.tryParse(
        _priceController.text.trim().replaceAll(',', '.'),
      );
      await ref
          .read(binderRepositoryProvider)
          .updateItem(
            widget.item.copyWith(
              isFoil: _isFoil,
              estimatedPrice: parsedPrice,
              notes: _notesController.text.trim(),
            ),
          );
      ref.invalidate(binderItemsProvider(widget.binderId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).saved)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteItemTitle),
        content: Text(l10n.deleteItemMessage(widget.item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(binderRepositoryProvider).deleteItem(widget.item.id);
    ref.invalidate(binderItemsProvider(widget.binderId));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _report() async {
    final l10n = AppLocalizations.of(context);
    final reason = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AuraColors.obsidianVoid,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                l10n.reportReasonTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final entry in {
              'inappropriate': l10n.reasonInappropriate,
              'copyright': l10n.reasonCopyright,
              'spam': l10n.reasonSpam,
              'other': l10n.reasonOther,
            }.entries)
              ListTile(
                title: Text(entry.value),
                onTap: () => Navigator.pop(context, entry.value),
              ),
          ],
        ),
      ),
    );
    if (reason == null) {
      return;
    }
    final profile = await ref.read(activeProfileProvider.future);
    final ReportRepository reports = ref.read(reportRepositoryProvider);
    await reports.createReport(
      itemId: widget.item.id,
      reporterId: profile.id,
      reason: reason,
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reportSubmitted)));
    }
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 17, color: AuraColors.champagneGold),
      label: Text(label),
      backgroundColor: AuraColors.smokedCharcoal,
    );
  }
}
