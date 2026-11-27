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
import '../../catalog/presentation/decks_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../data/repositories/binder_repository.dart';
import '../providers/binder_providers.dart';
import 'widgets/language_menu.dart';

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
        actions: const [LanguageMenu()],
      ),
      bottomNavigationBar: AuraBottomBar(
        activeTab: _activeTab,
        onSelected: (tab) => setState(() => _activeTab = tab),
      ),
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

class _ShowcasesListView extends StatelessWidget {
  const _ShowcasesListView({
    required this.binders,
    required this.onCreateBinder,
    required this.onShowProInfo,
  });

  final List<BinderModel> binders;
  final VoidCallback onCreateBinder;
  final VoidCallback onShowProInfo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      children: [
        Text(
          l10n.yourCollection,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.collectionSubtitle,
          style: const TextStyle(color: AuraColors.mutedText, height: 1.4),
        ),
        const SizedBox(height: 22),
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

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
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
              TextField(
                controller: _queryController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.searchMyShowcasesLabel,
                  hintText: l10n.searchMyShowcasesHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _SearchMatchesList(binders: binders, query: query),
              ),
            ],
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
                              l10n.occupiedCount(
                                binderItems.length,
                                binder.maxSlots,
                              ),
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
