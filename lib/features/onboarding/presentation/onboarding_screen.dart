import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/collections/collection_l10n.dart';
import '../../../core/collections/collection_registry.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/aura_colors.dart';
import '../../../core/widgets/aura_sigil_logo.dart';
import '../../../core/widgets/collection_category_selector.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/providers/auth_providers.dart';
import '../../binder/data/repositories/binder_repository.dart';
import '../../binder/providers/binder_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _titleController = TextEditingController();
  final _customCollectionController = TextEditingController();
  CollectionFamily? _selectedFamily;
  String? _selectedCode;
  bool _isPublic = false;
  bool _submitting = false;
  String? _errorMessage;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    if (ref.read(authStateProvider) != null) {
      _step = 1;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customCollectionController.dispose();
    super.dispose();
  }

  CollectionSpec? get _selectedSpec =>
      _selectedCode == null ? null : CollectionRegistry.byCode(_selectedCode!);

  bool get _canPassCollectionStep {
    final spec = _selectedSpec;
    if (spec == null) {
      return false;
    }
    if (spec.requiresCustomName) {
      return _customCollectionController.text.trim().isNotEmpty;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: AuraBackdrop(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (_step) {
              0 => _LanguageStep(
                key: const ValueKey('step-language'),
                onContinue: () {
                  if (ref.read(authStateProvider) == null) {
                    context.go('/auth');
                  } else {
                    setState(() => _step = 1);
                  }
                },
              ),
              1 => _StepScaffold(
                key: const ValueKey('step-family'),
                stepIndex: 1,
                onBack: () => setState(() => _step = 0),
                title: l10n.chooseCollectionTitle,
                subtitle: l10n.chooseFamilySubtitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CollectionFamilySelector(
                      selectedFamily: _selectedFamily,
                      onSelected: (family) {
                        setState(() {
                          if (_selectedFamily != family) {
                            _selectedCode = null;
                            _customCollectionController.clear();
                          }
                          _selectedFamily = family;
                        });
                      },
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _selectedFamily == null
                          ? null
                          : () => setState(() => _step = 2),
                      child: Text(l10n.continueButton),
                    ),
                  ],
                ),
              ),
              2 => _StepScaffold(
                key: const ValueKey('step-spec'),
                stepIndex: 2,
                onBack: () => setState(() => _step = 1),
                title: _selectedFamily == CollectionFamily.cards
                    ? l10n.chooseCardGameTitle
                    : l10n.chooseObjectTypeTitle,
                subtitle: _selectedFamily == CollectionFamily.cards
                    ? l10n.chooseCardGameSubtitle
                    : l10n.chooseObjectTypeSubtitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CollectionSpecSelector(
                      family: _selectedFamily ?? CollectionFamily.cards,
                      selectedCode: _selectedCode,
                      customNameController: _customCollectionController,
                      onCustomNameChanged: (_) => setState(() {}),
                      onSelected: (spec) {
                        setState(() {
                          _selectedCode = spec.code;
                          _errorMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _canPassCollectionStep
                          ? () => setState(() => _step = 3)
                          : null,
                      child: Text(l10n.continueButton),
                    ),
                  ],
                ),
              ),
              _ => _StepScaffold(
                key: const ValueKey('step-name'),
                stepIndex: 3,
                onBack: _submitting ? null : () => setState(() => _step = 2),
                title: l10n.nameYourShowcaseTitle,
                subtitle: l10n.freeBinderCapacityHint,
                child: _buildFinalStep(context, l10n),
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFinalStep(BuildContext context, AppLocalizations l10n) {
    final spec = _selectedSpec;
    final customName = _customCollectionController.text.trim();
    final collectionLabel = spec == null
        ? ''
        : CollectionL10n.collectionName(
            l10n,
            spec.code,
            customName: customName,
          );
    final familyLabel = _selectedFamily == null
        ? ''
        : CollectionL10n.familyTitle(l10n, _selectedFamily!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AuraColors.smokedCharcoal.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AuraColors.champagneGold.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: (spec?.accentColor ?? AuraColors.champagneGold)
                    .withValues(alpha: 0.2),
                foregroundColor: spec?.accentColor ?? AuraColors.champagneGold,
                child: Text(
                  spec?.monogram ?? '◆',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collectionLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      familyLabel,
                      style: const TextStyle(
                        color: AuraColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _submitting ? null : () => setState(() => _step = 2),
                child: Text(l10n.changeSelectionButton),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _titleController,
          enabled: !_submitting,
          maxLength: 60,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.firstBinderNameLabel,
            hintText: CollectionL10n.suggestedBinderTitle(
              l10n,
              spec,
              customName: customName,
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
        const SizedBox(height: 12),
        if (spec != null)
          _ShowcaseIncludesCard(spec: spec, collectionLabel: collectionLabel),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AuraColors.psychicMagenta),
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed:
              spec != null &&
                  _titleController.text.trim().isNotEmpty &&
                  !_submitting
              ? _createFirstBinder
              : null,
          child: _submitting
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.createFreeBinderButton),
        ),
      ],
    );
  }

  Future<void> _createFirstBinder() async {
    final spec = _selectedSpec;
    if (spec == null) {
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(binderRepositoryProvider)
          .createBinder(
            title: _titleController.text.trim(),
            family: spec.family.code,
            collectionCode: spec.code,
            customCollectionName: spec.requiresCustomName
                ? _customCollectionController.text.trim()
                : null,
            isPublic: _isPublic,
          );
      await ref
          .read(sharedPreferencesProvider)
          .setBool(onboardingCompleteKey, true);
      ref.invalidate(bindersProvider);
      if (mounted) {
        context.go('/home');
      }
    } on BinderLimitException {
      if (mounted) {
        setState(
          () =>
              _errorMessage = AppLocalizations.of(context).freeTierLimitMessage,
        );
      }
    } on BinderRepositoryException {
      if (mounted) {
        setState(
          () => _errorMessage = AppLocalizations.of(context).createBinderError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.stepIndex,
    required this.onBack,
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final int stepIndex;
  final VoidCallback? onBack;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: l10n.backButton,
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  _ProgressDots(activeStep: stepIndex),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AuraColors.champagneGold,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AuraColors.mutedText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final active = index == activeStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(left: 6),
          width: active ? 22 : 7,
          height: 5,
          decoration: BoxDecoration(
            color: active ? AuraColors.champagneGold : AuraColors.surfaceRaised,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _ShowcaseIncludesCard extends StatelessWidget {
  const _ShowcaseIncludesCard({
    required this.spec,
    required this.collectionLabel,
  });

  final CollectionSpec spec;
  final String collectionLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuraColors.smokedCharcoal.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AuraColors.champagneGold.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.showcaseIncludesTitle,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.4,
              color: AuraColors.mutedText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _IncludeRow(
            color: AuraColors.champagneGold,
            text: l10n.freeBinderCapacityHint,
          ),
          const SizedBox(height: 6),
          if (spec.supportsApiSearch) ...[
            _IncludeRow(
              color: AuraColors.emeraldAura,
              text: l10n.includesCatalogSearch(collectionLabel),
            ),
            const SizedBox(height: 6),
            _IncludeRow(
              color: AuraColors.manaCyan,
              text: l10n.includesCameraScanner,
            ),
          ] else
            _IncludeRow(
              color: AuraColors.manaCyan,
              text: l10n.includesManualWebp,
            ),
          const SizedBox(height: 6),
          _IncludeRow(
            color: AuraColors.psychicMagenta,
            text: l10n.includesSingleCollectionRule(collectionLabel),
          ),
        ],
      ),
    );
  }
}

class _IncludeRow extends StatelessWidget {
  const _IncludeRow({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(Icons.diamond, size: 12, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(appLocaleProvider);
    final languageEntries = [
      ('es', '🇪🇸', l10n.languageSpanish),
      ('en', '🇺🇸', l10n.languageEnglish),
      ('pt', '🇧🇷', l10n.languagePortuguese),
      ('ja', '🇯🇵', l10n.languageJapanese),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              Center(
                child: AuraSigilLogo(
                  size: 88,
                  semanticLabel: l10n.auraLogoDescription,
                ),
              ),
              const SizedBox(height: 10),
              const AuraWordmark(fontSize: 30),
              const SizedBox(height: 10),
              Text(
                l10n.welcomeTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AuraColors.champagneLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AuraColors.mutedText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.selectLanguage,
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.3,
                  color: AuraColors.mutedText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final halfWidth = (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final (code, flag, label) in languageEntries)
                        SizedBox(
                          width: halfWidth,
                          child: _LanguageTile(
                            flag: flag,
                            label: label,
                            selected: locale.languageCode == code,
                            onTap: () => ref
                                .read(appLocaleProvider.notifier)
                                .setLocale(Locale(code)),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onContinue,
                child: Text(l10n.continueButton),
              ),
              const SizedBox(height: 14),
              const Center(child: _ProgressDots(activeStep: 0)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? AuraColors.champagneGold.withValues(alpha: 0.11)
            : AuraColors.smokedCharcoal.withValues(alpha: 0.78),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected
                ? AuraColors.champagneGold
                : AuraColors.champagneGold.withValues(alpha: 0.16),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (selected)
                  const Icon(Icons.check, color: AuraColors.champagneGold),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
