import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/aura_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/binder_providers.dart';

class BinderHomeScreen extends ConsumerWidget {
  const BinderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final binders = ref.watch(bindersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: binders.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.genericError),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => ref.invalidate(bindersProvider),
                    child: Text(l10n.retryButton),
                  ),
                ],
              ),
            ),
          ),
          data: (items) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.yourCollection,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.collectionSubtitle,
                style: const TextStyle(color: AuraColors.mutedText),
              ),
              const SizedBox(height: 24),
              ...items.map(
                (binder) => Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AuraColors.solarGold,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.auto_stories,
                                  color: AuraColors.obsidianVoid,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    binder.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.binderSummary(
                                      binder.gridFormat,
                                      binder.maxSlots,
                                    ),
                                    style: const TextStyle(
                                      color: AuraColors.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AspectRatio(
                          aspectRatio: 1.2,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              return Semantics(
                                label: l10n.emptySlot(index + 1),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AuraColors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AuraColors.manaCyan.withValues(
                                        alpha: 0.18,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AuraColors.mutedText,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.add),
                label: Text(l10n.addBinderButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
