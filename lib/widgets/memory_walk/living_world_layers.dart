import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Isolated, high-performance animation layers for the Living World.
/// Each layer uses an efficient CustomPainter with mathematical particle paths
/// and zero expensive child widgets to maintain high framerates on mobile.

/// 1. RAIN LAYER
/// Renders diagonal storybook raindrops and subtle ground ripples.
class RainLayer extends StatelessWidget {
  final double animationValue; // 0.0 to 1.0 from ambient controller

  const RainLayer({
    super.key,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _RainPainter(progress: animationValue),
        ),
      ),
    );
  }
}

class _RainPainter extends CustomPainter {
  final double progress;

  _RainPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rainPaint = Paint()
      ..color = const Color(0xFF8BA6BE).withValues(alpha: 0.55)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final ripplePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const dropCount = 42;
    for (int i = 0; i < dropCount; i++) {
      // Deterministic spread based on index
      final seedX = (i * 37.0) % size.width;
      final speed = 1.2 + (i % 5) * 0.25;
      final yOffset = ((progress * speed + (i * 0.17)) % 1.0) * (size.height + 60) - 30;
      final xOffset = seedX - (progress * 35 % 20);

      // Rain streak angled slightly to the right (diagonal storybook breeze)
      canvas.drawLine(
        Offset(xOffset, yOffset),
        Offset(xOffset - 4, yOffset + 14),
        rainPaint,
      );

      // Ground ripple when drop hits lower half
      if (yOffset > size.height * 0.60 && (i % 3 == 0)) {
        final rippleRadius = ((progress * 3 + i) % 1.0) * 8.0;
        final rippleAlpha = (1.0 - (((progress * 3 + i) % 1.0))).clamp(0.0, 1.0);
        ripplePaint.color = Colors.white.withValues(alpha: rippleAlpha * 0.35);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(xOffset, yOffset),
            width: rippleRadius * 2.2,
            height: rippleRadius * 0.8,
          ),
          ripplePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) => true;
}

/// 2. SNOW LAYER
/// Gentle falling snowflakes with sinusoidal horizontal drift and varied depth.
class SnowLayer extends StatelessWidget {
  final double animationValue;

  const SnowLayer({
    super.key,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _SnowPainter(progress: animationValue),
        ),
      ),
    );
  }
}

class _SnowPainter extends CustomPainter {
  final double progress;

  _SnowPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final flakePaint = Paint()..style = PaintingStyle.fill;

    const flakeCount = 50;
    for (int i = 0; i < flakeCount; i++) {
      final seedX = (i * 29.0) % size.width;
      final speed = 0.5 + (i % 4) * 0.2;
      final y = ((progress * speed + (i * 0.23)) % 1.0) * (size.height + 40) - 20;

      // Soft sinusoidal floating sway
      final sway = math.sin((progress * math.pi * 4) + i) * (8.0 + (i % 6));
      final x = (seedX + sway) % size.width;

      final radius = 1.4 + (i % 3) * 1.1;
      final opacity = 0.45 + (i % 4) * 0.15;

      flakePaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, flakePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowPainter oldDelegate) => true;
}

/// 3. FIREFLY LAYER
/// Subtle pulsing golden-green fireflies for night or starlit forest.
class FireflyLayer extends StatelessWidget {
  final double animationValue;

  const FireflyLayer({
    super.key,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _FireflyPainter(progress: animationValue),
        ),
      ),
    );
  }
}

class _FireflyPainter extends CustomPainter {
  final double progress;

  _FireflyPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const fireflyCount = 16;
    for (int i = 0; i < fireflyCount; i++) {
      // Gentle wandering paths
      final baseX = (size.width * 0.15) + ((i * 47.0) % (size.width * 0.70));
      final baseY = (size.height * 0.40) + ((i * 31.0) % (size.height * 0.45));

      final driftX = math.sin((progress * math.pi * 2) + i * 1.3) * 22;
      final driftY = math.cos((progress * math.pi * 2) + i * 0.9) * 16;

      // Pulsing glow
      final pulse = (math.sin((progress * math.pi * 4) + i * 2.1) + 1.0) / 2.0;
      final alpha = (0.25 + pulse * 0.65).clamp(0.0, 1.0);

      final center = Offset(baseX + driftX, baseY + driftY);

      // Outer soft aura
      final auraPaint = Paint()
        ..color = const Color(0xFFD4FF78).withValues(alpha: alpha * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(center, 7, auraPaint);

      // Core bright firefly
      final corePaint = Paint()
        ..color = const Color(0xFFFFFFA0).withValues(alpha: alpha);
      canvas.drawCircle(center, 2.2, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FireflyPainter oldDelegate) => true;
}

/// 4. BUTTERFLY LAYER
/// Fluttering pastel butterflies active in day/garden.
class ButterflyLayer extends StatelessWidget {
  final double animationValue;

  const ButterflyLayer({
    super.key,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ButterflyPainter(progress: animationValue),
        ),
      ),
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  final double progress;

  _ButterflyPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFFFAAA6), // Coral pink
      const Color(0xFFFFD3B6), // Warm peach
      const Color(0xFFB8E0D2), // Soft mint
    ];

    for (int i = 0; i < 3; i++) {
      final startX = size.width * (0.25 + i * 0.25);
      final startY = size.height * (0.55 + (i % 2) * 0.15);

      final flyX = startX + math.sin((progress * math.pi * 2) + i * 2.0) * 36;
      final flyY = startY + math.cos((progress * math.pi * 3) + i * 1.5) * 20;

      // Wing flap cycle
      final wingSpan = (math.sin(progress * math.pi * 14 + i) * 3.5).abs() + 1.5;

      final wingPaint = Paint()..color = colors[i % colors.length];

      // Left and right wings
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(flyX - wingSpan, flyY),
          width: wingSpan * 1.4,
          height: 5.0,
        ),
        wingPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(flyX + wingSpan, flyY),
          width: wingSpan * 1.4,
          height: 5.0,
        ),
        wingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ButterflyPainter oldDelegate) => true;
}

/// 5. FALLING LEAVES LAYER
/// Warm amber leaves drifting down in Autumn.
class FallingLeavesLayer extends StatelessWidget {
  final double animationValue;

  const FallingLeavesLayer({
    super.key,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _FallingLeavesPainter(progress: animationValue),
        ),
      ),
    );
  }
}

class _FallingLeavesPainter extends CustomPainter {
  final double progress;

  _FallingLeavesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final leafColors = [
      const Color(0xFFD46938), // Rust orange
      const Color(0xFFE29D45), // Golden amber
      const Color(0xFFC04B32), // Deep red
    ];

    const leafCount = 14;
    for (int i = 0; i < leafCount; i++) {
      final seedX = (i * 43.0) % size.width;
      final y = ((progress * 0.6 + (i * 0.19)) % 1.0) * (size.height + 40) - 20;
      final sway = math.sin((progress * math.pi * 3) + i) * 18;
      final x = (seedX + sway) % size.width;

      final leafPaint = Paint()..color = leafColors[i % leafColors.length].withValues(alpha: 0.85);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((progress * math.pi * 2) + i);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 7.0, height: 3.5),
        leafPaint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FallingLeavesPainter oldDelegate) => true;
}

/// 6. STARS AND MOON LAYER
/// Twinkling stars and soft golden crescent moon for Night mode.
class StarsAndMoonLayer extends StatelessWidget {
  final double animationValue;

  const StarsAndMoonLayer({
    super.key,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _StarsAndMoonPainter(progress: animationValue),
        ),
      ),
    );
  }
}

class _StarsAndMoonPainter extends CustomPainter {
  final double progress;

  _StarsAndMoonPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.28;

    // 1. Crescent Moon in upper sky
    final moonCenter = Offset(size.width * 0.82, horizonY * 0.42);

    // Moon soft aura glow
    final auraPaint = Paint()
      ..color = const Color(0xFFFFF3D1).withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(moonCenter, 22, auraPaint);

    // Main moon disc
    final moonPaint = Paint()..color = const Color(0xFFFFFBE8);
    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: 13));

    // Cutout to form a gentle crescent
    final cutoutPath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(moonCenter.dx - 5.5, moonCenter.dy - 3),
        radius: 11,
      ));

    final crescent = Path.combine(PathOperation.difference, moonPath, cutoutPath);
    canvas.drawPath(crescent, moonPaint);

    // 2. Twinkling Stars across sky
    final starPositions = [
      Offset(size.width * 0.12, horizonY * 0.25),
      Offset(size.width * 0.26, horizonY * 0.48),
      Offset(size.width * 0.40, horizonY * 0.18),
      Offset(size.width * 0.58, horizonY * 0.35),
      Offset(size.width * 0.68, horizonY * 0.15),
      Offset(size.width * 0.90, horizonY * 0.65),
      Offset(size.width * 0.34, horizonY * 0.70),
      Offset(size.width * 0.74, horizonY * 0.55),
    ];

    for (int i = 0; i < starPositions.length; i++) {
      final twinkle = (math.sin((progress * math.pi * 4) + (i * 1.5)) + 1.0) / 2.0;
      final alpha = 0.35 + twinkle * 0.65;
      final starPaint = Paint()..color = Colors.white.withValues(alpha: alpha);

      final pos = starPositions[i];
      // 4-point star cross
      final radius = 1.8 + (i % 2) * 0.8;
      canvas.drawCircle(pos, radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsAndMoonPainter oldDelegate) => true;
}

/// 7. AMBIENT LIGHT LAYER
/// Applies smooth lighting tint (soft golden sunrise, deep warm amber sunset, or gentle twilight night)
/// without washing out landmarks or reducing text readability.
class AmbientLightLayer extends StatelessWidget {
  final Color overlayColor;

  const AmbientLightLayer({
    super.key,
    required this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: overlayColor,
        ),
      ),
    );
  }
}
