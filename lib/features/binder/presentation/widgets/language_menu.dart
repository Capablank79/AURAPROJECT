import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';

class LanguageMenu extends ConsumerWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(appLocaleProvider);
    final labels = {
      'es': l10n.languageSpanish,
      'en': l10n.languageEnglish,
      'pt': l10n.languagePortuguese,
      'ja': l10n.languageJapanese,
    };

    return Semantics(
      button: true,
      label: l10n.changeLanguage,
      child: PopupMenuButton<String>(
        tooltip: l10n.changeLanguage,
        icon: const Icon(Icons.language),
        onSelected: (code) =>
            ref.read(appLocaleProvider.notifier).setLocale(Locale(code)),
        itemBuilder: (context) => labels.entries
            .map(
              (entry) => PopupMenuItem(
                value: entry.key,
                child: Row(
                  children: [
                    Expanded(child: Text(entry.value)),
                    if (entry.key == locale.languageCode)
                      const Icon(Icons.check, size: 18),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
