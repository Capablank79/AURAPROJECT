import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/aura_colors.dart';

enum AuraNavTab { showcases, search, settings }

class AuraBottomBar extends StatelessWidget {
  const AuraBottomBar({
    required this.activeTab,
    required this.onSelected,
    super.key,
  });

  final AuraNavTab activeTab;
  final ValueChanged<AuraNavTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AuraColors.obsidianVoid.withValues(alpha: 0.94),
        border: Border(
          top: BorderSide(
            color: AuraColors.champagneGold.withValues(alpha: 0.16),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIconButton(
                icon: Icons.style_outlined,
                activeIcon: Icons.style,
                tooltip: l10n.navShowcases,
                selected: activeTab == AuraNavTab.showcases,
                onTap: () => onSelected(AuraNavTab.showcases),
              ),
              _NavIconButton(
                icon: Icons.search,
                activeIcon: Icons.search,
                tooltip: l10n.navSearchCollection,
                selected: activeTab == AuraNavTab.search,
                onTap: () => onSelected(AuraNavTab.search),
              ),
              _NavIconButton(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                tooltip: l10n.navSettings,
                selected: activeTab == AuraNavTab.settings,
                onTap: () => onSelected(AuraNavTab.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.activeIcon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: tooltip,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(
          selected ? activeIcon : icon,
          color: selected ? AuraColors.champagneGold : AuraColors.mutedText,
          size: 25,
        ),
      ),
    );
  }
}
