import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/collections/collection_l10n.dart';
import '../../../core/collections/collection_registry.dart';
import '../../../core/models/item_model.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../core/widgets/aura_sigil_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/presentation/card_scanner_screen.dart';
import '../../catalog/providers/deck_providers.dart';
import '../../profile/data/report_repository.dart';
import '../providers/binder_providers.dart';
import 'widgets/aura_ai_strategy_tab.dart';
import 'widgets/deck_picker_sheet.dart';
import 'widgets/holo_foil_card_widget.dart';
import 'widgets/item_metadata_card.dart';
import 'widgets/item_showcase_controls.dart';

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
                key: ValueKey(
                  '${item.id}-${item.isPhysicallyVerified}-${item.tradeStatus}-${item.slabGrader}',
                ),
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
    super.key,
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
  late TextEditingController _costController;
  late TextEditingController _slabScoreController;
  late TextEditingController _slabCertController;
  late bool _isFoil;
  late String _tradeStatus;
  late String? _slabGrader;
  bool _saving = false;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.item.notes);
    _priceController = TextEditingController(
      text: widget.item.estimatedPrice?.toStringAsFixed(2) ?? '',
    );
    _costController = TextEditingController(
      text: widget.item.purchaseCost?.toStringAsFixed(2) ?? '',
    );
    _slabScoreController = TextEditingController(
      text: widget.item.slabScore ?? '10',
    );
    _slabCertController = TextEditingController(
      text: widget.item.slabCert ?? '',
    );
    _isFoil = widget.item.isFoil;
    _tradeStatus = widget.item.tradeStatus;
    _slabGrader = widget.item.slabGrader;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _slabScoreController.dispose();
    _slabCertController.dispose();
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        HolographicItemCard(item: widget.item, isFoil: _isFoil),
        const SizedBox(height: 10),
        _AuthenticityStatusBanner(
          item: widget.item,
          publicView: widget.publicView,
          onVerifyWithScanner: () => _verifyWithScanner(collectionLabel),
        ),
        const SizedBox(height: 10),
        Text(
          widget.item.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
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
            if (widget.item.tradeStatus == ItemTradeStatus.forTrade)
              _DetailChip(
                icon: Icons.swap_horiz,
                label: l10n.tradeBadgeShort,
                accent: AuraColors.manaCyan,
              ),
            if (widget.item.tradeStatus == ItemTradeStatus.forSale)
              _DetailChip(
                icon: Icons.sell_outlined,
                label: l10n.saleBadgeShort,
                accent: AuraColors.solarGold,
              ),
          ],
        ),
        const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          if (_activeTab == 0)
            ItemMetadataCard(
              metadata: widget.item.metadata,
              estimatedPrice: widget.item.estimatedPrice,
            ),
          if (_activeTab == 1) AuraAiStrategyTab(item: widget.item),
          if (_activeTab == 2)
            ItemShowcaseControls(
              item: widget.item,
              isFoil: _isFoil,
              tradeStatus: _tradeStatus,
              slabGrader: _slabGrader,
              priceController: _priceController,
              costController: _costController,
              slabScoreController: _slabScoreController,
              slabCertController: _slabCertController,
              notesController: _notesController,
              saving: _saving,
              onFoilChanged: (val) => setState(() => _isFoil = val),
              onTradeStatusChanged: (val) => setState(() => _tradeStatus = val),
              onSlabGraderChanged: (val) => setState(() => _slabGrader = val),
              onSave: _save,
              onAddToDeck: () => showDeckPickerSheet(context, item: widget.item),
              onDelete: _delete,
            ),
        ],
      ],
    );
  }

  Future<void> _verifyWithScanner(String collectionLabel) async {
    final spec = CollectionRegistry.byCode(widget.item.collectionCode);
    final scanned = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (_) => CardScannerScreen(
          collectionLabel: collectionLabel,
          provider: spec.catalogProvider,
        ),
      ),
    );
    if (!mounted || scanned == null) {
      return;
    }
    final upgraded = widget.item.withVaultMetadata(
      verificationOrigin: ItemVerificationOrigin.scanned,
      tradeStatus: ItemTradeStatus.none,
    );
    await ref.read(binderRepositoryProvider).updateItem(upgraded);
    ref.invalidate(binderItemsProvider(widget.binderId));
    ref.invalidate(
      itemProvider((binderId: widget.binderId, itemId: widget.item.id)),
    );
    ref.invalidate(portfolioValuationProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).verifiedSuccessMessage)),
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final parsedPrice = double.tryParse(
        _priceController.text.trim().replaceAll(',', '.'),
      );
      final parsedCost = double.tryParse(
        _costController.text.trim().replaceAll(',', '.'),
      );
      final updated = widget.item
          .copyWith(
            isFoil: _isFoil,
            estimatedPrice: parsedPrice,
            notes: _notesController.text.trim(),
          )
          .withVaultMetadata(
            tradeStatus: widget.item.isPhysicallyVerified
                ? _tradeStatus
                : ItemTradeStatus.wishlistApi,
            clearSlab: _slabGrader == null,
            slabGrader: _slabGrader,
            slabScore: _slabGrader != null ? _slabScoreController.text : null,
            slabCert: _slabGrader != null ? _slabCertController.text : null,
            purchaseCost: parsedCost,
          );
      await ref.read(binderRepositoryProvider).updateItem(updated);
      ref.invalidate(binderItemsProvider(widget.binderId));
      ref.invalidate(
        itemProvider((binderId: widget.binderId, itemId: widget.item.id)),
      );
      ref.invalidate(portfolioValuationProvider);
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
        title: Text(l10n.moveToTrashButton),
        content: Text(l10n.moveToTrashConfirm(widget.item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.moveToTrashButton),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(binderRepositoryProvider).moveItemToTrash(widget.item.id);
    ref.invalidate(binderItemsProvider(widget.binderId));
    ref.invalidate(trashedItemsProvider);
    ref.invalidate(portfolioValuationProvider);
    ref.invalidate(deckInventoryMatchProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.movedToTrashMessage(widget.item.name))),
      );
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

class _AuthenticityStatusBanner extends StatelessWidget {
  const _AuthenticityStatusBanner({
    required this.item,
    required this.publicView,
    required this.onVerifyWithScanner,
  });

  final ItemModel item;
  final bool publicView;
  final VoidCallback onVerifyWithScanner;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (item.isPhysicallyVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AuraColors.emeraldAura.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AuraColors.emeraldAura.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.verified_rounded,
              size: 18,
              color: AuraColors.emeraldAura,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.physicalVerifiedBanner,
                style: const TextStyle(
                  color: AuraColors.emeraldAura,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AuraColors.psychicMagenta.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AuraColors.psychicMagenta.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 18,
                color: AuraColors.psychicMagenta,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.apiUnverifiedBannerTitle,
                  style: const TextStyle(
                    color: AuraColors.psychicMagenta,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.apiUnverifiedBannerBody,
            style: const TextStyle(
              color: AuraColors.creamText,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          if (!publicView) ...[
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: onVerifyWithScanner,
              icon: const Icon(Icons.document_scanner_outlined, size: 18),
              label: Text(l10n.verifyWithScannerButton),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label, this.accent});

  final IconData icon;
  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AuraColors.champagneGold;
    return Chip(
      avatar: Icon(icon, size: 17, color: color),
      label: Text(label),
      backgroundColor: AuraColors.smokedCharcoal,
    );
  }
}
