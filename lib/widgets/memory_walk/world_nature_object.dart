import 'package:flutter/material.dart';
import 'package:mimory/core/theme/app_theme.dart';

enum NatureObjectType {
  treeLarge,
  treeSmall,
  bush,
  flowerPatch,
  rock,
}

/// A natural environmental feature (tree, bush, flower, rock) in the 3D world.
class WorldNatureObjectWidget extends StatelessWidget {
  final NatureObjectType type;
  final double scale;

  const WorldNatureObjectWidget({
    super.key,
    required this.type,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveScale = scale.clamp(0.35, 2.4);

    return Transform.scale(
      scale: effectiveScale,
      alignment: Alignment.bottomCenter,
      child: _buildObject(),
    );
  }

  Widget _buildObject() {
    switch (type) {
      case NatureObjectType.treeLarge:
        return SizedBox(
          width: 74,
          height: 94,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Shadow
              Positioned(
                bottom: 0,
                child: Container(
                  width: 52,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E4624).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Trunk
              Positioned(
                bottom: 2,
                child: Container(
                  width: 14,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5A2B),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Foliage Bottom Layer
              Positioned(
                bottom: 26,
                child: Container(
                  width: 68,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B9955),
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
              // Foliage Top Layer
              Positioned(
                bottom: 40,
                child: Container(
                  width: 54,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7FA86D),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              // Blossom / Fruit accents
              Positioned(
                bottom: 46,
                left: 18,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 56,
                right: 20,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );

      case NatureObjectType.treeSmall:
        return SizedBox(
          width: 52,
          height: 68,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Shadow
              Positioned(
                bottom: 0,
                child: Container(
                  width: 36,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E4624).withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              // Trunk
              Positioned(
                bottom: 2,
                child: Container(
                  width: 9,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5A2B),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Foliage
              Positioned(
                bottom: 20,
                child: Container(
                  width: 46,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF78A766),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        );

      case NatureObjectType.bush:
        return SizedBox(
          width: 38,
          height: 24,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 0,
                child: Container(
                  width: 34,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E4624).withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                child: Container(
                  width: 36,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B9B5C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );

      case NatureObjectType.flowerPatch:
        return SizedBox(
          width: 38,
          height: 18,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.local_florist_rounded, size: 10, color: AppTheme.primaryPink),
                SizedBox(width: 2),
                Icon(Icons.local_florist_rounded, size: 12, color: Color(0xFFFFD166)),
                SizedBox(width: 2),
                Icon(Icons.local_florist_rounded, size: 9, color: AppTheme.primaryPink),
              ],
            ),
          ),
        );

      case NatureObjectType.rock:
        return SizedBox(
          width: 24,
          height: 14,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFB0A596),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF8C8274),
                width: 0.8,
              ),
            ),
          ),
        );
    }
  }
}
