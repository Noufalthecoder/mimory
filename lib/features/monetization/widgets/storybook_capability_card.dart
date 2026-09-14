import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/mimory_plus_capability.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';

/// Small illustrated storybook card representing an unlocked MIMORY+ capability.
///
/// Embodies the warmth, organic paper texture, and gentle botanical charm
/// of the MIMORY storybook universe.
class StorybookCapabilityCard extends StatelessWidget {
  final MimoryPlusCapability capability;

  const StorybookCapabilityCard({
    super.key,
    required this.capability,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEADBCE),
          width: 1.2,
        ),
        boxShadow: AppTheme.paperShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Illustrated Emblem Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE5D5C2),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: _buildIllustratedIcon(capability.iconType),
          ),
          const SizedBox(width: 14),

          // Feature Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        capability.title,
                        style: GoogleFonts.mali(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '♡',
                      style: GoogleFonts.mali(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  capability.description,
                  style: GoogleFonts.nunito(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustratedIcon(CapabilityIconType type) {
    switch (type) {
      case CapabilityIconType.worlds:
        return const Stack(
          alignment: Alignment.center,
          children: [
            StorybookLeaf(size: 18, angle: -0.2),
            Positioned(
              right: 1,
              bottom: 1,
              child: StorybookSparkle(size: 10),
            ),
          ],
        );
      case CapabilityIconType.environments:
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.wb_sunny_rounded,
              size: 18,
              color: const Color(0xFFF3A37C),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Icon(
                Icons.nightlight_round,
                size: 11,
                color: AppTheme.sageGreen,
              ),
            ),
          ],
        );
      case CapabilityIconType.companions:
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 17,
              color: AppTheme.primaryPink,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: StorybookFlower(size: 10),
            ),
          ],
        );
      case CapabilityIconType.echoes:
        return Icon(
          Icons.graphic_eq_rounded,
          size: 18,
          color: AppTheme.primaryPinkDark,
        );
    }
  }
}
