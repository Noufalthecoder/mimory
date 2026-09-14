import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/services/revenue_cat_service.dart';
import 'package:mimory/features/monetization/screens/mimory_plus_paywall.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';

/// Charming, compact illustrated storybook header displaying World identity
/// without obscuring the living miniature landscape.
class WorldHeader extends StatelessWidget {
  final World world;
  final int memoryCount;
  final VoidCallback? onBack;

  const WorldHeader({
    super.key,
    required this.world,
    required this.memoryCount,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final countLabel = memoryCount == 0
        ? 'A waiting world'
        : memoryCount == 1
            ? '1 little moment'
            : '$memoryCount little moments';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppTheme.creamLight.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1.2,
        ),
        boxShadow: AppTheme.paperShadow,
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.borderSubtle,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 17,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const StorybookLeaf(size: 14, angle: -0.2),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        world.name,
                        style: GoogleFonts.mali(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '♡',
                      style: GoogleFonts.mali(
                        fontSize: 13,
                        color: AppTheme.primaryPink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'with ${world.personName.toLowerCase()}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppTheme.borderSubtle,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        countLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: memoryCount > 0
                              ? AppTheme.sageGreen
                              : AppTheme.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ListenableBuilder(
            listenable: RevenueCatService(),
            builder: (context, _) {
              final isPlus = RevenueCatService().isMimoryPlusActive();
              return GestureDetector(
                onTap: () => MimoryPlusPaywall.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPlus
                        ? AppTheme.primaryPink.withValues(alpha: 0.12)
                        : AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPlus ? AppTheme.primaryPink : AppTheme.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isPlus ? 'PLUS ♡' : '✦ PLUS',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isPlus ? AppTheme.primaryPink : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
