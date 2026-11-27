import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/binder_model.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/repositories/binder_repository.dart';
import '../../providers/binder_providers.dart';

Future<bool> showBinderManageSheet(
  BuildContext context, {
  required BinderModel binder,
  required int occupiedCount,
}) async {
  final deleted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AuraColors.smokedCharcoal,
    builder: (_) => _BinderManageSheet(
      binder: binder,
      occupiedCount: occupiedCount,
    ),
  );
  return deleted == true;
}

class _BinderManageSheet extends ConsumerStatefulWidget {
  const _BinderManageSheet({
    required this.binder,
    required this.occupiedCount,
  });

  final BinderModel binder;
  final int occupiedCount;

  @override
  ConsumerState<_BinderManageSheet> createState() => _BinderManageSheetState();
}

class _BinderManageSheetState extends ConsumerState<_BinderManageSheet> {
  late final TextEditingController _titleController;
  late bool _isPublic;
  late String _gridFormat;
  late int _maxSlots;
  late bool _isCompleted;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.binder.title);
    _isPublic = widget.binder.isPublic;
    _gridFormat = widget.binder.gridFormat;
    _maxSlots = widget.binder.maxSlots;
    _isCompleted = widget.binder.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(activeProfileProvider).valueOrNull;
    final availableBank = profile?.availableSlots ?? 0;
    final isPro = (profile?.isPro ?? false) || (profile?.isAdmin ?? false);
    final canAddSheet =
        _maxSlots + AppConstants.sheetSlots <= AppConstants.maxBinderSlots &&
        (isPro || availableBank >= AppConstants.sheetSlots);
    final canRemoveSheet =
        _maxSlots - AppConstants.sheetSlots >= widget.occupiedCount &&
        _maxSlots > AppConstants.sheetSlots;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.editBinderTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _titleController,
                maxLength: 50,
                decoration: InputDecoration(labelText: l10n.firstBinderNameLabel),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.publicBinderLabel),
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _gridFormat,
                decoration: InputDecoration(labelText: l10n.gridFormatLabel),
                items: [
                  DropdownMenuItem(
                    value: '2x2',
                    child: Text(l10n.grid2x2Option),
                  ),
                  DropdownMenuItem(
                    value: '3x3',
                    child: Text(l10n.grid3x3Option),
                  ),
                  DropdownMenuItem(
                    value: '4x3',
                    child: Text(l10n.grid4x3ProOption),
                  ),
                ],
                onChanged: (next) {
                  if (next == null) {
                    return;
                  }
                  if (next == '4x3' && !isPro) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.gridProRequiredMessage)),
                    );
                    return;
                  }
                  setState(() => _gridFormat = next);
                },
              ),
              const Divider(height: 24),
              Text(
                l10n.manageSpacesTitle,
                style: const TextStyle(
                  color: AuraColors.champagneGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.occupiedCount} / $_maxSlots · ${l10n.availableSlotsLabel}: $availableBank',
                style: const TextStyle(
                  color: AuraColors.silverMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving || !canRemoveSheet
                          ? null
                          : () => _resize(_maxSlots - AppConstants.sheetSlots),
                      child: Text(l10n.releaseEmptySheetButton),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: _saving
                          ? null
                          : () {
                              if (!canAddSheet) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.notEnoughBankSpaces),
                                  ),
                                );
                                return;
                              }
                              _resize(_maxSlots + AppConstants.sheetSlots);
                            },
                      child: Text(l10n.addSheetFromBankButton),
                    ),
                  ),
                ],
              ),
              if (!_isCompleted && _maxSlots > widget.occupiedCount) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _confirmComplete,
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(l10n.completeCollectionButton),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _saveChanges,
                child: Text(l10n.saveChangesButton),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _saving ? null : _confirmDelete,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.deleteBinderButton),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AuraColors.psychicMagenta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resize(int nextSlots) async {
    setState(() => _saving = true);
    try {
      final updated = await ref
          .read(binderRepositoryProvider)
          .resizeBinder(binderId: widget.binder.id, newMaxSlots: nextSlots);
      _maxSlots = updated.maxSlots;
      _isCompleted = updated.isCompleted;
      ref.invalidate(binderProvider(widget.binder.id));
      ref.invalidate(bindersProvider);
      ref.invalidate(activeProfileProvider);
    } on BinderCapacityException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).notEnoughBankSpaces)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _confirmComplete() async {
    final l10n = AppLocalizations.of(context);
    final released = _maxSlots - widget.occupiedCount;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.completeCollectionButton),
        content: Text(
          l10n.completeCollectionConfirm(widget.occupiedCount, released),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.yesCompleteButton),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    setState(() => _saving = true);
    try {
      final updated = await ref
          .read(binderRepositoryProvider)
          .completeBinder(widget.binder.id);
      _maxSlots = updated.maxSlots;
      _isCompleted = updated.isCompleted;
      ref.invalidate(binderProvider(widget.binder.id));
      ref.invalidate(bindersProvider);
      ref.invalidate(activeProfileProvider);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(binderRepositoryProvider)
          .updateBinder(
            binderId: widget.binder.id,
            title: _titleController.text.trim(),
            gridFormat: _gridFormat,
            isPublic: _isPublic,
          );
      ref.invalidate(binderProvider(widget.binder.id));
      ref.invalidate(bindersProvider);
      if (mounted) {
        Navigator.pop(context, false);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteBinderButton),
        content: Text(l10n.deleteBinderConfirm(widget.binder.title, _maxSlots)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (ok != true) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(binderRepositoryProvider).deleteBinder(widget.binder.id);
      ref.invalidate(bindersProvider);
      ref.invalidate(activeProfileProvider);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
