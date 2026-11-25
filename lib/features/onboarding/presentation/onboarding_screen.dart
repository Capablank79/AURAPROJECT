import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(appLocaleProvider);
    final languageEntries = {
      'es': l10n.languageSpanish,
      'en': l10n.languageEnglish,
      'pt': l10n.languagePortuguese,
      'ja': l10n.languageJapanese,
    };

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Semantics(
                    image: true,
                    label: l10n.auraLogoDescription,
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            AuraColors.solarGold,
                            AuraColors.manaCyan,
                            AuraColors.psychicMagenta,
                            AuraColors.emeraldAura,
                            AuraColors.solarGold,
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: AuraColors.obsidianVoid,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AuraColors.solarGold,
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AuraColors.solarGold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AuraColors.mutedText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    l10n.selectLanguage,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: languageEntries.entries.map((entry) {
                      return ChoiceChip(
                        label: Text(entry.value),
                        selected: locale.languageCode == entry.key,
                        onSelected: (selected) {
                          if (selected) {
                            ref
                                .read(appLocaleProvider.notifier)
                                .setLocale(Locale(entry.key));
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  FilledButton(
                    onPressed: () async {
                      await ref
                          .read(sharedPreferencesProvider)
                          .setBool(onboardingCompleteKey, true);
                      if (context.mounted) {
                        context.go('/home');
                      }
                    },
                    child: Text(l10n.beginButton),
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
