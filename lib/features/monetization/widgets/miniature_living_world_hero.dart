import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/services/world_service.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/widgets/anime_character_widget.dart';

/// A miniature living-world hero illustration designed specifically
/// for the MIMORY+ unlock celebration.
///
/// Features the user's actual selected characters, their environment,
/// a garden rabbit, blooming botanical flora, and an organic 7-stage
/// micro-animation sequence illustrating the core concept:
/// "Your little world just grew. ♡"
class MiniatureLivingWorldHero extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const MiniatureLivingWorldHero({
    super.key,
    this.onAnimationComplete,
  });

  @override
  State<MiniatureLivingWorldHero> createState() =>
      _MiniatureLivingWorldHeroState();
}

class _MiniatureLivingWorldHeroState extends State<MiniatureLivingWorldHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animation Stages (0.0 to 1.0 mapped over 2000ms):
  // 0.0 - 0.2: Quiet world
  // 0.2 - 0.45: Golden light appears & travels path
  // 0.45 - 0.75: Flowers bloom along path
  // 0.65 - 0.90: New memory archway/landmark gently appears
  // 0.85 - 1.0: Particles settle & complete
  late Animation<double> _goldenLightAnimation;
  late Animation<double> _flowerBloomAnimation;
  late Animation<double> _landmarkGrowthAnimation;
  late Animation<double> _particlesSettleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _goldenLightAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.48, curve: Curves.easeInOutCubic),
    );

    _flowerBloomAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.42, 0.76, curve: Curves.elasticOut),
    );

    _landmarkGrowthAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 0.88, curve: Curves.easeOutBack),
    );

    _particlesSettleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.80, 1.0, curve: Curves.easeOut),
    );

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read active characters from WorldService
    final worlds = WorldService().worlds;
    final activeWorld = worlds.isNotEmpty ? worlds.first : null;
    final characters = activeWorld != null
        ? WorldService().getCharactersForWorld(activeWorld.id)
        : <Character>[];

    final userChar = characters.firstWhere(
      (c) => c.isCurrentUser,
      orElse: () => Character(
        id: 'u_default',
        worldId: 'default',
        personName: 'Noufal',
        gender: 'male',
        isCurrentUser: true,
        hairStyle: 'messy_short',
        hairColor: const Color(0xFF3A2E2B),
        skinTone: const Color(0xFFFFDFC4),
        outfitColor: const Color(0xFF7A9E7E),
      ),
    );

    final companionChar = characters.firstWhere(
      (c) => !c.isCurrentUser,
      orElse: () => Character(
        id: 'c_default',
        worldId: 'default',
        personName: 'Companion',
        gender: 'female',
        isCurrentUser: false,
        hairStyle: 'twin_tails',
        hairColor: const Color(0xFF4A3728),
        skinTone: const Color(0xFFFFDFC4),
        outfitColor: const Color(0xFFE8A598),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 190,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F0),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFE5DAC8),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.10),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
              ...AppTheme.paperShadow,
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Illustrated Storybook Landscape Background
              Positioned.fill(
                child: CustomPaint(
                  painter: _MiniatureLandscapePainter(
                    lightProgress: _goldenLightAnimation.value,
                    bloomProgress: _flowerBloomAnimation.value,
                    settleProgress: _particlesSettleAnimation.value,
                  ),
                ),
              ),

              // 2. Existing Memory Landmark (Cozy Storybook Bench on Left)
              Positioned(
                left: 20,
                bottom: 26,
                child: _buildStorybookBench(),
              ),

              // 3. New Memory Landmark Unlocked by MIMORY+ (Floral Trellis Archway on Right)
              Positioned(
                right: 22,
                bottom: 24,
                child: Transform.scale(
                  scale: _landmarkGrowthAnimation.value.clamp(0.0, 1.0),
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: _landmarkGrowthAnimation.value.clamp(0.0, 1.0),
                    child: _buildNewMemoryArch(),
                  ),
                ),
              ),

              // 4. Companion Characters (User & Companion holding hands in center)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // User Character
                      Transform.scale(
                        scale: 0.72,
                        child: AnimeCharacterWidget(
                          character: userChar,
                          isWalking: false,
                          facingRight: true,
                        ),
                      ),
                      // Connected Hands Clasp with Floating Heart
                      Transform.translate(
                        offset: const Offset(0, -18),
                        child: Text(
                          '♡',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryPink.withValues(
                              alpha: 0.85 + (0.15 * math.sin(_controller.value * math.pi * 3)),
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Companion Character
                      Transform.scale(
                        scale: 0.72,
                        child: AnimeCharacterWidget(
                          character: companionChar,
                          isWalking: false,
                          facingRight: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Living Garden Rabbit hopping nearby
              Positioned(
                left: 92,
                bottom: 24,
                child: _buildGardenRabbit(),
              ),

              // 6. Traveling Golden Sparkle Particle
              if (_goldenLightAnimation.value > 0.05 && _particlesSettleAnimation.value < 0.98)
                Positioned(
                  left: 60 + (160 * _goldenLightAnimation.value),
                  bottom: 35 + (18 * math.sin(_goldenLightAnimation.value * math.pi * 2)),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD56B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFCC33).withValues(alpha: 0.9),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),

              // 7. Soft Decorative Storybook Corner Leaves
              const Positioned(
                top: 10,
                left: 12,
                child: StorybookLeaf(size: 16, angle: 0.4),
              ),
              const Positioned(
                top: 10,
                right: 12,
                child: StorybookSparkle(size: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Miniature storybook wooden bench with book
  Widget _buildStorybookBench() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tiny wildflower behind bench
        Container(
          width: 28,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFE2CBB2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF9E7E65), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 3, height: 12, color: const Color(0xFF9E7E65)),
              const SizedBox(width: 8),
              Container(width: 3, height: 12, color: const Color(0xFF9E7E65)),
            ],
          ),
        ),
        Container(
          width: 34,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFB59374),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  /// The new memory landmark that blooms during the MIMORY+ unlock
  Widget _buildNewMemoryArch() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tiny wooden flower trellis arch
        Container(
          width: 36,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            border: Border.all(color: const Color(0xFF9E7E65), width: 2.2),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Little hanging heart lantern
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 10,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),
              // Tiny blooming roses on arch
              const Positioned(
                top: 8,
                left: -3,
                child: StorybookFlower(size: 10),
              ),
              const Positioned(
                top: 18,
                right: -3,
                child: StorybookFlower(size: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Cute little garden bunny with fluffy ears
  Widget _buildGardenRabbit() {
    final hop = math.sin(_controller.value * math.pi * 6).abs() * 3.5;
    return Transform.translate(
      offset: Offset(0, -hop),
      child: SizedBox(
        width: 18,
        height: 20,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Body
            Container(
              width: 13,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFDED0C0), width: 0.8),
              ),
            ),
            // Ears
            Positioned(
              top: 0,
              left: 3,
              child: Container(
                width: 3,
                height: 9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFFDED0C0), width: 0.6),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 7,
              child: Container(
                width: 3,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFFDED0C0), width: 0.6),
                ),
              ),
            ),
            // Pink cheek
            Positioned(
              bottom: 4,
              right: 3,
              child: Container(
                width: 2.5,
                height: 2.5,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering the soft watercolor rolling hills,
/// winding cobblestone path, and blooming wildflowers.
class _MiniatureLandscapePainter extends CustomPainter {
  final double lightProgress;
  final double bloomProgress;
  final double settleProgress;

  _MiniatureLandscapePainter({
    required this.lightProgress,
    required this.bloomProgress,
    required this.settleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft Storybook Sky Gradient (Warm morning peach to light ivory)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFDFBF7),
          Color(0xFFF7F1E6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Distant Soft Green Rolling Hill
    final hillPath1 = Path()
      ..moveTo(0, size.height * 0.68)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.52,
        size.width,
        size.height * 0.64,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final hillPaint1 = Paint()..color = const Color(0xFFD9E7CE);
    canvas.drawPath(hillPath1, hillPaint1);

    // 3. Foreground Grassy Ground (Warm Storybook Green)
    final groundPath = Path()
      ..moveTo(0, size.height * 0.74)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.68,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final groundPaint = Paint()..color = const Color(0xFFBFD8AC);
    canvas.drawPath(groundPath, groundPaint);

    // 4. Winding Gentle Cobblestone Path
    final pathPaint = Paint()
      ..color = const Color(0xFFE9DEC9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final roadPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.82,
        size.width * 0.88,
        size.height * 0.88,
      );
    canvas.drawPath(roadPath, pathPaint);

    // 5. Blooming Wildflowers along the path
    final flowerPaint = Paint()..color = const Color(0xFFE8998D);
    final centerPaint = Paint()..color = const Color(0xFFFFDD67);
    final leafPaint = Paint()..color = const Color(0xFF7FA872);

    final flowerLocations = [
      Offset(size.width * 0.22, size.height * 0.76),
      Offset(size.width * 0.36, size.height * 0.73),
      Offset(size.width * 0.64, size.height * 0.73),
      Offset(size.width * 0.78, size.height * 0.77),
    ];

    for (int i = 0; i < flowerLocations.length; i++) {
      final loc = flowerLocations[i];
      final flowerScale = (bloomProgress * 1.15 - (i * 0.08)).clamp(0.0, 1.0);
      if (flowerScale > 0) {
        // Little stem
        canvas.drawLine(
          loc,
          Offset(loc.dx, loc.dy + 8),
          leafPaint..strokeWidth = 1.6,
        );
        // Petals
        canvas.drawCircle(loc, 4.0 * flowerScale, flowerPaint);
        canvas.drawCircle(loc, 1.8 * flowerScale, centerPaint);
      }
    }

    // 6. Subtle Golden Sparkle Stardust
    if (settleProgress > 0.3) {
      final particlePaint = Paint()
        ..color = const Color(0xFFFFD166).withValues(alpha: 0.65 * (1.0 - settleProgress * 0.3));
      final particles = [
        Offset(size.width * 0.28, size.height * 0.42),
        Offset(size.width * 0.52, size.height * 0.34),
        Offset(size.width * 0.74, size.height * 0.46),
        Offset(size.width * 0.42, size.height * 0.50),
      ];
      for (final p in particles) {
        canvas.drawCircle(p, 1.6, particlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniatureLandscapePainter oldDelegate) {
    return oldDelegate.lightProgress != lightProgress ||
        oldDelegate.bloomProgress != bloomProgress ||
        oldDelegate.settleProgress != settleProgress;
  }
}
