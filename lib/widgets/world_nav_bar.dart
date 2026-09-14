import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/core/theme/app_theme.dart';

enum WorldNavTab { world, memories, timeline }

/// Subtle organic storybook bottom navigation bar keeping the Living World dominant.
class WorldNavBar extends StatelessWidget {
  final WorldNavTab activeTab;
  final ValueChanged<WorldNavTab> onTabSelected;

  const WorldNavBar({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.creamLight.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1.2,
        ),
        boxShadow: AppTheme.paperShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildItem(
            tab: WorldNavTab.world,
            label: 'World',
            icon: Icons.park_outlined,
          ),
          const SizedBox(width: 4),
          _buildItem(
            tab: WorldNavTab.memories,
            label: 'Memories',
            icon: Icons.collections_bookmark_outlined,
          ),
          const SizedBox(width: 4),
          _buildItem(
            tab: WorldNavTab.timeline,
            label: 'Timeline',
            icon: Icons.history_edu_outlined,
            isPlaceholder: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required WorldNavTab tab,
    required String label,
    required IconData icon,
    bool isPlaceholder = false,
  }) {
    final isSelected = activeTab == tab;

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPinkLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppTheme.primaryPinkDark
                  : (isPlaceholder
                      ? AppTheme.textTertiary
                      : AppTheme.textSecondary),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPinkDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
