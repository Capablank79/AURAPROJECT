import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/currency/currency_registry.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

class CountryCurrencyCard extends ConsumerWidget {
  const CountryCurrencyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final countryCode = ref.watch(selectedCountryProvider);
    final currencyCode = ref.watch(preferredCurrencyProvider);
    final country = CurrencyRegistry.countryByCode(countryCode);
    final currency = CurrencyRegistry.currencyByCode(currencyCode);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.countryCurrencyTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AuraColors.champagneGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _SelectorRow(
              label: l10n.countryLabel,
              leading: Text(
                country?.flag ?? '🌍',
                style: const TextStyle(fontSize: 22),
              ),
              value: country?.name ?? l10n.selectCountryPrompt,
              onTap: () => _pickCountry(context, ref, countryCode),
            ),
            const SizedBox(height: 10),
            _SelectorRow(
              label: l10n.currencyLabel,
              leading: Text(
                currency.flag,
                style: const TextStyle(fontSize: 22),
              ),
              value: '${currency.code} (${currency.symbol}) · ${currency.name}',
              onTap: () => _pickCurrency(context, ref, currency.code),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.currencyAutoUpdatedHint,
              style: const TextStyle(
                color: AuraColors.silverMuted,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCountry(
    BuildContext context,
    WidgetRef ref,
    String? currentCode,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<CountrySpec>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.smokedCharcoal,
      builder: (_) => _SearchableSheet<CountrySpec>(
        title: l10n.countryLabel,
        searchHint: l10n.searchCountryHint,
        items: CurrencyRegistry.countries,
        matches: (c, q) =>
            c.name.toLowerCase().contains(q) ||
            c.code.toLowerCase().contains(q) ||
            c.defaultCurrencyCode.toLowerCase().contains(q),
        isSelected: (c) => c.code == currentCode,
        leadingBuilder: (c) => Text(c.flag, style: const TextStyle(fontSize: 22)),
        titleBuilder: (c) => c.name,
        subtitleBuilder: (c) => c.defaultCurrencyCode,
      ),
    );
    if (picked != null) {
      await ref.read(selectedCountryProvider.notifier).setCountry(picked);
    }
  }

  Future<void> _pickCurrency(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<CurrencySpec>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.smokedCharcoal,
      builder: (_) => _SearchableSheet<CurrencySpec>(
        title: l10n.currencyLabel,
        searchHint: l10n.searchCurrencyHint,
        items: CurrencyRegistry.currencies,
        matches: (c, q) =>
            c.code.toLowerCase().contains(q) ||
            c.name.toLowerCase().contains(q) ||
            c.symbol.toLowerCase().contains(q),
        isSelected: (c) => c.code == currentCode,
        leadingBuilder: (c) => Text(c.flag, style: const TextStyle(fontSize: 22)),
        titleBuilder: (c) => '${c.code} · ${c.symbol}',
        subtitleBuilder: (c) => c.name,
      ),
    );
    if (picked != null) {
      await ref.read(preferredCurrencyProvider.notifier).setCurrency(picked.code);
    }
  }
}

class _SelectorRow extends StatelessWidget {
  const _SelectorRow({
    required this.label,
    required this.leading,
    required this.value,
    required this.onTap,
  });

  final String label;
  final Widget leading;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AuraColors.obsidianVoid.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AuraColors.champagneGold.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AuraColors.silverMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AuraColors.champagneGold),
          ],
        ),
      ),
    );
  }
}

class _SearchableSheet<T> extends StatefulWidget {
  const _SearchableSheet({
    required this.title,
    required this.searchHint,
    required this.items,
    required this.matches,
    required this.isSelected,
    required this.leadingBuilder,
    required this.titleBuilder,
    required this.subtitleBuilder,
  });

  final String title;
  final String searchHint;
  final List<T> items;
  final bool Function(T item, String query) matches;
  final bool Function(T item) isSelected;
  final Widget Function(T item) leadingBuilder;
  final String Function(T item) titleBuilder;
  final String Function(T item) subtitleBuilder;

  @override
  State<_SearchableSheet<T>> createState() => _SearchableSheetState<T>();
}

class _SearchableSheetState<T> extends State<_SearchableSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.items
        : widget.items.where((item) => widget.matches(item, q)).toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                autofocus: false,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final selected = widget.isSelected(item);
                    return ListTile(
                      leading: widget.leadingBuilder(item),
                      title: Text(
                        widget.titleBuilder(item),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        widget.subtitleBuilder(item),
                        style: const TextStyle(color: AuraColors.silverMuted),
                      ),
                      trailing: selected
                          ? const Icon(Icons.check_circle, color: AuraColors.solarGold)
                          : null,
                      onTap: () => Navigator.pop(context, item),
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
