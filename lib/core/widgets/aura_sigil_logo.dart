import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/aura_colors.dart';

/// Isotipo geométrico dorado con cuernos y halo cromático oficial de AuraDeck.
class AuraSigilLogo extends StatelessWidget {
  const AuraSigilLogo({
    this.size = 96,
    this.showAura = true,
    this.semanticLabel,
    super.key,
  });

  final double size;
  final bool showAura;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final haloSize = size * 1.24;

    final logo = SizedBox(
      width: haloSize,
      height: haloSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showAura) ...[
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: reducedMotion ? 8 : 14,
                sigmaY: reducedMotion ? 8 : 14,
              ),
              child: Container(
                width: size * 1.04,
                height: size * 1.04,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    startAngle: 3.4,
                    colors: [
                      AuraColors.psychicMagenta.withValues(alpha: 0.45),
                      const Color(0xFFFF5A3C).withValues(alpha: 0.35),
                      AuraColors.solarGold.withValues(alpha: 0.42),
                      AuraColors.emeraldAura.withValues(alpha: 0.40),
                      AuraColors.manaCyan.withValues(alpha: 0.45),
                      AuraColors.arcaneViolet.withValues(alpha: 0.38),
                      AuraColors.psychicMagenta.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: size * 1.08,
              height: size * 1.08,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AuraColors.obsidianVoid,
              ),
            ),
            Container(
              width: size * 1.10,
              height: size * 1.10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AuraColors.champagneGold.withValues(alpha: 0.22),
                  width: 1.2,
                ),
              ),
            ),
          ],
          CustomPaint(
            size: Size(size, size * 1.08),
            painter: const AuraSigilPainter(),
          ),
        ],
      ),
    );

    if (semanticLabel == null) {
      return ExcludeSemantics(child: logo);
    }
    return Semantics(image: true, label: semanticLabel, child: logo);
  }
}

class AuraSigilPainter extends CustomPainter {
  const AuraSigilPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AuraColors.champagneLight,
        AuraColors.champagneGold,
        AuraColors.champagneDark,
      ],
    ).createShader(Offset.zero & size);

    final stroke = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.036).clamp(1.6, 4.2)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    final fineStroke = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.025).clamp(1.2, 3.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.miter;

    // 1. Cuernos curvos simétricos superiores (estilo toro místico)
    for (final dir in const [-1.0, 1.0]) {
      final horn = Path()
        ..moveTo(cx + dir * w * 0.14, h * 0.34)
        ..cubicTo(
          cx + dir * w * 0.34,
          h * 0.36,
          cx + dir * w * 0.48,
          h * 0.22,
          cx + dir * w * 0.42,
          h * 0.05,
        )
        ..cubicTo(
          cx + dir * w * 0.41,
          h * 0.19,
          cx + dir * w * 0.28,
          h * 0.28,
          cx + dir * w * 0.08,
          h * 0.27,
        );
      canvas.drawPath(horn, stroke);

      // Orejas geométricas laterales bajo los cuernos
      final ear = Path()
        ..moveTo(cx + dir * w * 0.25, h * 0.36)
        ..lineTo(cx + dir * w * 0.43, h * 0.47)
        ..lineTo(cx + dir * w * 0.26, h * 0.49);
      canvas.drawPath(ear, fineStroke);
    }

    // 2. Rombo maestro exterior
    final outerDiamond = Path()
      ..moveTo(cx, h * 0.12)
      ..lineTo(cx + w * 0.36, h * 0.54)
      ..lineTo(cx, h * 0.95)
      ..lineTo(cx - w * 0.36, h * 0.54)
      ..close();
    canvas.drawPath(outerDiamond, stroke);

    // 3. Chevrones concéntricos superiores
    for (final offset in const [0.20, 0.28]) {
      final chevron = Path()
        ..moveTo(cx - w * 0.22, h * (offset + 0.24))
        ..lineTo(cx, h * offset)
        ..lineTo(cx + w * 0.22, h * (offset + 0.24));
      canvas.drawPath(chevron, fineStroke);
    }

    // 4. Rombo central entrelazado
    final innerDiamond = Path()
      ..moveTo(cx, h * 0.34)
      ..lineTo(cx + w * 0.22, h * 0.57)
      ..lineTo(cx, h * 0.83)
      ..lineTo(cx - w * 0.22, h * 0.57)
      ..close();
    canvas.drawPath(innerDiamond, fineStroke);

    // 5. Trazos internos convergentes hacia el vértice inferior
    final spear = Path()
      ..moveTo(cx - w * 0.13, h * 0.48)
      ..lineTo(cx, h * 0.74)
      ..lineTo(cx + w * 0.13, h * 0.48)
      ..moveTo(cx, h * 0.44)
      ..lineTo(cx, h * 0.74);
    canvas.drawPath(spear, fineStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Logotipo tipográfico "AuraDeck" en degradado metálico dorado.
class AuraWordmark extends StatelessWidget {
  const AuraWordmark({this.fontSize = 26, super.key});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AuraColors.champagneLight,
          AuraColors.champagneGold,
          AuraColors.champagneDark,
        ],
      ).createShader(bounds),
      child: Text(
        'AuraDeck',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Fondo radial oscuro místico consistente con el mockup oficial.
class AuraBackdrop extends StatelessWidget {
  const AuraBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.85),
          radius: 1.25,
          colors: [AuraColors.obsidianGlow, AuraColors.obsidianVoid],
        ),
      ),
      child: child,
    );
  }
}

/// Placeholder de carta mística dorada con emblema y arco inferior (estilo referencia).
class AuraCardCrestPlaceholder extends StatelessWidget {
  const AuraCardCrestPlaceholder({
    required this.name,
    this.compact = false,
    super.key,
  });

  final String name;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF171924), Color(0xFF0A0B10)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: compact ? 14 : 24),
              child: AuraSigilLogo(size: compact ? 38 : 92, showAura: !compact),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: compact ? 36 : 92,
              height: compact ? 10 : 22,
              margin: EdgeInsets.only(bottom: compact ? 22 : 42),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AuraColors.champagneDark.withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  left: BorderSide(
                    color: AuraColors.champagneDark.withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  right: BorderSide(
                    color: AuraColors.champagneDark.withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.elliptical(48, 22),
                ),
              ),
            ),
          ),
          if (!compact)
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AuraColors.creamText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
