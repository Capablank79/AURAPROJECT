import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/collections/collection_l10n.dart';
import '../../../core/collections/collection_registry.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/binder_model.dart';
import '../../../core/models/item_model.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../core/widgets/aura_bottom_bar.dart';
import '../../../core/widgets/aura_sigil_logo.dart';
import '../../../core/widgets/collection_category_selector.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/presentation/decks_screen.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../../profile/presentation/profile_screen.dart';
import '../data/repositories/binder_repository.dart';
import '../providers/binder_providers.dart';

class BinderHomeScreen extends ConsumerStatefulWidget {
  const BinderHomeScreen({super.key});

  @override
  ConsumerState<BinderHomeScreen> createState() => _BinderHomeScreenState();
}

class _BinderHomeScreenState extends ConsumerState<BinderHomeScreen> {
  AuraNavTab _activeTab = AuraNavTab.showcases;

  @override
  Widget build(BuildContext context) {
    final binders = ref.watch(bindersProvider);
    final valuation = ref.watch(portfolioValuationProvider).valueOrNull;
    final formatUsd = ref.watch(formatUsdProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: const [
            AuraSigilLogo(size: 28, showAura: false),
            SizedBox(width: 10),
            AuraWordmark(fontSize: 21),
          ],
        ),
        actions: [
          if (valuation != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ActionChip(
                avatar: const Icon(
                  Icons.diamond_outlined,
                  size: 16,
                  color: AuraColors.champagneGold,
                ),
                label: Text(
                  formatUsd(valuation.totalValue),
                  style: const TextStyle(
                    color: AuraColors.champagneGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: AuraColors.smokedCharcoal,
                side: BorderSide(
                  color: AuraColors.champagneGold.withValues(alpha: 0.35),
                ),
                onPressed: () =>
                    setState(() => _activeTab = AuraNavTab.settings),
              ),
            ),
          IconButton(
            tooltip: 'MagicFrame',
            icon: const Icon(
              Icons.qr_code_scanner,
              color: AuraColors.champagneGold,
            ),
            onPressed: () => _openQuickScan(context, ref),
          ),
        ],
      ),
      bottomNavigationBar: AuraBottomBar(
        activeTab: _activeTab,
        onSelected: (tab) => setState(() => _activeTab = tab),
      ),
      floatingActionButton: _activeTab == AuraNavTab.showcases
          ? FloatingActionButton.extended(
              onPressed: () => _openQuickScan(context, ref),
              backgroundColor: AuraColors.champagneGold,
              foregroundColor: AuraColors.obsidianVoid,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                'MagicFrame',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : null,
      body: AuraBackdrop(
        child: SafeArea(
          child: switch (_activeTab) {
            AuraNavTab.showcases => binders.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) =>
                  _ErrorState(onRetry: () => ref.invalidate(bindersProvider)),
              data: (items) => items.isEmpty
                  ? _EmptyCollectionState(
                      onCreate: () => _showCreateBinder(context, ref),
                    )
                  : _ShowcasesListView(
                      binders: items,
                      onCreateBinder: () => _showCreateBinder(context, ref),
                      onShowProInfo: () => _showFreemiumLimit(context),
                    ),
            ),
            AuraNavTab.search => _CollectionQuickSearchView(
              bindersAsync: binders,
            ),
            AuraNavTab.decks => const DecksScreen(),
            AuraNavTab.settings => const ProfileScreen(),
          },
        ),
      ),
    );
  }

  Future<void> _openQuickScan(BuildContext context, WidgetRef ref) async {
    final binders = ref.read(bindersProvider).valueOrNull ?? const [];
    if (binders.isEmpty) {
      await _showCreateBinder(context, ref);
      return;
    }
    BinderModel? target = binders.length == 1 ? binders.first : null;
    target ??= await showModalBottomSheet<BinderModel>(
        context: context,
        backgroundColor: AuraColors.obsidianVoid,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(
            color: AuraColors.champagneGold.withValues(alpha: 0.25),
          ),
        ),
        builder: (sheetCtx) => SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(sheetCtx).yourCollection,
                  style: Theme.of(sheetCtx).textTheme.titleMedium?.copyWith(
                    color: AuraColors.champagneGold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                for (final b in binders)
                  ListTile(
                    leading: Icon(
                      CollectionRegistry.byCode(b.collectionCode).icon,
                      color: AuraColors.champagneGold,
                    ),
                    title: Text(b.title),
                    subtitle: Text(
                      CollectionL10n.binderCollectionLabel(
                        AppLocalizations.of(sheetCtx),
                        b,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pop(sheetCtx, b),
                  ),
              ],
            ),
          ),
        ),
      );
    if (target == null || !context.mounted) {
      return;
    }
    final items = await ref.read(binderItemsProvider(target.id).future);
    final occupied = items.map((e) => e.positionIndex).toSet();
    var nextPos = 0;
    while (occupied.contains(nextPos) && nextPos < target.maxSlots) {
      nextPos++;
    }
    if (!context.mounted) {
      return;
    }
    context.push('/binder/${target.id}/catalog?position=$nextPos');
  }

  Future<void> _showCreateBinder(BuildContext context, WidgetRef ref) async {
    final binders = ref.read(bindersProvider).valueOrNull ?? const [];
    final profile = await ref.read(activeProfileProvider.future);
    if (!context.mounted) {
      return;
    }
    final canCreate =
        binders.isEmpty ||
        profile.isPro ||
        profile.isAdmin ||
        profile.extraBinderCredits > 0 ||
        profile.availableSlots >= AppConstants.sheetSlots;
    if (!canCreate) {
      await _showFreemiumLimit(context);
      return;
    }

    final repository = ref.read(binderRepositoryProvider);
    final outcome = await showModalBottomSheet<_CreateBinderOutcome>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuraColors.obsidianVoid,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        side: BorderSide(
          color: AuraColors.champagneGold.withValues(alpha: 0.25),
        ),
      ),
      builder: (context) => _CreateBinderSheet(repository: repository),
    );
    if (!context.mounted) {
      return;
    }
    if (outcome == _CreateBinderOutcome.created) {
      ref.invalidate(bindersProvider);
      ref.invalidate(activeProfileProvider);
    } else if (outcome == _CreateBinderOutcome.limitReached) {
      await _showFreemiumLimit(context);
    }
  }

  Future<void> _showFreemiumLimit(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.workspace_premium, color: AuraColors.solarGold),
        title: Text(l10n.freeTierLimitTitle),
        content: Text(l10n.freeTierLimitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.notNowButton),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() => _activeTab = AuraNavTab.settings);
            },
            child: Text(l10n.viewAuraProButton),
          ),
        ],
      ),
    );
  }
}

class _ShowcasesListView extends ConsumerWidget {
  const _ShowcasesListView({
    required this.binders,
    required this.onCreateBinder,
    required this.onShowProInfo,
  });

  final List<BinderModel> binders;
  final VoidCallback onCreateBinder;
  final VoidCallback onShowProInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final valuation = ref.watch(portfolioValuationProvider).valueOrNull;
    final formatUsd = ref.watch(formatUsdProvider);

    ItemModel? mvpItem;
    for (final b in binders) {
      final items = ref.watch(binderItemsProvider(b.id)).valueOrNull ?? const [];
      for (final it in items) {
        if (it.isPhysicallyVerified &&
            (it.estimatedPrice ?? 0) > (mvpItem?.estimatedPrice ?? 0)) {
          mvpItem = it;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 92),
      children: [
        if (valuation != null) ...[
          _PortfolioTickerCard(
            totalValue: formatUsd(valuation.totalValue),
            totalItems: valuation.totalItems,
            slabsCount: valuation.slabsCount,
            mvpName: mvpItem?.name,
            mvpValue: mvpItem?.estimatedPrice != null
                ? formatUsd(mvpItem!.estimatedPrice!)
                : null,
          ),
          const SizedBox(height: 10),
        ],
        Text(
          l10n.yourCollection,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        for (final binder in binders) _BinderShowcase(binder: binder),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: onCreateBinder,
          icon: const Icon(Icons.add),
          label: Text(l10n.addBinderButton),
        ),
        const SizedBox(height: 16),
        _AuraProTeaserCard(onTap: onShowProInfo),
      ],
    );
  }
}

class _PortfolioTickerCard extends StatelessWidget {
  const _PortfolioTickerCard({
    required this.totalValue,
    required this.totalItems,
    required this.slabsCount,
    this.mvpName,
    this.mvpValue,
  });

  final String totalValue;
  final int totalItems;
  final int slabsCount;
  final String? mvpName;
  final String? mvpValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D172B), AuraColors.smokedCharcoal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AuraColors.champagneGold.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.trending_up,
            color: AuraColors.emeraldAura,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      totalValue,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AuraColors.champagneGold,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· $totalItems ${l10n.totalPiecesLabel}${slabsCount > 0 ? ' · $slabsCount Slabs' : ''}',
                      style: const TextStyle(
                        color: AuraColors.silverMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (mvpName != null)
                  Text(
                    'MVP: $mvpName${mvpValue != null ? ' ($mvpValue)' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AuraColors.creamText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuraProTeaserCard extends StatelessWidget {
  const _AuraProTeaserCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AuraColors.smokedCharcoal.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AuraColors.solarGold.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.workspace_premium,
                color: AuraColors.solarGold,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.auraProBannerTitle,
                      style: const TextStyle(
                        color: AuraColors.champagneGold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.auraProBannerSubtitle,
                      style: const TextStyle(
                        color: AuraColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AuraColors.champagneGold),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CreateBinderOutcome { created, limitReached }

class _CreateBinderSheet extends StatefulWidget {
  const _CreateBinderSheet({required this.repository});

  final BinderRepository repository;

  @override
  State<_CreateBinderSheet> createState() => _CreateBinderSheetState();
}

class _CreateBinderSheetState extends State<_CreateBinderSheet> {
  final _titleController = TextEditingController();
  final _customNameController = TextEditingController();
  CollectionFamily? _selectedFamily;
  String? _selectedCode;
  bool _isPublic = false;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _customNameController.dispose();
    super.dispose();
  }

  CollectionSpec? get _selectedSpec =>
      _selectedCode == null ? null : CollectionRegistry.byCode(_selectedCode!);

  bool get _canSubmit {
    final spec = _selectedSpec;
    if (spec == null || _submitting || _titleController.text.trim().isEmpty) {
      return false;
    }
    if (spec.requiresCustomName && _customNameController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spec = _selectedSpec;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.createBinderTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AuraColors.champagneGold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                CollectionFamilySelector(
                  selectedFamily: _selectedFamily,
                  onSelected: _submitting
                      ? (_) {}
                      : (family) {
                          setState(() {
                            if (_selectedFamily != family) {
                              _selectedCode = null;
                              _customNameController.clear();
                            }
                            _selectedFamily = family;
                            _errorMessage = null;
                          });
                        },
                ),
                if (_selectedFamily != null) ...[
                  const SizedBox(height: 18),
                  CollectionSpecSelector(
                    family: _selectedFamily!,
                    selectedCode: _selectedCode,
                    customNameController: _customNameController,
                    onCustomNameChanged: (_) => setState(() {}),
                    onSelected: (chosen) {
                      if (!_submitting) {
                        setState(() {
                          _selectedCode = chosen.code;
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  enabled: !_submitting,
                  onChanged: (_) => setState(() {}),
                  maxLength: 60,
                  decoration: InputDecoration(
                    labelText: l10n.binderTitleLabel,
                    hintText: CollectionL10n.suggestedBinderTitle(
                      l10n,
                      spec,
                      customName: _customNameController.text,
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isPublic,
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _isPublic = value),
                  title: Text(l10n.publicBinderLabel),
                  subtitle: Text(l10n.publicBinderHint),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AuraColors.psychicMagenta),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  child: _submitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.createButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final spec = _selectedSpec;
    if (spec == null) {
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await widget.repository.createBinder(
        title: _titleController.text.trim(),
        family: spec.family.code,
        collectionCode: spec.code,
        customCollectionName: spec.requiresCustomName
            ? _customNameController.text.trim()
            : null,
        isPublic: _isPublic,
      );
      if (mounted) {
        Navigator.of(context).pop(_CreateBinderOutcome.created);
      }
    } on BinderLimitException {
      if (mounted) {
        Navigator.of(context).pop(_CreateBinderOutcome.limitReached);
      }
    } on BinderRepositoryException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _errorMessage = AppLocalizations.of(context).createBinderError;
        });
      }
    }
  }
}

class _CollectionQuickSearchView extends ConsumerStatefulWidget {
  const _CollectionQuickSearchView({required this.bindersAsync});

  final AsyncValue<List<BinderModel>> bindersAsync;

  @override
  ConsumerState<_CollectionQuickSearchView> createState() =>
      _CollectionQuickSearchViewState();
}

class _CollectionQuickSearchViewState
    extends ConsumerState<_CollectionQuickSearchView> {
  final _queryController = TextEditingController();
  bool _onlineMode = false;
  CatalogProvider _onlineProvider = CatalogProvider.scryfall;
  Timer? _debounce;
  bool _searchingOnline = false;
  List<CatalogResult> _onlineResults = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {});
    if (!_onlineMode) {
      return;
    }
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      setState(() {
        _onlineResults = const [];
        _searchingOnline = false;
      });
      return;
    }
    setState(() => _searchingOnline = true);
    _debounce = Timer(const Duration(milliseconds: 380), () async {
      try {
        final results = await ref
            .read(catalogRepositoryProvider)
            .search(
              provider: _onlineProvider,
              query: trimmed,
              languageCode: ref.read(appLocaleProvider).languageCode,
            );
        if (mounted) {
          setState(() {
            _onlineResults = results;
            _searchingOnline = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _onlineResults = const [];
            _searchingOnline = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return widget.bindersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) =>
          _ErrorState(onRetry: () => ref.invalidate(bindersProvider)),
      data: (binders) {
        final query = _queryController.text.trim().toLowerCase();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.style_outlined, size: 16),
                    label: Text(l10n.navShowcases),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.public, size: 16),
                    label: Text(l10n.modeSearchLabel),
                  ),
                ],
                selected: {_onlineMode},
                onSelectionChanged: (selection) {
                  setState(() => _onlineMode = selection.first);
                  if (_onlineMode && _queryController.text.trim().length >= 2) {
                    _onQueryChanged(_queryController.text);
                  }
                },
              ),
              if (_onlineMode) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Magic'),
                      selected: _onlineProvider == CatalogProvider.scryfall,
                      onSelected: (_) {
                        setState(
                          () => _onlineProvider = CatalogProvider.scryfall,
                        );
                        _onQueryChanged(_queryController.text);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Pokémon'),
                      selected: _onlineProvider == CatalogProvider.tcgdex,
                      onSelected: (_) {
                        setState(() => _onlineProvider = CatalogProvider.tcgdex);
                        _onQueryChanged(_queryController.text);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Yu-Gi-Oh!'),
                      selected: _onlineProvider == CatalogProvider.ygoprodeck,
                      onSelected: (_) {
                        setState(
                          () => _onlineProvider = CatalogProvider.ygoprodeck,
                        );
                        _onQueryChanged(_queryController.text);
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _queryController,
                onChanged: _onQueryChanged,
                decoration: InputDecoration(
                  labelText: _onlineMode
                      ? l10n.modeSearchLabel
                      : l10n.searchMyShowcasesLabel,
                  hintText: _onlineMode
                      ? 'Sol Ring, Pikachu, Blue-Eyes...'
                      : l10n.searchMyShowcasesHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _onlineMode
                    ? _OnlineSearchResultsList(
                        loading: _searchingOnline,
                        results: _onlineResults,
                        binders: binders,
                        query: query,
                      )
                    : _SearchMatchesList(binders: binders, query: query),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OnlineSearchResultsList extends ConsumerWidget {
  const _OnlineSearchResultsList({
    required this.loading,
    required this.results,
    required this.binders,
    required this.query,
  });

  final bool loading;
  final List<CatalogResult> results;
  final List<BinderModel> binders;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatUsd = ref.watch(formatUsdProvider);
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (query.length < 2) {
      return Center(
        child: Text(
          l10n.searchMyShowcasesHint,
          style: const TextStyle(color: AuraColors.mutedText),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Text(
          l10n.noStoredItemsFound,
          style: const TextStyle(color: AuraColors.mutedText),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final card = results[index];
        return Card(
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 40,
                height: 54,
                child: card.imageUrl.isEmpty
                    ? AuraCardCrestPlaceholder(name: card.name, compact: true)
                    : Image.network(
                        card.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => AuraCardCrestPlaceholder(
                          name: card.name,
                          compact: true,
                        ),
                      ),
              ),
            ),
            title: Text(
              card.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              [
                if ((card.metadata['expansion'] ?? card.metadata['set_name']) !=
                    null)
                  (card.metadata['expansion'] ?? card.metadata['set_name'])
                      .toString(),
                if (card.estimatedPrice != null)
                  formatUsd(card.estimatedPrice!),
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: l10n.addItemButton,
              icon: const Icon(
                Icons.add_circle_outline,
                color: AuraColors.champagneGold,
              ),
              onPressed: binders.isEmpty
                  ? null
                  : () async {
                      final matching = binders
                          .where((b) => b.collectionCode == card.collectionCode)
                          .toList();
                      final target = matching.isNotEmpty
                          ? matching.first
                          : binders.first;
                      final items = await ref.read(
                        binderItemsProvider(target.id).future,
                      );
                      final occupied = items
                          .map((e) => e.positionIndex)
                          .toSet();
                      var nextPos = 0;
                      while (occupied.contains(nextPos) &&
                          nextPos < target.maxSlots) {
                        nextPos++;
                      }
                      if (context.mounted) {
                        context.push(
                          '/binder/${target.id}/catalog?position=$nextPos',
                        );
                      }
                    },
            ),
          ),
        );
      },
    );
  }
}

class _SearchMatchesList extends ConsumerWidget {
  const _SearchMatchesList({required this.binders, required this.query});

  final List<BinderModel> binders;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = <(BinderModel, ItemModel)>[];
    for (final binder in binders) {
      final items =
          ref.watch(binderItemsProvider(binder.id)).valueOrNull ?? const [];
      for (final item in items) {
        if (query.isEmpty || item.name.toLowerCase().contains(query)) {
          entries.add((binder, item));
        }
      }
    }
    if (entries.isEmpty) {
      return Center(
        child: Text(
          l10n.noStoredItemsFound,
          style: const TextStyle(color: AuraColors.mutedText),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final (binder, item) = entries[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/binder/${binder.id}/item/${item.id}'),
            leading: const Icon(
              Icons.auto_awesome,
              color: AuraColors.champagneGold,
            ),
            title: Text(item.name),
            subtitle: Text(
              '${binder.title} · ${CollectionL10n.binderCollectionLabel(l10n, binder)}',
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

class _EmptyCollectionState extends StatelessWidget {
  const _EmptyCollectionState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuraSigilLogo(size: 84),
            const SizedBox(height: 20),
            Text(
              l10n.emptyCollectionTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.emptyCollectionMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AuraColors.mutedText),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(l10n.chooseFirstCollectionButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _BinderShowcase extends ConsumerWidget {
  const _BinderShowcase({required this.binder});

  final BinderModel binder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final items = ref.watch(binderItemsProvider(binder.id));
    final formatUsd = ref.watch(formatUsdProvider);
    final spec = CollectionRegistry.byCode(binder.collectionCode);
    final collectionLabel = CollectionL10n.binderCollectionLabel(l10n, binder);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/binder/${binder.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1A1624),
                      AuraColors.smokedCharcoal,
                      AuraColors.obsidianVoid,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: spec.accentColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AuraColors.champagneGold.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                      child: Icon(spec.icon, color: AuraColors.champagneGold),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            binder.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _SmallBadge(label: collectionLabel),
                              _SmallBadge(label: binder.gridFormat),
                              _SmallBadge(
                                label: binder.isPublic
                                    ? l10n.visibilityPublic
                                    : l10n.visibilityPrivate,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AuraColors.champagneGold,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                child: items.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => Text(l10n.genericError),
                  data: (binderItems) {
                    final verifiedItems = binderItems
                        .where((i) => i.isPhysicallyVerified)
                        .toList();
                    final unverifiedCount =
                        binderItems.length - verifiedItems.length;
                    final value = verifiedItems.fold<double>(
                      0,
                      (sum, item) => sum + (item.estimatedPrice ?? 0),
                    );
                    final progress = binder.maxSlots == 0
                        ? 0.0
                        : (binderItems.length / binder.maxSlots).clamp(
                            0.0,
                            1.0,
                          );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${l10n.occupiedCount(binderItems.length, binder.maxSlots)} (${(progress * 100).round()}%)',
                              style: const TextStyle(
                                color: AuraColors.mutedText,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.diamond,
                              size: 14,
                              color: AuraColors.champagneGold,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              l10n.estimatedValue(formatUsd(value)),
                              style: const TextStyle(
                                color: AuraColors.champagneGold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if (binderItems.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            unverifiedCount == 0
                                ? l10n.trustBadgeFullPhysical
                                : l10n.trustBadgeHasApi(unverifiedCount),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: unverifiedCount == 0
                                  ? AuraColors.emeraldAura
                                  : AuraColors.psychicMagenta,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            value: progress,
                            backgroundColor: AuraColors.surfaceRaised,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              unverifiedCount == 0
                                  ? AuraColors.champagneGold
                                  : AuraColors.psychicMagenta,
                            ),
                          ),
                        ),
                      ],
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

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AuraColors.champagneGold.withValues(alpha: 0.32),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AuraColors.champagneGold,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.genericError),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}
