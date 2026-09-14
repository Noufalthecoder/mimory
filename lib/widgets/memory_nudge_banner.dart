import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';

/// Gentle, peaceful memory nudge banner designed for MIMORY storybook language.
/// Never manipulative or urgent; always warm and emotional.
class MemoryNudgeBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const MemoryNudgeBanner({
    super.key,
    this.message = 'Your world has been a little quiet. ♡',
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.creamLight.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.primaryPink.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: AppTheme.paperShadow,
        ),
        child: Row(
          children: [
            const StorybookFlower(size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.mali(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (onDismiss != null)
              GestureDetector(
                onTap: onDismiss,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
