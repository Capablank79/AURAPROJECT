import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/services/ml_kit_service.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/catalog_repository.dart';

class ScannerZonalReticle extends StatelessWidget {
  const ScannerZonalReticle({
    required this.locked,
    required this.streaming,
    super.key,
  });

  final bool locked;
  final bool streaming;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final frameColor = locked ? AuraColors.emeraldAura : AuraColors.solarGold;

    return IgnorePointer(
      child: AspectRatio(
        aspectRatio: 0.714,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: frameColor, width: 2.4),
            boxShadow: [
              BoxShadow(
                color: frameColor.withValues(alpha: 0.22),
                blurRadius: 18,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              return Stack(
                children: [
                  if (streaming && !locked)
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AuraColors.obsidianVoid.withValues(
                              alpha: 0.82,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AuraColors.manaCyan.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Text(
                            l10n.scannerStreamActiveBadge,
                            style: const TextStyle(
                              color: AuraColors.manaCyan,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Zona Superior: Nombre (ignora HP / coste a la derecha)
                  Positioned(
                    top: h * 0.08,
                    left: w * 0.07,
                    right: w * 0.22,
                    height: h * 0.11,
                    child: _ZoneBox(
                      label: l10n.scannerZoneTitleLabel,
                      color: AuraColors.solarGold,
                    ),
                  ),
                  // Zona Central: Ventana de huella visual dHash 64-bit
                  Positioned(
                    top: h * 0.21,
                    left: w * 0.12,
                    right: w * 0.12,
                    height: h * 0.36,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AuraColors.manaCyan.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                  // Zona Inferior: Set + Número de Coleccionista
                  Positioned(
                    bottom: h * 0.05,
                    left: w * 0.07,
                    right: w * 0.34,
                    height: h * 0.09,
                    child: _ZoneBox(
                      label: l10n.scannerZoneSetLabel,
                      color: AuraColors.emeraldAura,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ZoneBox extends StatelessWidget {
  const _ZoneBox({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.65)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class ScannerDetectedArHud extends ConsumerStatefulWidget {
  const ScannerDetectedArHud({
    required this.candidates,
    required this.scanMatch,
    required this.hasProofPhoto,
    required this.onConfirm,
    required this.onRescan,
    super.key,
  });

  final List<CatalogResult> candidates;
  final CardScanMatch scanMatch;
  final bool hasProofPhoto;
  final void Function(CatalogResult selected, bool isFoil) onConfirm;
  final VoidCallback onRescan;

  @override
  ConsumerState<ScannerDetectedArHud> createState() =>
      _ScannerDetectedArHudState();
}

class _ScannerDetectedArHudState extends ConsumerState<ScannerDetectedArHud> {
  int _selectedIndex = 0;
  bool _isFoil = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatUsd = ref.watch(formatUsdProvider);
    final card = widget.candidates[_selectedIndex];
    final basePrice = card.estimatedPrice;
    final effectivePrice = basePrice == null
        ? null
        : (_isFoil ? basePrice * 1.35 : basePrice);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AuraColors.smokedCharcoal,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AuraColors.emeraldAura, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AuraColors.emeraldAura.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.scannerCenteringLabel(
                    widget.scanMatch.centeringRatio,
                    widget.scanMatch.estimatedGrade,
                  ),
                  style: const TextStyle(
                    color: AuraColors.emeraldAura,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (widget.hasProofPhoto)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AuraColors.manaCyan.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.proofSnapshotSavedBadge,
                    style: const TextStyle(
                      color: AuraColors.manaCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
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
                    Text(
                      '${card.metadata['expansion'] ?? ''} ${card.metadata['number'] != null ? '· #${card.metadata['number']}' : ''}'
                          .trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AuraColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                    if (effectivePrice != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        formatUsd(effectivePrice),
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
              FilterChip(
                label: const Text('FOIL'),
                selected: _isFoil,
                onSelected: (val) => setState(() => _isFoil = val),
              ),
            ],
          ),
          if (widget.candidates.length > 1) ...[
            const SizedBox(height: 8),
            Text(
              l10n.scannerVariantSelectorLabel(widget.candidates.length),
              style: const TextStyle(
                color: AuraColors.silverMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (
                    var i = 0;
                    i < widget.candidates.length && i < 6;
                    i++
                  ) ...[
                    ChoiceChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        _variantLabel(widget.candidates[i], i),
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: _selectedIndex == i,
                      onSelected: (_) => setState(() => _selectedIndex = i),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onRescan,
                  child: Text(l10n.retryButton),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => widget.onConfirm(card, _isFoil),
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

  String _variantLabel(CatalogResult item, int index) {
    final exp = item.metadata['expansion']?.toString() ?? 'Ed. ${index + 1}';
    final num = item.metadata['number']?.toString();
    final shortExp = exp.length > 16 ? '${exp.substring(0, 16)}…' : exp;
    return num != null ? '$shortExp #$num' : shortExp;
  }
}
