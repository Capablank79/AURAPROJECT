import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/aura_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../binder/providers/binder_providers.dart';

Future<void> showModerationSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AuraColors.obsidianVoid,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: AuraColors.champagneGold.withValues(alpha: 0.25)),
    ),
    builder: (_) => const _ModerationSheet(),
  );
}

class _ModerationSheet extends ConsumerWidget {
  const _ModerationSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reportsAsync = ref.watch(reportsProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: SizedBox(
          height: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.moderationPanelTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AuraColors.champagneGold,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: reportsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(child: Text(l10n.genericError)),
                  data: (reports) {
                    if (reports.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.moderationEmptyMessage,
                          style: const TextStyle(color: AuraColors.mutedText),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: reports.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        final isPending = report.status == 'pending';
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        report.reason,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      report.status.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isPending
                                            ? AuraColors.solarGold
                                            : AuraColors.emeraldAura,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  report.itemId,
                                  style: const TextStyle(
                                    color: AuraColors.silverMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                if (isPending) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          await ref
                                              .read(reportRepositoryProvider)
                                              .updateReportStatus(
                                                reportId: report.id,
                                                status: 'dismissed',
                                              );
                                          ref.invalidate(reportsProvider);
                                        },
                                        child: Text(l10n.dismissReportButton),
                                      ),
                                      const SizedBox(width: 8),
                                      FilledButton.tonal(
                                        onPressed: () async {
                                          await ref
                                              .read(reportRepositoryProvider)
                                              .updateReportStatus(
                                                reportId: report.id,
                                                status: 'reviewed',
                                              );
                                          ref.invalidate(reportsProvider);
                                        },
                                        child: Text(l10n.markReviewedButton),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
