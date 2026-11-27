import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/profile_model.dart';
import '../../../../core/theme/aura_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../binder/providers/binder_providers.dart';

class ProfileIdentityCard extends ConsumerWidget {
  const ProfileIdentityCard({required this.profile, super.key});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final contact = profile.tradeContact;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    AuraColors.solarGold.withValues(alpha: 0.28),
                    AuraColors.manaCyan.withValues(alpha: 0.18),
                  ],
                ),
                border: Border.all(
                  color: AuraColors.solarGold.withValues(alpha: 0.7),
                ),
              ),
              child: Text(
                profile.initials,
                style: const TextStyle(
                  color: AuraColors.solarGold,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile.displayName ?? profile.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: profile.isPro
                                ? AuraColors.solarGold
                                : AuraColors.champagneGold.withValues(
                                    alpha: 0.35,
                                  ),
                          ),
                        ),
                        child: Text(
                          profile.isPro
                              ? l10n.proPlanLabel
                              : l10n.freePlanLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: profile.isPro
                                ? AuraColors.solarGold
                                : AuraColors.champagneGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '@${profile.username}',
                        style: const TextStyle(
                          color: AuraColors.silverMuted,
                          fontSize: 12,
                        ),
                      ),
                      if (contact != null && contact.isNotEmpty)
                        Text(
                          '💬 $contact',
                          style: const TextStyle(
                            color: AuraColors.manaCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.editProfileButton,
              onPressed: () => _showEditDialog(context, ref),
              icon: const Icon(
                Icons.edit_outlined,
                size: 19,
                color: AuraColors.champagneGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(
      text: profile.displayName ?? profile.username,
    );
    final contactCtrl = TextEditingController(text: profile.tradeContact ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AuraColors.smokedCharcoal,
        title: Text(l10n.editProfileButton),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: l10n.displayNameLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contactCtrl,
              decoration: InputDecoration(
                labelText: l10n.tradeContactLabel,
                helperText: l10n.tradeContactHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.saveChangesButton),
          ),
        ],
      ),
    );
    if (saved != true) {
      return;
    }
    await ref
        .read(binderRepositoryProvider)
        .updateProfileIdentity(
          displayName: nameCtrl.text,
          tradeContact: contactCtrl.text,
        );
    ref.invalidate(activeProfileProvider);
  }
}
