import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/collections/collection_l10n.dart';
import '../../../core/collections/collection_registry.dart';
import '../../../core/models/binder_model.dart';
import '../../../core/models/item_model.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/media_storage_service.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../core/utils/image_compressor.dart';
import '../../../core/widgets/aura_sigil_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../binder/data/repositories/binder_repository.dart';
import '../../binder/providers/binder_providers.dart';
import '../data/catalog_repository.dart';
import '../data/debounced_search.dart';
import '../providers/catalog_providers.dart';
import 'card_scanner_screen.dart';
import 'widgets/confirm_card_dialog.dart';

enum _AddMode { search, scanner, photo }

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({
    required this.binderId,
    required this.positionIndex,
    super.key,
  });

  final String binderId;
  final int positionIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final binderAsync = ref.watch(binderProvider(binderId));

    return binderAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.addItemButton)),
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.addItemButton)),
        body: SafeArea(
          child: Center(
            child: FilledButton.tonal(
              onPressed: () => ref.invalidate(binderProvider(binderId)),
              child: Text(l10n.retryButton),
            ),
          ),
        ),
      ),
      data: (binder) {
        if (binder == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.addItemButton)),
            body: SafeArea(child: Center(child: Text(l10n.unavailableBinder))),
          );
        }
        return _CatalogBody(
          key: ValueKey('${binder.id}-$positionIndex'),
          binder: binder,
          positionIndex: positionIndex,
        );
      },
    );
  }
}

class _CatalogBody extends ConsumerStatefulWidget {
  const _CatalogBody({
    required this.binder,
    required this.positionIndex,
    super.key,
  });

  final BinderModel binder;
  final int positionIndex;

  @override
  ConsumerState<_CatalogBody> createState() => _CatalogBodyState();
}

class _CatalogBodyState extends ConsumerState<_CatalogBody> {
  late final CollectionSpec _spec;
  late _AddMode _mode;
  String? _scannedQuery;

  @override
  void initState() {
    super.initState();
    _spec = CollectionRegistry.byCode(widget.binder.collectionCode);
    _mode = _spec.supportsApiSearch ? _AddMode.search : _AddMode.photo;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final collectionLabel = CollectionL10n.binderCollectionLabel(
      l10n,
      widget.binder,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addToPocketTitle(widget.positionIndex + 1)),
      ),
      body: AuraBackdrop(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _LockedCollectionBanner(
                  spec: _spec,
                  collectionLabel: collectionLabel,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeTile(
                        icon: Icons.search,
                        label: l10n.modeSearchLabel,
                        selected: _mode == _AddMode.search,
                        enabled: _spec.supportsApiSearch,
                        onTap: () => _selectMode(_AddMode.search, l10n),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeTile(
                        icon: Icons.document_scanner_outlined,
                        label: l10n.modeScanLabel,
                        selected: _mode == _AddMode.scanner,
                        enabled: _spec.supportsCardScanner,
                        onTap: () => _selectMode(_AddMode.scanner, l10n),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeTile(
                        icon: Icons.camera_alt_outlined,
                        label: l10n.modePhotoLabel,
                        selected: _mode == _AddMode.photo,
                        enabled: _spec.allowsManualPhoto,
                        onTap: () => _selectMode(_AddMode.photo, l10n),
                      ),
                    ),
                  ],
                ),
              ),
              if (!_spec.supportsApiSearch)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                  child: Text(
                    l10n.noCatalogApiNotice(collectionLabel),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AuraColors.mutedText,
                    ),
                  ),
                ),
              Expanded(
                child: switch (_mode) {
                  _AddMode.search => CardSearchTab(
                    key: ValueKey('search-$_scannedQuery'),
                    binder: widget.binder,
                    spec: _spec,
                    positionIndex: widget.positionIndex,
                    initialQuery: _scannedQuery,
                  ),
                  _AddMode.scanner => _CardScannerMode(
                    collectionLabel: collectionLabel,
                    provider: _spec.catalogProvider,
                    onDetectedTitle: (title) {
                      setState(() {
                        _scannedQuery = title;
                        _mode = _AddMode.search;
                      });
                    },
                    onDetectedCard: (card) async {
                      final navigator = Navigator.of(context);
                      final selection = await showConfirmCardDialog(
                        context,
                        result: card,
                      );
                      if (selection == null || !mounted) {
                        return;
                      }
                      final profile = await ref
                          .read(activeProfileProvider.future);
                      await ref
                          .read(binderRepositoryProvider)
                          .addItem(
                            card
                                .toItem(
                                  binderId: widget.binder.id,
                                  userId: profile.id,
                                  positionIndex: widget.positionIndex,
                                  condition: selection.condition,
                                  isFoil: selection.isFoil,
                                )
                                .copyWith(
                                  estimatedPrice: selection.estimatedPrice,
                                ),
                          );
                      ref.invalidate(binderItemsProvider(widget.binder.id));
                      if (mounted) {
                        navigator.pop(true);
                      }
                    },
                  ),
                  _AddMode.photo => PhysicalItemTab(
                    binder: widget.binder,
                    positionIndex: widget.positionIndex,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectMode(_AddMode nextMode, AppLocalizations l10n) {
    final allowed = switch (nextMode) {
      _AddMode.search => _spec.supportsApiSearch,
      _AddMode.scanner => _spec.supportsCardScanner,
      _AddMode.photo => _spec.allowsManualPhoto,
    };
    if (!allowed) {
      final label = CollectionL10n.binderCollectionLabel(l10n, widget.binder);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.noCatalogApiNotice(label))));
      return;
    }
    setState(() => _mode = nextMode);
  }
}

class _LockedCollectionBanner extends StatelessWidget {
  const _LockedCollectionBanner({
    required this.spec,
    required this.collectionLabel,
  });

  final CollectionSpec spec;
  final String collectionLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AuraColors.smokedCharcoal.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AuraColors.champagneGold.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: spec.accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              spec.monogram,
              style: TextStyle(
                color: spec.accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              collectionLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Icon(Icons.lock_outline, size: 15, color: AuraColors.mutedText),
          const SizedBox(width: 4),
          Text(
            l10n.lockedCollectionBadge,
            style: const TextStyle(fontSize: 11, color: AuraColors.mutedText),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.38,
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: selected,
        label: label,
        child: Material(
          color: selected
              ? AuraColors.champagneGold.withValues(alpha: 0.14)
              : AuraColors.smokedCharcoal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: selected
                  ? AuraColors.champagneGold
                  : AuraColors.champagneGold.withValues(alpha: 0.16),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: selected
                        ? AuraColors.champagneGold
                        : AuraColors.creamText,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AuraColors.champagneGold
                          : AuraColors.creamText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardSearchTab extends ConsumerStatefulWidget {
  const CardSearchTab({
    required this.binder,
    required this.spec,
    required this.positionIndex,
    this.initialQuery,
    super.key,
  });

  final BinderModel binder;
  final CollectionSpec spec;
  final int positionIndex;
  final String? initialQuery;

  @override
  ConsumerState<CardSearchTab> createState() => _CardSearchTabState();
}

class _CardSearchTabState extends ConsumerState<CardSearchTab> {
  late final TextEditingController _queryController;
  final _search = DebouncedSearch<List<CatalogResult>>();
  List<CatalogResult> _results = const [];
  CatalogErrorType? _error;
  bool _loading = false;
  String? _addingExternalId;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    if (_queryController.text.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _queueSearch());
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _search.dispose();
    super.dispose();
  }

  void _queueSearch() {
    final provider = widget.spec.catalogProvider;
    final query = _queryController.text.trim();
    _search.cancel();
    if (provider == null || query.isEmpty) {
      setState(() {
        _results = const [];
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final locale = Localizations.localeOf(context).languageCode;
    _search
        .run(
          () => ref
              .read(catalogRepositoryProvider)
              .search(provider: provider, query: query, languageCode: locale),
        )
        .then((results) {
          if (results != null && mounted) {
            setState(() {
              _results = results;
              _error = null;
              _loading = false;
            });
          }
        })
        .onError<CatalogRepositoryException>((error, _) {
          if (mounted) {
            setState(() {
              _error = error.type;
              _loading = false;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final collectionLabel = CollectionL10n.binderCollectionLabel(
      l10n,
      widget.binder,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: TextField(
            controller: _queryController,
            onChanged: (_) => _queueSearch(),
            decoration: InputDecoration(
              labelText: l10n.searchCardLabel,
              hintText: l10n.searchInCollectionHint(collectionLabel),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      tooltip: l10n.modeScanLabel,
                      icon: const Icon(Icons.document_scanner_outlined),
                      onPressed: () async {
                        final scanned = await Navigator.of(context).push<Object?>(
                          MaterialPageRoute(
                            builder: (_) => CardScannerScreen(
                              collectionLabel: collectionLabel,
                              provider: widget.spec.catalogProvider,
                            ),
                          ),
                        );
                        if (!mounted) {
                          return;
                        }
                        if (scanned is CatalogResult) {
                          await _addResult(scanned);
                        } else if (scanned is String && scanned.isNotEmpty) {
                          _queryController.text = scanned;
                          _queueSearch();
                        }
                      },
                    ),
            ),
          ),
        ),
        Expanded(child: _buildResults(context, collectionLabel)),
      ],
    );
  }

  Widget _buildResults(BuildContext context, String collectionLabel) {
    final l10n = AppLocalizations.of(context);
    if (_error != null) {
      final message = switch (_error!) {
        CatalogErrorType.offline => l10n.catalogOffline,
        CatalogErrorType.rateLimited => l10n.catalogRateLimited,
        CatalogErrorType.unavailable => l10n.catalogUnavailable,
      };
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(message, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _queueSearch,
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            _queryController.text.isEmpty
                ? l10n.onlyCollectionResultsNotice(collectionLabel)
                : l10n.noResults,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AuraColors.mutedText),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final result = _results[index];
        final isAdding = _addingExternalId == result.externalId;
        return Card(
          child: ListTile(
            onTap: _addingExternalId != null ? null : () => _addResult(result),
            contentPadding: const EdgeInsets.all(12),
            leading: SizedBox(
              width: 48,
              child: Image.network(
                result.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.style, color: AuraColors.champagneGold),
              ),
            ),
            title: Text(result.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.metadata['expansion']?.toString() ?? collectionLabel,
                ),
                if (result.estimatedPrice != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    ref.watch(formatUsdProvider)(result.estimatedPrice!),
                    style: const TextStyle(
                      color: AuraColors.solarGold,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              tooltip: l10n.addItemButton,
              onPressed: _addingExternalId != null
                  ? null
                  : () => _addResult(result),
              icon: isAdding
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.add_circle_outline,
                      color: AuraColors.champagneGold,
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addResult(CatalogResult result) async {
    final selection = await showConfirmCardDialog(context, result: result);
    if (selection == null || !mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() => _addingExternalId = result.externalId);
    try {
      final profile = await ref.read(activeProfileProvider.future);
      await ref
          .read(binderRepositoryProvider)
          .addItem(
            result
                .toItem(
                  binderId: widget.binder.id,
                  userId: profile.id,
                  positionIndex: widget.positionIndex,
                  condition: selection.condition,
                  isFoil: selection.isFoil,
                )
                .copyWith(estimatedPrice: selection.estimatedPrice),
          );
      ref.invalidate(binderItemsProvider(widget.binder.id));
      if (mounted) {
        await Navigator.of(context).maybePop();
      }
    } on CollectionMismatchException catch (error) {
      if (mounted) {
        final expectedLabel = CollectionL10n.collectionName(
          l10n,
          error.expectedCollectionCode,
          customName: widget.binder.customCollectionName,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.collectionMismatchError(expectedLabel))),
        );
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
    } on BinderRepositoryException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    } finally {
      if (mounted) {
        setState(() => _addingExternalId = null);
      }
    }
  }
}

class _CardScannerMode extends ConsumerStatefulWidget {
  const _CardScannerMode({
    required this.collectionLabel,
    required this.onDetectedTitle,
    required this.onDetectedCard,
    this.provider,
  });

  final String collectionLabel;
  final CatalogProvider? provider;
  final ValueChanged<String> onDetectedTitle;
  final ValueChanged<CatalogResult> onDetectedCard;

  @override
  ConsumerState<_CardScannerMode> createState() => _CardScannerModeState();
}

class _CardScannerModeState extends ConsumerState<_CardScannerMode> {
  bool _scanning = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 240,
            decoration: BoxDecoration(
              color: AuraColors.smokedCharcoal,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AuraColors.manaCyan, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AuraColors.manaCyan.withValues(alpha: 0.25),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.document_scanner_outlined,
                size: 56,
                color: AuraColors.manaCyan,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.scannerHeadline(widget.collectionLabel),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scannerSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AuraColors.mutedText),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _scanning ? null : _openLiveScanner,
            icon: const Icon(Icons.document_scanner_outlined),
            label: Text(l10n.openScannerCameraButton),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _scanning ? null : () => _scan(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(l10n.galleryButton),
          ),
        ],
      ),
    );
  }

  Future<void> _openLiveScanner() async {
    final scanned = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (_) => CardScannerScreen(
          collectionLabel: widget.collectionLabel,
          provider: widget.provider,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    if (scanned is CatalogResult) {
      widget.onDetectedCard(scanned);
    } else if (scanned is String && scanned.isNotEmpty) {
      widget.onDetectedTitle(scanned);
    }
  }

  Future<void> _scan(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _scanning = true);
    try {
      final image = await ref
          .read(imagePickerProvider)
          .pickImage(source: source, imageQuality: 95);
      if (image == null || !mounted) {
        return;
      }
      final title = await ref
          .read(cardTextExtractorProvider)
          .extractSuggestedTitle(image.path);
      if (!mounted) {
        return;
      }
      if (title != null && title.isNotEmpty) {
        widget.onDetectedTitle(title);
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
        setState(() => _scanning = false);
      }
    }
  }
}

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
  final _notesController = TextEditingController();
  String _condition = 'NM';
  bool _isFoil = false;
  XFile? _selectedImage;
  CompressedImageResult? _compressedPreview;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _priceController.dispose();
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
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l10n.itemNameLabel),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _typeController,
            decoration: InputDecoration(
              labelText: l10n.itemTypeLabel,
              hintText: l10n.itemTypeHint,
            ),
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 14),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.estimatedPriceLabel,
              prefixText: '\$ ',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.notesLabel),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.foilLabel),
            value: _isFoil,
            onChanged: (value) => setState(() => _isFoil = value),
          ),
          const SizedBox(height: 14),
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
        // Si la vista previa no puede comprimirse aún, se reintentará al guardar.
      }

      // Mejora aprobada: autocompletar título con OCR local en el dispositivo
      // incluso para colecciones sin API pública (como Naruto).
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
      await ref
          .read(binderRepositoryProvider)
          .addItem(
            ItemModel(
              id: 'upload-${DateTime.now().microsecondsSinceEpoch}',
              binderId: widget.binder.id,
              userId: profile.id,
              collectionCode: widget.binder.collectionCode,
              sourceType: 'user_upload',
              name: _nameController.text.trim(),
              imageUrl: imageUrl,
              isFoil: _isFoil,
              condition: _condition,
              estimatedPrice: double.tryParse(_priceController.text.trim()),
              positionIndex: widget.positionIndex,
              metadata: {
                'family': widget.binder.family,
                if (customType.isNotEmpty) 'type': customType,
              },
              notes: _notesController.text.trim(),
              createdAt: DateTime.now().toUtc(),
            ),
          );
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
