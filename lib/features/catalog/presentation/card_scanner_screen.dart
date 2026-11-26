import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/collections/collection_registry.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/catalog_repository.dart';
import '../providers/catalog_providers.dart';

class CardScannerScreen extends ConsumerStatefulWidget {
  const CardScannerScreen({
    required this.collectionLabel,
    this.provider,
    super.key,
  });

  final String collectionLabel;
  final CatalogProvider? provider;

  @override
  ConsumerState<CardScannerScreen> createState() => _CardScannerScreenState();
}

class _CardScannerScreenState extends ConsumerState<CardScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Timer? _autoScanTimer;
  bool _initializing = true;
  bool _processing = false;
  bool _cameraUnavailable = false;
  CatalogResult? _detectedCard;
  String? _lastQueriedTitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _autoScanTimer?.cancel();
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _initializing = false;
            _cameraUnavailable = true;
          });
        }
        return;
      }
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
        _cameraUnavailable = false;
      });
      _startAutoScanLoop();
    } on CameraException {
      if (mounted) {
        setState(() {
          _initializing = false;
          _cameraUnavailable = true;
        });
      }
    } on MissingPluginException {
      if (mounted) {
        setState(() {
          _initializing = false;
          _cameraUnavailable = true;
        });
      }
    } on PlatformException {
      if (mounted) {
        setState(() {
          _initializing = false;
          _cameraUnavailable = true;
        });
      }
    }
  }

  void _startAutoScanLoop() {
    _autoScanTimer?.cancel();
    if (widget.provider == null) {
      return;
    }
    _autoScanTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (!mounted ||
          _processing ||
          _detectedCard != null ||
          _controller == null ||
          !_controller!.value.isInitialized) {
        return;
      }
      _capture(silent: true);
    });
  }

  @override
  void dispose() {
    _autoScanTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    final hasPreview = controller != null && controller.value.isInitialized;
    final detected = _detectedCard;

    return Scaffold(
      backgroundColor: AuraColors.obsidianVoid,
      appBar: AppBar(title: Text(l10n.scannerHeadline(widget.collectionLabel))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (hasPreview)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: CameraPreview(controller),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AuraColors.smokedCharcoal,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        alignment: Alignment.center,
                        child: _initializing
                            ? const CircularProgressIndicator()
                            : Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  _cameraUnavailable
                                      ? l10n.scannerCameraFallback
                                      : l10n.scannerSubtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AuraColors.mutedText,
                                  ),
                                ),
                              ),
                      ),
                    IgnorePointer(
                      child: AspectRatio(
                        aspectRatio: 0.714,
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: detected != null
                                  ? AuraColors.emeraldAura
                                  : AuraColors.solarGold,
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (detected != null)
              _DetectedCardBanner(
                card: detected,
                onAdd: () => Navigator.of(context).pop(detected),
                onRescan: () => setState(() {
                  _detectedCard = null;
                  _lastQueriedTitle = null;
                }),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.scannerGuideHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AuraColors.mutedText),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _processing || !hasPreview
                          ? null
                          : () => _capture(silent: false),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(l10n.captureCardButton),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _processing ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.galleryButton),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _capture({required bool silent}) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    setState(() => _processing = true);
    try {
      final file = await controller.takePicture();
      await _processImagePath(file.path, silent: silent);
    } on CameraException {
      if (!silent) {
        _showNoTextMessage();
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _processing = true);
    try {
      final image = await ref
          .read(imagePickerProvider)
          .pickImage(source: ImageSource.gallery, imageQuality: 95);
      if (image != null) {
        await _processImagePath(image.path, silent: false);
      }
    } on PlatformException {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.imagePermissionError)));
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  Future<void> _processImagePath(String path, {required bool silent}) async {
    final match = await ref
        .read(mlKitServiceProvider)
        .extractCardDataFromImage(path);
    var title = match.title;
    if (title.isEmpty && !silent) {
      title =
          await ref
              .read(cardTextExtractorProvider)
              .extractSuggestedTitle(path) ??
          '';
    }
    if (!mounted) {
      return;
    }
    if (title.isEmpty) {
      if (!silent) {
        _showNoTextMessage();
      }
      return;
    }

    final provider = widget.provider;
    if (provider != null && title != _lastQueriedTitle) {
      _lastQueriedTitle = title;
      try {
        final locale = Localizations.localeOf(context).languageCode;
        final results = await ref
            .read(catalogRepositoryProvider)
            .search(provider: provider, query: title, languageCode: locale);
        if (mounted && results.isNotEmpty) {
          final exact = _pickBestMatch(results, match.collectorNumber);
          setState(() => _detectedCard = exact);
          return;
        }
      } catch (_) {
        if (silent) {
          return;
        }
      }
    }

    if (!silent && mounted) {
      Navigator.of(context).pop(title);
    }
  }

  CatalogResult _pickBestMatch(
    List<CatalogResult> results,
    String? collectorNumber,
  ) {
    if (collectorNumber != null && collectorNumber.isNotEmpty) {
      final normalizedTarget = collectorNumber.replaceFirst(RegExp(r'^0+'), '');
      for (final item in results) {
        final rawNum = item.metadata['number']?.toString() ?? '';
        final normalizedItem = rawNum
            .split('/')
            .first
            .trim()
            .replaceFirst(RegExp(r'^0+'), '');
        if (normalizedItem == normalizedTarget) {
          return item;
        }
      }
    }
    return results.first;
  }

  void _showNoTextMessage() {
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.ocrNoTextDetected)));
  }
}

class _DetectedCardBanner extends ConsumerWidget {
  const _DetectedCardBanner({
    required this.card,
    required this.onAdd,
    required this.onRescan,
  });

  final CatalogResult card;
  final VoidCallback onAdd;
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatUsd = ref.watch(formatUsdProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AuraColors.smokedCharcoal,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AuraColors.solarGold, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 66,
                  child: Image.network(
                    card.imageUrl,
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
                      card.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (card.metadata['expansion'] != null)
                      Text(
                        card.metadata['expansion'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AuraColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    if (card.estimatedPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        formatUsd(card.estimatedPrice!),
                        style: const TextStyle(
                          color: AuraColors.solarGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRescan,
                  child: Text(l10n.retryButton),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addItemButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
