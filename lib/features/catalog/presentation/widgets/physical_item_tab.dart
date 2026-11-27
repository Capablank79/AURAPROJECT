import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/binder_model.dart';
import '../../../../core/models/item_model.dart';
import '../../../../core/services/media_storage_service.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../binder/data/repositories/binder_repository.dart';
import '../../../binder/providers/binder_providers.dart';
import '../../providers/catalog_providers.dart';

class PhysicalItemTab extends ConsumerStatefulWidget {
  const PhysicalItemTab({
    required this.binder,
    required this.positionIndex,
    super.key,
  });

  final BinderModel binder;
  final int positionIndex;

  @override
  ConsumerState<PhysicalItemTab> createState() => _PhysicalItemTabState();
}

class _PhysicalItemTabState extends ConsumerState<PhysicalItemTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _slabScoreController = TextEditingController(text: '10');
  final _slabCertController = TextEditingController();
  final _notesController = TextEditingController();

  String _condition = 'NM';
  String _tradeStatus = ItemTradeStatus.none;
  String? _slabGrader;
  bool _isFoil = false;
  XFile? _selectedImage;
  CompressedImageResult? _compressedPreview;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _slabScoreController.dispose();
    _slabCertController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final imageSubtitle = _compressedPreview == null
        ? l10n.imageReady
        : l10n.webpSavingsSummary(
            CompressedImageResult.formatSize(_compressedPreview!.originalBytes),
            CompressedImageResult.formatSize(
              _compressedPreview!.compressedBytes,
            ),
          );
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                tileColor: AuraColors.smokedCharcoal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(
                  Icons.image_outlined,
                  color: AuraColors.emeraldAura,
                ),
                title: Text(_selectedImage!.name),
                subtitle: Text(imageSubtitle),
                trailing: IconButton(
                  tooltip: l10n.removeImageButton,
                  onPressed: () => setState(() {
                    _selectedImage = null;
                    _compressedPreview = null;
                  }),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(l10n.galleryButton),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(l10n.cameraButton),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.itemNameLabel,
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _typeController,
                  decoration: InputDecoration(
                    labelText: l10n.itemTypeLabel,
                    hintText: l10n.itemTypeHint,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _slabGrader,
                  isExpanded: true,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: l10n.slabGraderLabel,
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l10n.slabNoneOption),
                    ),
                    const DropdownMenuItem(value: 'PSA', child: Text('PSA')),
                    const DropdownMenuItem(value: 'BGS', child: Text('BGS')),
                    const DropdownMenuItem(value: 'CGC', child: Text('CGC')),
                  ],
                  onChanged: (value) => setState(() => _slabGrader = value),
                ),
              ),
            ],
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
                      isDense: true,
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
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _condition,
                  isExpanded: true,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: l10n.conditionLabel,
                    isDense: true,
                  ),
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
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _tradeStatus,
                  isExpanded: true,
                  isDense: true,
                  decoration: InputDecoration(
                    labelText: l10n.tradeStatusLabel,
                    isDense: true,
                  ),
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
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.estimatedPriceLabel,
                    prefixText: '\$ ',
                    isDense: true,
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
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.notesLabel,
              isDense: true,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(l10n.foilLabel),
            value: _isFoil,
            onChanged: (value) => setState(() => _isFoil = value),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.saveItemButton),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    try {
      final image = await ref
          .read(imagePickerProvider)
          .pickImage(source: source, imageQuality: 100);
      if (image == null || !mounted) {
        return;
      }
      setState(() {
        _selectedImage = image;
        _compressedPreview = null;
      });
      try {
        final stats = await ref
            .read(imageCompressorProvider)
            .compressToWebpWithStats(image.path);
        if (mounted) {
          setState(() => _compressedPreview = stats);
        }
      } on ImageCompressionException {
        // Reintenta al guardar.
      }
      if (_nameController.text.trim().isEmpty) {
        final suggested = await ref
            .read(cardTextExtractorProvider)
            .extractSuggestedTitle(image.path);
        if (mounted &&
            suggested != null &&
            suggested.isNotEmpty &&
            _nameController.text.trim().isEmpty) {
          setState(() => _nameController.text = suggested);
        }
      }
    } on PlatformException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.imagePermissionError)));
      }
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_nameController.text.trim().isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.physicalFormRequired)));
      return;
    }
    setState(() => _saving = true);
    try {
      final compressedBytes =
          _compressedPreview?.bytes ??
          await ref
              .read(imageCompressorProvider)
              .compressToWebp(_selectedImage!.path);
      final imageUrl = await ref
          .read(mediaStorageServiceProvider)
          .storeWebp(
            bytes: compressedBytes,
            fileName: _selectedImage!.name.replaceFirst(
              RegExp(r'\.[^.]+$'),
              '',
            ),
          );
      final profile = await ref.read(activeProfileProvider.future);
      final customType = _typeController.text.trim();
      final baseItem = ItemModel(
        id: 'upload-${DateTime.now().microsecondsSinceEpoch}',
        binderId: widget.binder.id,
        userId: profile.id,
        collectionCode: widget.binder.collectionCode,
        sourceType: 'user_upload',
        name: _nameController.text.trim(),
        imageUrl: imageUrl,
        isFoil: _isFoil,
        condition: _condition,
        estimatedPrice: double.tryParse(
          _priceController.text.trim().replaceAll(',', '.'),
        ),
        positionIndex: widget.positionIndex,
        metadata: {
          'family': widget.binder.family,
          if (customType.isNotEmpty) 'type': customType,
        },
        notes: _notesController.text.trim(),
        createdAt: DateTime.now().toUtc(),
      ).withVaultMetadata(
        verificationOrigin: ItemVerificationOrigin.photoWebp,
        tradeStatus: _tradeStatus,
        slabGrader: _slabGrader,
        slabScore: _slabGrader != null ? _slabScoreController.text : null,
        slabCert: _slabGrader != null ? _slabCertController.text : null,
        purchaseCost: double.tryParse(
          _costController.text.trim().replaceAll(',', '.'),
        ),
      );
      await ref.read(binderRepositoryProvider).addItem(baseItem);
      ref.invalidate(binderItemsProvider(widget.binder.id));
      if (mounted) {
        await Navigator.of(context).maybePop();
      }
    } on ItemPositionException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.pocketOccupiedError)));
      }
    } on BinderCapacityException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.binderFullButton)));
      }
    } on ImageCompressionException {
      _showImageError();
    } on MediaStorageException {
      _showImageError();
    } on BinderRepositoryException {
      _showImageError();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showImageError() {
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.imageCompressionError)));
    }
  }
}
