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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reducedMotion = MediaQuery.disableAnimationsOf(context);
      if (mounted && widget.isFoil && !reducedMotion) {
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
    if (!widget.isFoil || MediaQuery.disableAnimationsOf(context)) {
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
    final animated = widget.isFoil && !reducedMotion;
    final x = _previewGlow ? 0.10 : _x;
    final y = _previewGlow ? -0.08 : _y;

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
                child: AspectRatio(
                  aspectRatio: 0.714,
                  child: Semantics(
                    image: true,
                    label: l10n.itemImageDescription(widget.item.name),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: widget.item.imageUrl.startsWith('mock://')
                              ? AuraCardCrestPlaceholder(name: widget.item.name)
                              : Image.network(
                                  widget.item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      AuraCardCrestPlaceholder(
                                        name: widget.item.name,
                                      ),
                                ),
                        ),
                        if (widget.isFoil)
                          IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
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
                                    AuraColors.manaCyan.withValues(alpha: 0.14),
                                    AuraColors.solarGold.withValues(
                                      alpha: 0.34,
                                    ),
                                    AuraColors.psychicMagenta.withValues(
                                      alpha: 0.22,
                                    ),
                                    AuraColors.emeraldAura.withValues(
                                      alpha: 0.16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isFoil) ...[
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
