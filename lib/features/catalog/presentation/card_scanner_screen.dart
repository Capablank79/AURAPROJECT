import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/collections/collection_registry.dart';
import '../../../core/services/ml_kit_service.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../core/utils/card_art_hasher.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/catalog_repository.dart';
import '../providers/catalog_providers.dart';
import 'widgets/scanner_ar_hud.dart';

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
  bool _initializing = true;
  bool _processing = false;
  bool _streaming = false;
  bool _cameraUnavailable = false;

  DateTime _lastStreamCheck = DateTime.fromMillisecondsSinceEpoch(0);
  String? _pendingStableTitle;
  int _stabilityHits = 0;

  List<CatalogResult> _detectedCandidates = const [];
  CardScanMatch? _detectedMatch;
  String? _proofImageUrl;
  int? _capturedArtHash;

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
      _stopStreamSafely();
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
      final formatGroup = defaultTargetPlatform == TargetPlatform.iOS
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.nv21;
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: formatGroup,
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
      await _startOpticalStream();
    } on CameraException {
      _markCameraUnavailable();
    } on MissingPluginException {
      _markCameraUnavailable();
    } on PlatformException {
      _markCameraUnavailable();
    }
  }

  void _markCameraUnavailable() {
    if (mounted) {
      setState(() {
        _initializing = false;
        _cameraUnavailable = true;
      });
    }
  }

  Future<void> _startOpticalStream() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _streaming ||
        widget.provider == null) {
      return;
    }
    try {
      await controller.startImageStream(_onCameraFrame);
      if (mounted) {
        setState(() => _streaming = true);
      }
    } catch (_) {
      // Si el emulador no soporta startImageStream, queda activo el disparo manual.
    }
  }

  Future<void> _stopStreamSafely() async {
    final controller = _controller;
    if (controller != null && _streaming) {
      try {
        await controller.stopImageStream();
      } catch (_) {}
    }
    _streaming = false;
  }

  Future<void> _onCameraFrame(CameraImage image) async {
    if (!mounted || _processing || _detectedCandidates.isNotEmpty) {
      return;
    }
    final now = DateTime.now();
    if (now.difference(_lastStreamCheck).inMilliseconds < 450) {
      return;
    }
    _lastStreamCheck = now;

    final inputImage = _buildInputImage(image);
    if (inputImage == null) {
      return;
    }
    _processing = true;
    try {
      final dHash = image.planes.isNotEmpty
          ? CardArtHasher.computeLuminanceDHash(
              yPlane: image.planes.first.bytes,
              width: image.width,
              height: image.height,
              bytesPerRow: image.planes.first.bytesPerRow,
            )
          : 0;
      final lang = Localizations.localeOf(context).languageCode;
      final match = await ref
          .read(mlKitServiceProvider)
          .extractCardDataFromInputImage(
            inputImage,
            frameSize: Size(image.width.toDouble(), image.height.toDouble()),
            languageCode: lang,
          );
      if (!mounted || match.title.isEmpty) {
        return;
      }

      // Estabilidad tipo MagicFrame: confirma inmediato si leyó Set/Número,
      // o al repetir el mismo título en 2 frames consecutivos.
      final normalized = match.title.toLowerCase();
      final highConfidence =
          match.collectorNumber != null || match.setCode != null;
      if (highConfidence || _pendingStableTitle == normalized) {
        _stabilityHits++;
      } else {
        _pendingStableTitle = normalized;
        _stabilityHits = 1;
      }
      if (!highConfidence && _stabilityHits < 2) {
        return;
      }

      await _resolveCatalogCandidates(
        match,
        artHash: dHash,
        silent: true,
      );
    } finally {
      _processing = false;
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    final controller = _controller;
    if (controller == null || image.planes.isEmpty) {
      return null;
    }
    final rotation =
        InputImageRotationValue.fromRawValue(
          controller.description.sensorOrientation,
        ) ??
        InputImageRotation.rotation0deg;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      return null;
    }
    final buffer = WriteBuffer();
    for (final plane in image.planes) {
      buffer.putUint8List(plane.bytes);
    }
    return InputImage.fromBytes(
      bytes: buffer.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    final hasPreview = controller != null && controller.value.isInitialized;
    final locked = _detectedCandidates.isNotEmpty && _detectedMatch != null;

    return Scaffold(
      backgroundColor: AuraColors.obsidianVoid,
      appBar: AppBar(title: Text(l10n.scannerHeadline(widget.collectionLabel))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
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
                    ScannerZonalReticle(locked: locked, streaming: _streaming),
                  ],
                ),
              ),
            ),
            if (locked)
              ScannerDetectedArHud(
                candidates: _detectedCandidates,
                scanMatch: _detectedMatch!,
                hasProofPhoto: _proofImageUrl != null,
                onConfirm: _confirmSelection,
                onRescan: () async {
                  setState(() {
                    _detectedCandidates = const [];
                    _detectedMatch = null;
                    _proofImageUrl = null;
                    _pendingStableTitle = null;
                    _stabilityHits = 0;
                  });
                  await _startOpticalStream();
                },
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
                    const SizedBox(height: 12),
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
      await _stopStreamSafely();
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
    final locale = Localizations.localeOf(context).languageCode;
    var match = await ref
        .read(mlKitServiceProvider)
        .extractCardDataFromImage(path, languageCode: locale);
    if (match.title.isEmpty && !silent) {
      final fallback = await ref
          .read(cardTextExtractorProvider)
          .extractSuggestedTitle(path);
      if (fallback != null && fallback.isNotEmpty) {
        match = CardScanMatch(title: fallback);
      }
    }
    if (!mounted) {
      return;
    }
    if (match.title.isEmpty) {
      if (!silent) {
        _showNoTextMessage();
      }
      return;
    }
    final savedProof = await _storeProofSnapshot(path);
    await _resolveCatalogCandidates(
      match,
      proofUrl: savedProof,
      silent: silent,
    );
  }

  Future<String?> _storeProofSnapshot(String path) async {
    try {
      final webp = await ref.read(imageCompressorProvider).compressToWebp(path);
      return await ref
          .read(mediaStorageServiceProvider)
          .storeWebp(
            bytes: webp,
            fileName: 'scan_proof_${DateTime.now().millisecondsSinceEpoch}',
          );
    } catch (_) {
      return null;
    }
  }

  Future<void> _resolveCatalogCandidates(
    CardScanMatch match, {
    int? artHash,
    String? proofUrl,
    required bool silent,
  }) async {
    final provider = widget.provider;
    if (provider != null) {
      try {
        final locale = Localizations.localeOf(context).languageCode;
        final results = await ref
            .read(catalogRepositoryProvider)
            .search(provider: provider, query: match.title, languageCode: locale);
        if (mounted && results.isNotEmpty) {
          await _stopStreamSafely();
          HapticFeedback.mediumImpact();
          final ranked = CardArtHasher.rankCandidates(
            results,
            match,
            capturedArtHash: artHash,
          );
          setState(() {
            _detectedCandidates = ranked;
            _detectedMatch = match;
            _capturedArtHash = artHash;
            _proofImageUrl = proofUrl;
          });
          return;
        }
      } catch (_) {
        if (silent) {
          return;
        }
      }
    }
    if (!silent && mounted) {
      Navigator.of(context).pop(match.title);
    }
  }

  void _confirmSelection(CatalogResult selected, bool isFoil) {
    final match = _detectedMatch;
    final enrichedMeta = <String, dynamic>{
      ...selected.metadata,
      'foil_hint': isFoil,
      if (match != null) 'centering_ratio': match.centeringRatio,
      if (match != null) 'estimated_grade': match.estimatedGrade,
      if (_capturedArtHash != null && _capturedArtHash != 0)
        'art_dhash': _capturedArtHash,
      if (_proofImageUrl != null) 'proof_image_url': _proofImageUrl,
    };
    final enriched = CatalogResult(
      collectionCode: selected.collectionCode,
      sourceType: selected.sourceType,
      externalId: selected.externalId,
      name: selected.name,
      imageUrl: selected.imageUrl,
      estimatedPrice: isFoil && selected.estimatedPrice != null
          ? double.parse((selected.estimatedPrice! * 1.35).toStringAsFixed(2))
          : selected.estimatedPrice,
      metadata: enrichedMeta,
    );
    Navigator.of(context).pop(enriched);
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
