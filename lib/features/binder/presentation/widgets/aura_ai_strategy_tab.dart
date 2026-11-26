import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/item_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../catalog/data/repositories/card_strategy_repository.dart';
import '../../../catalog/providers/catalog_providers.dart';

class AuraAiStrategyTab extends ConsumerStatefulWidget {
  const AuraAiStrategyTab({required this.item, super.key});

  final ItemModel item;

  @override
  ConsumerState<AuraAiStrategyTab> createState() => _AuraAiStrategyTabState();
}

class _AuraAiStrategyTabState extends ConsumerState<AuraAiStrategyTab> {
  CardStrategyAnalysis? _analysis;
  bool _loading = false;
  bool _limitReached = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider);
    final usedCount = ref.watch(aiDailyUsageProvider);
    final isPro = user?.isPro ?? false;
    final remaining = (ApiConstants.freeAiAnalysesPerDay - usedCount).clamp(
      0,
      ApiConstants.freeAiAnalysesPerDay,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AuraColors.solarGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.auraAiTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AuraColors.champagneGold,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (!isPro)
                      Text(
                        l10n.auraAiRemaining(
                          remaining,
                          ApiConstants.freeAiAnalysesPerDay,
                        ),
                        style: const TextStyle(
                          color: AuraColors.silverMuted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loading ? null : () => _analyze(isPro),
                  icon: _loading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bolt),
                  label: Text(l10n.analyzeSynergiesButton),
                ),
                if (_limitReached) ...[
                  const SizedBox(height: 10),
                  Text(
                    l10n.auraAiLimitReached,
                    style: const TextStyle(color: AuraColors.psychicMagenta),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_analysis != null) ...[
          const SizedBox(height: 14),
          _AnalysisResultsCard(analysis: _analysis!),
        ],
      ],
    );
  }

  Future<void> _analyze(bool isPro) async {
    final used = ref.read(aiDailyUsageProvider);
    if (!isPro && used >= ApiConstants.freeAiAnalysesPerDay) {
      setState(() => _limitReached = true);
      return;
    }
    setState(() {
      _loading = true;
      _limitReached = false;
    });
    try {
      final lang = ref.read(appLocaleProvider).languageCode;
      final result = await ref
          .read(cardStrategyRepositoryProvider)
          .analyzeItem(item: widget.item, targetLanguage: lang);
      if (!isPro) {
        ref.read(aiDailyUsageProvider.notifier).state = used + 1;
      }
      if (mounted) {
        setState(() => _analysis = result);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

class _AnalysisResultsCard extends StatelessWidget {
  const _AnalysisResultsCard({required this.analysis});

  final CardStrategyAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.auraAiArchetypesTitle,
              style: const TextStyle(
                color: AuraColors.champagneGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: analysis.archetypes
                  .map(
                    (arch) => Chip(
                      label: Text(arch),
                      backgroundColor: AuraColors.surfaceRaised,
                    ),
                  )
                  .toList(),
            ),
            const Divider(height: 24),
            Text(
              l10n.auraAiCombosTitle,
              style: const TextStyle(
                color: AuraColors.champagneGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            for (final combo in analysis.synergies) ...[
              Text(
                '◆ ${combo.cardName}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AuraColors.manaCyan,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                combo.reason,
                style: const TextStyle(
                  color: AuraColors.creamText,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
            ],
            const Divider(height: 16),
            Text(
              l10n.auraAiTacticalTipTitle,
              style: const TextStyle(
                color: AuraColors.champagneGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              analysis.tacticalTip,
              style: const TextStyle(color: AuraColors.silverMuted),
            ),
          ],
        ),
      ),
    );
  }
}
