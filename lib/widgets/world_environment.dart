import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/widgets/world_character.dart';

/// The Living World illustrated environment.
/// Renders a multi-layered storybook countryside park with wide winding road,
/// layered rolling grass knolls, wildflowers, fluttering butterflies, and ambient particles.
class WorldEnvironment extends StatefulWidget {
  final World world;
  final int memoryCount;

  const WorldEnvironment({
    super.key,
    required this.world,
    required this.memoryCount,
  });

  @override
  State<WorldEnvironment> createState() => _WorldEnvironmentState();

  // Modular layer builders for WorldCamera parallax

  static Widget buildSky(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.35, 0.6, 1.0],
          colors: [
            Color(0xFFFFF8F0), // Soft warm sunrise cream
            Color(0xFFFFECE5), // Gentle peach blush
            Color(0xFFF9F1E6), // Atmospheric mist
            Color(0xFFE8F2E6), // Sage reflection
          ],
        ),
      ),
      child: Stack(
        children: [
          // Soft Golden Sun Glow
          Positioned(
            top: height * 0.08,
            right: width * 0.15,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFF9E6).withValues(alpha: 0.95),
                    const Color(0xFFFFECC7).withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildClouds(double width, double height, double progress) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CloudsPainter(progress: progress),
    );
  }

  static Widget buildDistantHills(double width, double height) {
    return CustomPaint(
      size: Size(width, height),
      painter: _DistantHillsPainter(),
    );
  }

  static Widget buildMidgroundHills(double width, double height, int memoryCount) {
    return CustomPaint(
      size: Size(width, height),
      painter: _MidgroundHillsPainter(memoryCount: memoryCount),
    );
  }

  static Widget buildWalkingMeadow(double width, double height, int memoryCount) {
    return CustomPaint(
      size: Size(width, height),
      painter: _ForegroundMeadowPainter(memoryCount: memoryCount),
    );
  }

  static Widget buildForegroundAtmosphere(
      double width, double height, double progress, int memoryCount) {
    return CustomPaint(
      size: Size(width, height),
      painter: _FloatingParticlesPainter(
        progress: progress,
        memoryCount: memoryCount,
      ),
    );
  }
}

class _WorldEnvironmentState extends State<WorldEnvironment>
    with SingleTickerProviderStateMixin {
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          fit: StackFit.expand,
          children: [
            WorldEnvironment.buildSky(width, height),
            AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) => WorldEnvironment.buildClouds(
                  width, height, _ambientController.value),
            ),
            WorldEnvironment.buildDistantHills(width, height),
            WorldEnvironment.buildMidgroundHills(width, height, widget.memoryCount),
            Positioned(
              top: height * 0.32,
              left: width * 0.5 - 45,
              child: _buildRelationshipClearing(context),
            ),
            WorldEnvironment.buildWalkingMeadow(width, height, widget.memoryCount),
            AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) => WorldEnvironment.buildForegroundAtmosphere(
                  width, height, _ambientController.value, widget.memoryCount),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRelationshipClearing(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WorldCharacter(
          world: widget.world,
          size: 64,
        ),
        const SizedBox(height: 4),
        CustomPaint(
          size: const Size(60, 24),
          painter: _CozyBenchPainter(),
        ),
      ],
    );
  }
}

/// Custom painter for soft drifting storybook clouds
class _CloudsPainter extends CustomPainter {
  final double progress;

  _CloudsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    // Cloud 1
    final cloud1X = ((progress * size.width * 1.2) % (size.width + 160)) - 80;
    _drawCloud(canvas, cloud1X, size.height * 0.12, 70, 24, cloudPaint);

    // Cloud 2
    final cloud2X = (((progress * 0.8 + 0.4) * size.width * 1.1) %
            (size.width + 180)) -
        90;
    _drawCloud(canvas, cloud2X, size.height * 0.20, 85, 28, cloudPaint);

    // Cloud 3
    final cloud3X = (((progress * 0.6 + 0.7) * size.width * 1.0) %
            (size.width + 120)) -
        60;
    _drawCloud(canvas, cloud3X, size.height * 0.16, 55, 18, cloudPaint);

    // Gentle Storybook Birds gliding softly in the sky
    final birdPaint = Paint()
      ..color = const Color(0xFF8D8177).withValues(alpha: 0.38)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bird1X = (((progress * 0.45 + 0.2) * size.width * 1.2) %
            (size.width + 80)) -
        40;
    final bird1Y = size.height * 0.11 + math.sin(progress * math.pi * 4) * 4;
    _drawBird(canvas, bird1X, bird1Y, 10, birdPaint);

    final bird2X = bird1X - 18;
    final bird2Y = bird1Y + 7;
    _drawBird(canvas, bird2X, bird2Y, 7.5, birdPaint);
  }

  void _drawBird(
      Canvas canvas, double x, double y, double span, Paint paint) {
    final wing = span / 2;
    final path = Path();
    path.moveTo(x - wing, y);
    path.quadraticBezierTo(x - wing * 0.5, y - 4, x, y);
    path.quadraticBezierTo(x + wing * 0.5, y - 4, x + wing, y);
    canvas.drawPath(path, paint);
  }

  void _drawCloud(Canvas canvas, double x, double y, double width, double height,
      Paint paint) {
    final r = height / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, height),
        Radius.circular(r),
      ),
      paint,
    );
    canvas.drawCircle(Offset(x + width * 0.35, y + 2), r * 1.1, paint);
    canvas.drawCircle(Offset(x + width * 0.62, y - 1), r * 1.3, paint);
  }

  @override
  bool shouldRepaint(covariant _CloudsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Custom painter for distant rolling lavender-sage hills
class _DistantHillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hillPaint = Paint()
      ..color = const Color(0xFFD6E2D5).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path();
    final startY = size.height * 0.38;
    path.moveTo(0, startY);

    path.quadraticBezierTo(
      size.width * 0.25,
      startY - 25,
      size.width * 0.55,
      startY + 8,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      startY + 35,
      size.width,
      startY - 15,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, hillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for midground hills and environmental trees
class _MidgroundHillsPainter extends CustomPainter {
  final int memoryCount;

  _MidgroundHillsPainter({required this.memoryCount});

  @override
  void paint(Canvas canvas, Size size) {
    final midHillPaint = Paint()
      ..color = const Color(0xFFBED4BE).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final path = Path();
    final startY = size.height * 0.44;
    path.moveTo(0, startY + 20);

    path.quadraticBezierTo(
      size.width * 0.35,
      startY - 30,
      size.width * 0.68,
      startY + 15,
    );
    path.quadraticBezierTo(
      size.width * 0.88,
      startY + 40,
      size.width,
      startY - 5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, midHillPaint);

    // Left Gentle Tree
    _drawStorybookTree(canvas, size.width * 0.12, startY - 15, 42, 60,
        const Color(0xFF8BAE8E), const Color(0xFF7A9F7D));

    // Right Tree
    _drawStorybookTree(canvas, size.width * 0.88, startY + 5, 38, 54,
        const Color(0xFF96B899), const Color(0xFF83A786));

    if (memoryCount >= 3) {
      _drawStorybookTree(canvas, size.width * 0.28, startY + 5, 32, 46,
          const Color(0xFFA5C5A8), const Color(0xFF90B593));
    }
  }

  void _drawStorybookTree(Canvas canvas, double x, double y, double radius,
      double height, Color leafColor, Color shadowColor) {
    // Soft ground shadow under tree
    final shadowPaint = Paint()
      ..color = const Color(0xFF385E3B).withValues(alpha: 0.12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y + height + 2),
        width: radius * 1.5,
        height: 10,
      ),
      shadowPaint,
    );

    // Trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF967E68)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, y), Offset(x, y + height), trunkPaint);

    // Foliage Clusters
    final leafPaint = Paint()..color = leafColor;
    final leafShadowPaint = Paint()..color = shadowColor;

    canvas.drawCircle(Offset(x - 6, y - 6), radius * 0.6, leafShadowPaint);
    canvas.drawCircle(Offset(x + 8, y - 4), radius * 0.65, leafPaint);
    canvas.drawCircle(Offset(x, y - 18), radius * 0.7, leafPaint);
  }

  @override
  bool shouldRepaint(covariant _MidgroundHillsPainter oldDelegate) =>
      oldDelegate.memoryCount != memoryCount;
}

/// Rich foreground rolling countryside meadow with wide textured road,
/// grass tufts, stone edges, and wildflowers
class _ForegroundMeadowPainter extends CustomPainter {
  final int memoryCount;

  _ForegroundMeadowPainter({required this.memoryCount});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Layer 1: Upper Meadow Knoll
    final knollPaint = Paint()
      ..color = const Color(0xFFAECDAA)
      ..style = PaintingStyle.fill;
    final knollPath = Path();
    final kY = size.height * 0.50;
    knollPath.moveTo(0, kY + 10);
    knollPath.quadraticBezierTo(
      size.width * 0.35,
      kY - 20,
      size.width * 0.75,
      kY + 15,
    );
    knollPath.lineTo(size.width, kY + 30);
    knollPath.lineTo(size.width, size.height);
    knollPath.lineTo(0, size.height);
    knollPath.close();
    canvas.drawPath(knollPath, knollPaint);

    // 2. Layer 2: Main Rolling Meadow Floor
    final meadowPaint = Paint()
      ..color = const Color(0xFFA1C29E) // Soft lush sage meadow
      ..style = PaintingStyle.fill;

    final meadowPath = Path();
    final startY = size.height * 0.53;
    meadowPath.moveTo(0, startY);
    meadowPath.quadraticBezierTo(
      size.width * 0.45,
      startY - 25,
      size.width * 0.82,
      startY + 15,
    );
    meadowPath.quadraticBezierTo(
      size.width * 0.94,
      startY + 25,
      size.width,
      startY + 10,
    );
    meadowPath.lineTo(size.width, size.height);
    meadowPath.lineTo(0, size.height);
    meadowPath.close();
    canvas.drawPath(meadowPath, meadowPaint);

    // 3. Wide Winding Countryside Pebble Road with Perspective
    _drawWideWindingRoad(canvas, size);

    // 4. Grass Tufts & Tiny Stepping Stones
    _drawMeadowDetails(canvas, size);

    // 5. Environmental Growth Elements based on memoryCount
    _drawGrowthElements(canvas, size);
  }

  void _drawWideWindingRoad(Canvas canvas, Size size) {
    final startY = size.height * 0.48;

    // Road Outer Soft Shadow / Edge Line
    final edgePaint = Paint()
      ..color = const Color(0xFFDCCDB9).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Road Surface Paint (Soft Warm Cream Gravel)
    final roadPaint = Paint()
      ..color = const Color(0xFFF6EFE3).withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Outer Edge (wider)
    edgePaint.strokeWidth = 38.0;
    roadPaint.strokeWidth = 34.0;

    final trail = Path();
    trail.moveTo(size.width * 0.5, startY + 16);
    trail.quadraticBezierTo(
      size.width * 0.40,
      size.height * 0.65,
      size.width * 0.54,
      size.height * 0.82,
    );
    trail.quadraticBezierTo(
      size.width * 0.60,
      size.height * 0.92,
      size.width * 0.48,
      size.height + 30,
    );

    canvas.drawPath(trail, edgePaint);
    canvas.drawPath(trail, roadPaint);

    // Little smooth pebbles along road edges
    final pebblePaint = Paint()..color = const Color(0xFFDCC8B3);
    canvas.drawCircle(Offset(size.width * 0.43, size.height * 0.64), 2.5, pebblePaint);
    canvas.drawCircle(Offset(size.width * 0.47, size.height * 0.70), 3.0, pebblePaint);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.84), 3.5, pebblePaint);
    canvas.drawCircle(Offset(size.width * 0.51, size.height * 0.90), 4.0, pebblePaint);
  }

  void _drawMeadowDetails(Canvas canvas, Size size) {
    final tuftPaint = Paint()
      ..color = const Color(0xFF8BAF89)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Scattered cute grass blades
    _drawGrassTuft(canvas, size.width * 0.18, size.height * 0.58, tuftPaint);
    _drawGrassTuft(canvas, size.width * 0.72, size.height * 0.56, tuftPaint);
    _drawGrassTuft(canvas, size.width * 0.34, size.height * 0.78, tuftPaint);
    _drawGrassTuft(canvas, size.width * 0.66, size.height * 0.80, tuftPaint);
    _drawGrassTuft(canvas, size.width * 0.84, size.height * 0.68, tuftPaint);
  }

  void _drawGrassTuft(Canvas canvas, double x, double y, Paint paint) {
    canvas.drawLine(Offset(x, y), Offset(x - 3, y - 6), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y - 8), paint);
    canvas.drawLine(Offset(x, y), Offset(x + 3, y - 6), paint);
  }

  void _drawGrowthElements(Canvas canvas, Size size) {
    // 0 Memories
    if (memoryCount == 0) {
      _drawSprout(canvas, size.width * 0.5, size.height * 0.68, 14);
      return;
    }

    // 1+ Memories: 1st blooming pink flower cluster
    if (memoryCount >= 1) {
      _drawFlower(
        canvas,
        size.width * 0.30,
        size.height * 0.66,
        AppTheme.primaryPink,
        10,
      );
      _drawFlower(
        canvas,
        size.width * 0.35,
        size.height * 0.69,
        const Color(0xFFFFD5DC),
        8,
      );
      _drawSprout(canvas, size.width * 0.28, size.height * 0.64, 12);
    }

    // 2+ Memories: Lavender & Peach blossoms
    if (memoryCount >= 2) {
      _drawFlower(
        canvas,
        size.width * 0.68,
        size.height * 0.70,
        const Color(0xFFE4C1F9),
        9,
      );
      _drawFlower(
        canvas,
        size.width * 0.74,
        size.height * 0.73,
        const Color(0xFFFFDFBA),
        8,
      );
      _drawSprout(canvas, size.width * 0.76, size.height * 0.68, 14);
    }

    // 3+ Memories: Buttercups & Clover
    if (memoryCount >= 3) {
      _drawFlower(
        canvas,
        size.width * 0.20,
        size.height * 0.82,
        AppTheme.primaryPink,
        11,
      );
      _drawFlower(
        canvas,
        size.width * 0.25,
        size.height * 0.85,
        const Color(0xFFFFF275),
        8,
      );
      _drawFlower(
        canvas,
        size.width * 0.78,
        size.height * 0.86,
        const Color(0xFFFFD5DC),
        10,
      );
    }

    // 4+ Memories: Blooming garden meadow
    if (memoryCount >= 4) {
      _drawFlower(
        canvas,
        size.width * 0.42,
        size.height * 0.88,
        const Color(0xFFE4C1F9),
        9,
      );
      _drawFlower(
        canvas,
        size.width * 0.58,
        size.height * 0.89,
        AppTheme.primaryPink,
        10,
      );
      _drawFlower(
        canvas,
        size.width * 0.15,
        size.height * 0.74,
        const Color(0xFFFFDFBA),
        9,
      );
    }
  }

  void _drawSprout(Canvas canvas, double x, double y, double size) {
    final stemPaint = Paint()
      ..color = const Color(0xFF729974)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, y), Offset(x, y - size), stemPaint);

    final leafPaint = Paint()..color = const Color(0xFF86B089);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x - size * 0.4, y - size * 0.8),
        width: size * 0.8,
        height: size * 0.4,
      ),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x + size * 0.4, y - size * 0.9),
        width: size * 0.8,
        height: size * 0.4,
      ),
      leafPaint,
    );
  }

  void _drawFlower(
      Canvas canvas, double x, double y, Color petalColor, double radius) {
    final stemPaint = Paint()
      ..color = const Color(0xFF729974)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, y + radius), Offset(x, y), stemPaint);

    final petalPaint = Paint()..color = petalColor;
    const numPetals = 5;
    for (int i = 0; i < numPetals; i++) {
      final angle = (i * 2 * math.pi) / numPetals;
      final px = x + math.cos(angle) * (radius * 0.6);
      final py = y + math.sin(angle) * (radius * 0.6);
      canvas.drawCircle(Offset(px, py), radius * 0.5, petalPaint);
    }

    final centerPaint = Paint()..color = const Color(0xFFFFE066);
    canvas.drawCircle(Offset(x, y), radius * 0.35, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _ForegroundMeadowPainter oldDelegate) =>
      oldDelegate.memoryCount != memoryCount;
}

class _CozyBenchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final woodPaint = Paint()
      ..color = const Color(0xFF9E846E)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.45),
      Offset(size.width * 0.85, size.height * 0.45),
      woodPaint,
    );

    final legPaint = Paint()
      ..color = const Color(0xFF7D6450)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.45),
      Offset(size.width * 0.22, size.height * 0.95),
      legPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.45),
      Offset(size.width * 0.78, size.height * 0.95),
      legPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating petals, ambient sparkles, and cute fluttering storybook butterflies
class _FloatingParticlesPainter extends CustomPainter {
  final double progress;
  final int memoryCount;

  _FloatingParticlesPainter({
    required this.progress,
    required this.memoryCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final particleCount = memoryCount >= 4 ? 12 : 6;

    for (int i = 0; i < particleCount; i++) {
      final seed = i * 1.618;
      final speed = 0.5 + (i % 3) * 0.25;
      final currentT = (progress * speed + seed) % 1.0;

      final x = (size.width * (1.1 - currentT * 1.2) +
              math.sin(currentT * math.pi * 4 + i) * 20) %
          size.width;
      final y = (size.height * 0.2 + currentT * size.height * 0.7) %
          (size.height * 0.95);

      final isPetal = i % 2 == 0;
      if (isPetal) {
        final petalPaint = Paint()
          ..color = AppTheme.primaryPink.withValues(alpha: 0.45);
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(currentT * math.pi * 2);
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 7, height: 4),
          petalPaint,
        );
        canvas.restore();
      } else {
        final sparklePaint = Paint()
          ..color = const Color(0xFFFFEAA7).withValues(alpha: 0.6);
        canvas.drawCircle(Offset(x, y), 2.2, sparklePaint);
      }
    }

    // Fluttering Storybook Butterflies
    _drawButterfly(
      canvas,
      size.width * 0.22 + math.sin(progress * math.pi * 6) * 14,
      size.height * 0.62 + math.cos(progress * math.pi * 6) * 10,
      const Color(0xFFFFC6D9),
      progress,
    );

    if (memoryCount >= 2) {
      _drawButterfly(
        canvas,
        size.width * 0.72 + math.cos((progress + 0.5) * math.pi * 5) * 16,
        size.height * 0.71 + math.sin((progress + 0.5) * math.pi * 5) * 12,
        const Color(0xFFC7E2FE),
        progress + 0.3,
      );
    }
  }

  void _drawButterfly(
      Canvas canvas, double x, double y, Color wingColor, double t) {
    final flap = (math.sin(t * math.pi * 14) * 0.45).abs() + 0.55;
    final wingPaint = Paint()..color = wingColor.withValues(alpha: 0.85);

    canvas.save();
    canvas.translate(x, y);

    // Left Wing
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-4 * flap, -2), width: 7 * flap, height: 9),
      wingPaint,
    );
    // Right Wing
    canvas.drawOval(
      Rect.fromCenter(center: Offset(4 * flap, -2), width: 7 * flap, height: 9),
      wingPaint,
    );
    // Body
    final bodyPaint = Paint()..color = const Color(0xFF4A3423).withValues(alpha: 0.7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 2.2, height: 6),
      bodyPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.memoryCount != memoryCount;
}
