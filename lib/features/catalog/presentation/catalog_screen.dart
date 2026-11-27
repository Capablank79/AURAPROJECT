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
import '../../../core/theme/aura_colors.dart';
import '../../../core/widgets/aura_sigil_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../binder/data/repositories/binder_repository.dart';
import '../../binder/providers/binder_providers.dart';
import '../data/catalog_repository.dart';
import '../data/debounced_search.dart';
import '../providers/catalog_providers.dart';
import 'card_scanner_screen.dart';
import 'widgets/batch_scanner_sheet.dart';
import 'widgets/confirm_card_dialog.dart';
import 'widgets/physical_item_tab.dart';

export 'widgets/physical_item_tab.dart';

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
                    binder: widget.binder,
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
                        fromApiSearch: false,
                      );
                      if (selection == null || !mounted) {
                        return;
                      }
                      final profile = await ref.read(
                        activeProfileProvider.future,
                      );
                      final item = card
                          .toItem(
                            binderId: widget.binder.id,
                            userId: profile.id,
                            positionIndex: widget.positionIndex,
                            condition: selection.condition,
                            isFoil: selection.isFoil,
                          )
                          .copyWith(estimatedPrice: selection.estimatedPrice)
                          .withVaultMetadata(
                            verificationOrigin: ItemVerificationOrigin.scanned,
                            tradeStatus: selection.tradeStatus,
                            slabGrader: selection.slabGrader,
                            slabScore: selection.slabScore,
                            slabCert: selection.slabCert,
                            purchaseCost: selection.purchaseCost,
                          );
                      await ref.read(binderRepositoryProvider).addItem(item);
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
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AuraColors.psychicMagenta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AuraColors.psychicMagenta.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_outlined,
                  size: 16,
                  color: AuraColors.psychicMagenta,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${l10n.apiPolicyBannerTitle}: ${l10n.apiPolicyBannerBody}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AuraColors.creamText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
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
                        final scanned = await Navigator.of(context)
                            .push<Object?>(
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
                          await _addResult(scanned, fromApiSearch: false);
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
            onTap: _addingExternalId != null
                ? null
                : () => _addResult(result, fromApiSearch: true),
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
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (result.estimatedPrice != null)
                      Text(
                        ref.watch(formatUsdProvider)(result.estimatedPrice!),
                        style: const TextStyle(
                          color: AuraColors.solarGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      l10n.apiUnverifiedBadge,
                      style: const TextStyle(
                        color: AuraColors.psychicMagenta,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              tooltip: l10n.addItemButton,
              onPressed: _addingExternalId != null
                  ? null
                  : () => _addResult(result, fromApiSearch: true),
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

  Future<void> _addResult(
    CatalogResult result, {
    required bool fromApiSearch,
  }) async {
    final selection = await showConfirmCardDialog(
      context,
      result: result,
      fromApiSearch: fromApiSearch,
    );
    if (selection == null || !mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() => _addingExternalId = result.externalId);
    try {
      final profile = await ref.read(activeProfileProvider.future);
      final item = result
          .toItem(
            binderId: widget.binder.id,
            userId: profile.id,
            positionIndex: widget.positionIndex,
            condition: selection.condition,
            isFoil: selection.isFoil,
          )
          .copyWith(estimatedPrice: selection.estimatedPrice)
          .withVaultMetadata(
            verificationOrigin: fromApiSearch
                ? ItemVerificationOrigin.apiUnverified
                : ItemVerificationOrigin.scanned,
            tradeStatus: selection.tradeStatus,
            slabGrader: selection.slabGrader,
            slabScore: selection.slabScore,
            slabCert: selection.slabCert,
            purchaseCost: selection.purchaseCost,
          );
      await ref.read(binderRepositoryProvider).addItem(item);
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
    required this.binder,
    required this.collectionLabel,
    required this.onDetectedTitle,
    required this.onDetectedCard,
    this.provider,
  });

  final BinderModel binder;
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 215,
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
                size: 52,
                color: AuraColors.manaCyan,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.scannerHeadline(widget.collectionLabel),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.scannerSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AuraColors.mutedText),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _scanning ? null : _openLiveScanner,
            icon: const Icon(Icons.document_scanner_outlined),
            label: Text(l10n.openScannerCameraButton),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _scanning ? null : _openBatchScanner,
            icon: const Icon(Icons.filter_none_outlined),
            label: Text(l10n.batchScannerButton),
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

  Future<void> _openBatchScanner() async {
    final added = await showBatchScannerSheet(
      context,
      binder: widget.binder,
      collectionLabel: widget.collectionLabel,
      provider: widget.provider,
    );
    if (added > 0 && mounted) {
      Navigator.of(context).maybePop(true);
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
