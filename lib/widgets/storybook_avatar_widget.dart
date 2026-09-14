import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/avatar_definition.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/widgets/anime_character_widget.dart';

/// Beautiful storybook avatar card/portrait with soft illustrated frames,
/// subtle scale-up on selection, soft pink outline, and botanical/sparkle accents.
class StorybookAvatarWidget extends StatelessWidget {
  final AvatarDefinition avatar;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;
  final String? subtitle;
  final bool showLabel;

  const StorybookAvatarWidget({
    super.key,
    required this.avatar,
    this.isSelected = false,
    this.onTap,
    this.size = 76,
    this.subtitle,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    // Generate dummy character instance for preview rendering
    final previewChar = avatar.toCharacter(
      id: 'preview_${avatar.id}',
      worldId: 'preview',
      personName: avatar.name,
      isCurrentUser: false,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.07 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Soft Illustrated Frame
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryPinkLight
                        : AppTheme.creamLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryPink
                          : const Color(0xFFE2CDBA),
                      width: isSelected ? 2.6 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryPink.withValues(alpha: 0.28),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                            ...AppTheme.paperShadow,
                          ]
                        : AppTheme.paperShadow,
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: size / 42.0,
                      child: AnimeCharacterWidget(
                        character: previewChar,
                        isWalking: false,
                        facingRight: true,
                      ),
                    ),
                  ),
                ),

                // Tiny botanical flower/sparkle accent when selected
                if (isSelected) ...[
                  const Positioned(
                    top: -2,
                    right: -2,
                    child: StorybookSparkle(size: 16),
                  ),
                  const Positioned(
                    bottom: -2,
                    left: -2,
                    child: StorybookFlower(size: 14),
                  ),
                ],
              ],
            ),
            if (showLabel) ...[
              const SizedBox(height: 6),
              Text(
                avatar.name,
                style: GoogleFonts.mali(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? AppTheme.primaryPinkDark
                      : AppTheme.textPrimary,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
