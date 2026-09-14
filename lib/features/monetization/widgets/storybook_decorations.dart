import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mimory/core/theme/app_theme.dart';

/// Lightweight custom painters and decorative widgets for the MIMORY storybook aesthetic.
/// These replace raw emojis with gentle, hand-drawn vector artwork.

class StorybookSprout extends StatelessWidget {
  final double size;
  final Color color;

  const StorybookSprout({
    super.key,
    this.size = 24,
    this.color = AppTheme.sageGreen,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SproutPainter(color: color),
    );
  }
}

class _SproutPainter extends CustomPainter {
  final Color color;
  _SproutPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    // Stem
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.95);
    path.quadraticBezierTo(
      size.width * 0.48,
      size.height * 0.55,
      size.width * 0.5,
      size.height * 0.35,
    );
    canvas.drawPath(path, paint);

    // Left Leaf
    final leftLeaf = Path();
    leftLeaf.moveTo(size.width * 0.5, size.height * 0.5);
    leftLeaf.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.3,
      size.width * 0.2,
      size.height * 0.18,
    );
    leftLeaf.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.22,
      size.width * 0.5,
      size.height * 0.45,
    );
    leftLeaf.close();
    canvas.drawPath(leftLeaf, fillPaint);

    // Right Leaf
    final rightLeaf = Path();
    rightLeaf.moveTo(size.width * 0.5, size.height * 0.45);
    rightLeaf.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.25,
      size.width * 0.8,
      size.height * 0.15,
    );
    rightLeaf.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.18,
      size.width * 0.5,
      size.height * 0.4,
    );
    rightLeaf.close();
    canvas.drawPath(rightLeaf, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _SproutPainter oldDelegate) =>
      oldDelegate.color != color;
}

class StorybookFlower extends StatelessWidget {
  final double size;
  final Color petalColor;
  final Color centerColor;

  const StorybookFlower({
    super.key,
    this.size = 24,
    this.petalColor = AppTheme.primaryPink,
    this.centerColor = AppTheme.softYellow,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FlowerPainter(petalColor: petalColor, centerColor: centerColor),
    );
  }
}

class _FlowerPainter extends CustomPainter {
  final Color petalColor;
  final Color centerColor;

  _FlowerPainter({required this.petalColor, required this.centerColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final petalRadius = size.width * 0.22;
    final petalDist = size.width * 0.25;

    final petalPaint = Paint()
      ..color = petalColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final angle = i * (2 * math.pi / 5) - math.pi / 2;
      final offset = Offset(
        center.dx + math.cos(angle) * petalDist,
        center.dy + math.sin(angle) * petalDist,
      );
      canvas.drawCircle(offset, petalRadius, petalPaint);
    }

    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.18, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _FlowerPainter oldDelegate) =>
      oldDelegate.petalColor != petalColor ||
      oldDelegate.centerColor != centerColor;
}

class StorybookSparkle extends StatelessWidget {
  final double size;
  final Color color;

  const StorybookSparkle({
    super.key,
    this.size = 18,
    this.color = AppTheme.softYellowDark,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color: color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width;
    final h = size.height;

    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy, w, cy);
    path.quadraticBezierTo(cx, cy, cx, h);
    path.quadraticBezierTo(cx, cy, 0, cy);
    path.quadraticBezierTo(cx, cy, cx, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}

class StorybookLeaf extends StatelessWidget {
  final double size;
  final Color color;
  final double angle;

  const StorybookLeaf({
    super.key,
    this.size = 20,
    this.color = AppTheme.sageGreen,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: CustomPaint(
        size: Size(size, size),
        painter: _LeafPainter(color: color),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final Color color;
  _LeafPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.2,
      size.width,
      0,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.9,
      0,
      size.height,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Stem line
    final stemPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width * 0.7, size.height * 0.3),
      stemPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LeafPainter oldDelegate) =>
      oldDelegate.color != color;
}

class StorybookButterfly extends StatelessWidget {
  final double size;
  final Color color;

  const StorybookButterfly({
    super.key,
    this.size = 22,
    this.color = AppTheme.primaryPink,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ButterflyPainter(color: color),
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  final Color color;
  _ButterflyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final wingPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    // Upper left wing
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - size.width * 0.24, cy - size.height * 0.18),
        width: size.width * 0.38,
        height: size.height * 0.42,
      ),
      wingPaint,
    );

    // Upper right wing
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + size.width * 0.24, cy - size.height * 0.18),
        width: size.width * 0.38,
        height: size.height * 0.42,
      ),
      wingPaint,
    );

    // Lower left wing
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - size.width * 0.18, cy + size.height * 0.22),
        width: size.width * 0.28,
        height: size.height * 0.3,
      ),
      wingPaint,
    );

    // Lower right wing
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + size.width * 0.18, cy + size.height * 0.22),
        width: size.width * 0.28,
        height: size.height * 0.3,
      ),
      wingPaint,
    );

    // Body
    final bodyPaint = Paint()
      ..color = AppTheme.textPrimary
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: size.width * 0.1,
          height: size.height * 0.6,
        ),
        const Radius.circular(3),
      ),
      bodyPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ButterflyPainter oldDelegate) =>
      oldDelegate.color != color;
}
