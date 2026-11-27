import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/aura_colors.dart';

enum AuraNavTab { showcases, search, decks, settings }

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
        color: AuraColors.obsidianVoid.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: AuraColors.champagneGold.withValues(alpha: 0.18),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              Expanded(
                child: _NavTabButton(
                  icon: Icons.style_outlined,
                  activeIcon: Icons.style,
                  label: l10n.navShowcases,
                  selected: activeTab == AuraNavTab.showcases,
                  onTap: () => onSelected(AuraNavTab.showcases),
                ),
              ),
              Expanded(
                child: _NavTabButton(
                  icon: Icons.search,
                  activeIcon: Icons.search,
                  label: l10n.modeSearchLabel,
                  selected: activeTab == AuraNavTab.search,
                  onTap: () => onSelected(AuraNavTab.search),
                ),
              ),
              Expanded(
                child: _NavTabButton(
                  icon: Icons.layers_outlined,
                  activeIcon: Icons.layers,
                  label: l10n.navDecks,
                  selected: activeTab == AuraNavTab.decks,
                  onTap: () => onSelected(AuraNavTab.decks),
                ),
              ),
              Expanded(
                child: _NavTabButton(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: l10n.navSettings,
                  selected: activeTab == AuraNavTab.settings,
                  onTap: () => onSelected(AuraNavTab.settings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AuraColors.solarGold : AuraColors.mutedText;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? activeIcon : icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
