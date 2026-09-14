import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/core/theme/app_theme.dart';

/// Handcrafted storybook wooden direction board planted in the 3D world.
/// Shows cute destinations like:
/// [ 📷 MEETUP → ] or [ 🌸 FIRST TRIP ← ] or [ 🌱 EXPLORE ↑ ]
/// Architected with FittedBox and flexible constraints to guarantee ZERO overflow.
class DirectionSignboardWidget extends StatelessWidget {
  final String label;
  final String arrow;
  final double scale;

  const DirectionSignboardWidget({
    super.key,
    required this.label,
    required this.arrow,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveScale = scale.clamp(0.40, 2.2);

    return Transform.scale(
      scale: effectiveScale,
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 150, minWidth: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Wooden Plank with Arrow & Label (FittedBox guarantees zero overflow)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD7A769), // Warm carved wood
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: const Color(0xFF966333),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Little wooden nail
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5A3818),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$label $arrow',
                      style: GoogleFonts.mali(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A280B),
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(width: 5),
                    // Little pink flower decoration
                    const Icon(
                      Icons.local_florist_rounded,
                      size: 8,
                      color: AppTheme.primaryPink,
                    ),
                  ],
                ),
              ),
            ),

            // 2. Wooden Post with climbing vine
            SizedBox(
              width: 20,
              height: 32,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Wooden Post
                  Container(
                    width: 6,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5A2B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Vines
                  Positioned(
                    top: 6,
                    left: 2,
                    child: Container(
                      width: 3.5,
                      height: 3.5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6B9B58),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 2,
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7FA86D),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Ground Shadow
            Container(
              width: 24,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF334A29).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
