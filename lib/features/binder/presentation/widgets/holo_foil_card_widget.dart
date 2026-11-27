import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/models/item_model.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../core/widgets/aura_sigil_logo.dart';
import '../../../../l10n/generated/app_localizations.dart';

typedef HoloFoilCardWidget = HolographicItemCard;

class HolographicItemCard extends StatefulWidget {
  const HolographicItemCard({
    required this.item,
    required this.isFoil,
    super.key,
  });

  final ItemModel item;
  final bool isFoil;

  @override
  State<HolographicItemCard> createState() => _HolographicItemCardState();
}

class _HolographicItemCardState extends State<HolographicItemCard> {
  StreamSubscription<GyroscopeEvent>? _subscription;
  double _x = 0;
  double _y = 0;
  bool _sensorAvailable = false;
  bool _previewGlow = false;
  bool _showProofPhoto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reducedMotion = MediaQuery.disableAnimationsOf(context);
      if (mounted &&
          widget.isFoil &&
          widget.item.isPhysicallyVerified &&
          !reducedMotion) {
        _listenToSensor();
      }
    });
  }

  void _listenToSensor() {
    try {
      _subscription = gyroscopeEventStream().listen(
        (event) {
          if (!mounted) {
            return;
          }
          setState(() {
            _sensorAvailable = true;
            _x = (event.y / 4).clamp(-0.14, 0.14);
            _y = (-event.x / 4).clamp(-0.14, 0.14);
          });
        },
        onError: (_) {
          if (mounted) {
            setState(() => _sensorAvailable = false);
          }
        },
      );
    } on MissingPluginException {
      _sensorAvailable = false;
    } on PlatformException {
      _sensorAvailable = false;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isFoil ||
        !widget.item.isPhysicallyVerified ||
        MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    setState(() {
      _x = (_x - details.delta.dy * 0.004).clamp(-0.18, 0.18);
      _y = (_y + details.delta.dx * 0.004).clamp(-0.18, 0.18);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isFoil || MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    setState(() {
      _x = 0;
      _y = 0;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final verified = widget.item.isPhysicallyVerified;
    final showFoil = widget.isFoil && verified;
    final animated = showFoil && !reducedMotion;
    final x = _previewGlow ? 0.10 : _x;
    final y = _previewGlow ? -0.08 : _y;
    final proofUrl = widget.item.metadata['proof_image_url']?.toString();
    final activeUrl = (_showProofPhoto && proofUrl != null && proofUrl.isNotEmpty)
        ? proofUrl
        : widget.item.imageUrl;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          children: [
            GestureDetector(
              onPanUpdate: animated ? _onPanUpdate : null,
              onPanEnd: animated ? _onPanEnd : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(animated ? x : 0)
                  ..rotateY(animated ? y : 0),
                transformAlignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.item.hasSlab) _SlabCapsuleHeader(item: widget.item),
                    AspectRatio(
                      aspectRatio: 0.714,
                      child: Semantics(
                        image: true,
                        label: l10n.itemImageDescription(widget.item.name),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                  widget.item.hasSlab ? 4 : 20,
                                ),
                                bottom: const Radius.circular(20),
                              ),
                              child: activeUrl.startsWith('mock://')
                                  ? AuraCardCrestPlaceholder(
                                      name: widget.item.name,
                                    )
                                  : Image.network(
                                      activeUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          AuraCardCrestPlaceholder(
                                            name: widget.item.name,
                                          ),
                                    ),
                            ),
                            if (showFoil)
                              IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                        widget.item.hasSlab ? 4 : 20,
                                      ),
                                      bottom: const Radius.circular(20),
                                    ),
                                    border: Border.all(
                                      color: AuraColors.champagneLight,
                                      width: 2,
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment(
                                        (x * 4).clamp(-1.0, 1.0),
                                        (y * 4).clamp(-1.0, 1.0),
                                      ),
                                      end: Alignment(
                                        (-x * 4).clamp(-1.0, 1.0),
                                        (-y * 4).clamp(-1.0, 1.0),
                                      ),
                                      colors: [
                                        AuraColors.manaCyan.withValues(
                                          alpha: 0.16,
                                        ),
                                        AuraColors.solarGold.withValues(
                                          alpha: 0.34,
                                        ),
                                        AuraColors.psychicMagenta.withValues(
                                          alpha: 0.24,
                                        ),
                                        AuraColors.emeraldAura.withValues(
                                          alpha: 0.18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (showFoil)
                              IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                        widget.item.hasSlab ? 4 : 20,
                                      ),
                                      bottom: const Radius.circular(20),
                                    ),
                                    gradient: RadialGradient(
                                      center: Alignment(
                                        (-x * 5).clamp(-0.9, 0.9),
                                        (-y * 5).clamp(-0.9, 0.9),
                                      ),
                                      radius: 0.72,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.28),
                                        AuraColors.solarGold.withValues(
                                          alpha: 0.08,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (!verified)
                              Align(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 10,
                                  ),
                                  color: AuraColors.obsidianVoid.withValues(
                                    alpha: 0.88,
                                  ),
                                  child: Text(
                                    '☁️ ${l10n.apiReferenceWatermark}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AuraColors.psychicMagenta,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (proofUrl != null && proofUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.auto_awesome_outlined, size: 15),
                    label: Text(l10n.viewOfficialArtToggle),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.camera_alt_outlined, size: 15),
                    label: Text(l10n.viewProofPhotoToggle),
                  ),
                ],
                selected: {_showProofPhoto},
                onSelectionChanged: (v) =>
                    setState(() => _showProofPhoto = v.first),
              ),
            ],
            if (showFoil) ...[
              const SizedBox(height: 12),
              Text(
                _sensorAvailable
                    ? l10n.gyroscopeActive
                    : l10n.gyroscopeFallback,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AuraColors.mutedText),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _previewGlow = !_previewGlow),
                icon: Icon(
                  _previewGlow ? Icons.visibility_off : Icons.visibility,
                ),
                label: Text(
                  _previewGlow
                      ? l10n.staticViewButton
                      : l10n.previewShineButton,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SlabCapsuleHeader extends StatelessWidget {
  const _SlabCapsuleHeader({required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AuraColors.obsidianVoid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border.all(color: AuraColors.solarGold, width: 1.6),
      ),
      child: Row(
        children: [
          Text(
            item.slabGrader ?? '',
            style: const TextStyle(
              color: AuraColors.solarGold,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.slabCert != null ? '#${item.slabCert}' : 'CERTIFIED',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AuraColors.silverMuted,
                fontSize: 10,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AuraColors.solarGold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.slabScore ?? '10',
              style: const TextStyle(
                color: AuraColors.obsidianVoid,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
