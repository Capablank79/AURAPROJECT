import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/binder_model.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/billing_service.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../core/widgets/aura_sigil_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../../binder/presentation/widgets/trash_bin_sheet.dart';
import '../../binder/providers/binder_providers.dart';
import 'moderation_sheet.dart';
import 'widgets/country_currency_card.dart';
import 'widgets/profile_identity_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({this.asScaffold = false, super.key});

  final bool asScaffold;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _purchasing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(activeProfileProvider);
    final bindersAsync = ref.watch(bindersProvider);
    final authUser = ref.watch(authStateProvider);
    final valuationAsync = ref.watch(portfolioValuationProvider);
    final trashCount = ref.watch(trashedItemsProvider).valueOrNull?.length ?? 0;
    final locale = ref.watch(appLocaleProvider);

    final profile = profileAsync.valueOrNull ?? authUser;
    final languages = {
      'es': l10n.languageSpanish,
      'en': l10n.languageEnglish,
      'pt': l10n.languagePortuguese,
      'ja': l10n.languageJapanese,
    };

    final body = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.navSettings,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => showTrashBinSheet(context),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: trashCount > 0
                    ? AuraColors.psychicMagenta
                    : AuraColors.silverMuted,
              ),
              icon: const Icon(Icons.delete_outline, size: 17),
              label: Text(l10n.trashBinCountBadge(trashCount)),
            ),
          ],
        ),
        if (profile != null) ...[
          const SizedBox(height: 8),
          ProfileIdentityCard(profile: profile),
          const SizedBox(height: 8),
          _ValuationCard(valuationAsync: valuationAsync),
          const SizedBox(height: 8),
          _SpaceBankCard(
            profile: profile,
            binders: bindersAsync.valueOrNull ?? const <BinderModel>[],
          ),
          const SizedBox(height: 8),
          _SpaceStoreCard(
            profile: profile,
            purchasing: _purchasing,
            onBuySingleSheet: () => _purchase(BillingProductId.singleSheet),
            onBuyTenSheets: () => _purchase(BillingProductId.packTenSheets),
            onBuyExtraBinder: () => _purchase(BillingProductId.standardBinder),
            onBuyPro: () => _purchase(BillingProductId.auraProAnnual),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            value: profile.isAdmin,
            title: Text(l10n.adminModeLabel),
            onChanged: (value) async {
              await ref
                  .read(binderRepositoryProvider)
                  .updateProfileEntitlements(isAdmin: value);
              ref.invalidate(activeProfileProvider);
            },
          ),
          if (profile.isAdmin) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => showModerationSheet(context),
              icon: const Icon(Icons.shield_outlined),
              label: Text(l10n.moderationPanelTitle),
            ),
          ],
        ],
        const SizedBox(height: 14),
        const CountryCurrencyCard(),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.changeLanguage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: languages.entries.map((entry) {
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
              ],
            ),
          ),
        ),
        if (authUser != null) ...[
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.signOutButton),
          ),
        ],
      ],
    );

    if (!widget.asScaffold) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: AuraBackdrop(child: SafeArea(child: body)),
    );
  }

  Future<void> _purchase(BillingProductId product) async {
    setState(() => _purchasing = true);
    try {
      final billing = ref.read(billingServiceProvider);
      final result = await billing.purchaseProduct(product);
      if (!result.success) {
        return;
      }
      final entitlements = await billing.getEntitlements();
      final currentProfile = ref.read(activeProfileProvider).valueOrNull;
      final nextAvailableSlots = product.isSubscription ||
              product == BillingProductId.standardBinder ||
              product == BillingProductId.compactBinder ||
              product == BillingProductId.packThreeBinders
          ? currentProfile?.availableSlots
          : (currentProfile?.availableSlots ?? 0) + product.slots;
      await ref
          .read(binderRepositoryProvider)
          .updateProfileEntitlements(
            isPro: entitlements.isPro,
            extraBinderCredits: entitlements.extraBinderCredits,
            availableSlots: nextAvailableSlots,
          );
      ref.invalidate(activeProfileProvider);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.purchaseCompletedMessage)));
      }
    } finally {
      if (mounted) {
        setState(() => _purchasing = false);
      }
    }
  }
}

class _ValuationCard extends ConsumerWidget {
  const _ValuationCard({required this.valuationAsync});

  final AsyncValue<PortfolioValuation> valuationAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatUsd = ref.watch(formatUsdProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: valuationAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => Text(l10n.genericError),
          data: (valuation) {
            final roiPct = valuation.roiPercent.round();
            final roiSign = valuation.netRoi >= 0 ? '+' : '-';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.valuationPanelTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AuraColors.champagneGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _ValuationMiniStat(
                        label: l10n.totalPiecesLabel,
                        value: '${valuation.totalItems}',
                        valueColor: AuraColors.creamText,
                        large: true,
                      ),
                    ),
                    Expanded(
                      child: _ValuationMiniStat(
                        label: l10n.costBasisLabel,
                        value: valuation.costBasis > 0
                            ? formatUsd(valuation.costBasis)
                            : '—',
                        valueColor: AuraColors.creamText,
                      ),
                    ),
                    Expanded(
                      child: _ValuationMiniStat(
                        label: l10n.totalValuationLabel,
                        value: formatUsd(valuation.totalValue),
                        valueColor: AuraColors.solarGold,
                        large: true,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 12),
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    _ValuationMiniStat(
                      label: l10n.roiLabel,
                      value:
                          '$roiSign${formatUsd(valuation.netRoi.abs())} ($roiSign${roiPct.abs()}%)',
                      valueColor: valuation.netRoi >= 0
                          ? AuraColors.emeraldAura
                          : AuraColors.psychicMagenta,
                    ),
                    _ValuationMiniStat(
                      label: l10n.slabsCountLabel,
                      value: '${valuation.slabsCount}',
                      valueColor: AuraColors.champagneGold,
                    ),
                    _ValuationMiniStat(
                      label: l10n.tradelistCountLabel,
                      value: '${valuation.tradeCount}',
                      valueColor: AuraColors.manaCyan,
                    ),
                    if (valuation.unverifiedApiItems > 0)
                      _ValuationMiniStat(
                        label: l10n.apiReferencesCountLabel,
                        value: '${valuation.unverifiedApiItems}',
                        valueColor: AuraColors.psychicMagenta,
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ValuationMiniStat extends StatelessWidget {
  const _ValuationMiniStat({
    required this.label,
    required this.value,
    required this.valueColor,
    this.large = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AuraColors.silverMuted, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w800,
            fontSize: large ? 16 : 13,
          ),
        ),
      ],
    );
  }
}

class _SpaceBankCard extends StatelessWidget {
  const _SpaceBankCard({required this.profile, required this.binders});

  final ProfileModel profile;
  final List<BinderModel> binders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final allocated = binders.fold<int>(0, (sum, b) => sum + b.maxSlots);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  color: AuraColors.manaCyan,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.spaceBankTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AuraColors.champagneGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.allocatedSlotsLabel,
                        style: const TextStyle(
                          color: AuraColors.silverMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$allocated',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.availableSlotsLabel,
                        style: const TextStyle(
                          color: AuraColors.silverMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile.availableSlots}',
                        style: const TextStyle(
                          color: AuraColors.emeraldAura,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.spaceBankHint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AuraColors.silverMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceStoreCard extends StatelessWidget {
  const _SpaceStoreCard({
    required this.profile,
    required this.purchasing,
    required this.onBuySingleSheet,
    required this.onBuyTenSheets,
    required this.onBuyExtraBinder,
    required this.onBuyPro,
  });

  final ProfileModel profile;
  final bool purchasing;
  final VoidCallback onBuySingleSheet;
  final VoidCallback onBuyTenSheets;
  final VoidCallback onBuyExtraBinder;
  final VoidCallback onBuyPro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  color: AuraColors.solarGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.spaceStoreTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AuraColors.champagneGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  l10n.binderCreditsCount(profile.extraBinderCredits),
                  style: const TextStyle(
                    color: AuraColors.manaCyan,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: purchasing ? null : onBuySingleSheet,
              child: Text(l10n.buySingleSheetButton),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: purchasing ? null : onBuyTenSheets,
              child: Text(l10n.buyTenSheetsButton),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: purchasing ? null : onBuyExtraBinder,
              child: Text(l10n.buyExtraBinderButton),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: purchasing || profile.isPro ? null : onBuyPro,
              child: Text(
                profile.isPro
                    ? l10n.proPlanLabel
                    : l10n.upgradeToProAnnualButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
