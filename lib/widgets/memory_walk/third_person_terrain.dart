import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mimory/models/world_point.dart';

/// Renders the 3D perspective terrain:
/// - Winding natural road tapering into the distance
/// - Layered lush green meadow with subtle patches and soft shadows
/// - Distant hills, warm pastel sky, and soft sunlight horizon
class ThirdPersonTerrainPainter extends CustomPainter {
  final Camera3D camera;
  final List<WorldPos> roadCenterline;
  final double roadWidth;
  final double ambientTime;

  ThirdPersonTerrainPainter({
    required this.camera,
    required this.roadCenterline,
    this.roadWidth = 46.0,
    this.ambientTime = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.28;

    // 1. SKY & DISTANT HORIZON
    _paintSkyAndHorizon(canvas, size, horizonY);

    // 2. LUSH GREEN GROUND MEADOW
    _paintGroundMeadow(canvas, size, horizonY);

    // 3. WINDING PERSPECTIVE ROAD
    _paintPerspectiveRoad(canvas, size);
  }

  void _paintSkyAndHorizon(Canvas canvas, Size size, double horizonY) {
    // Soft anime sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF9F0), // Warm sunlight cream
          Color(0xFFFFEEE8), // Soft pastel blush
          Color(0xFFF7EBE1), // Horizon mist
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, horizonY + 2));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, horizonY + 2), skyPaint);

    // Distant soft mountains / hills silhouettes on horizon
    final hillPaint1 = Paint()
      ..color = const Color(0xFFC7DEC4).withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final hillPath1 = Path();
    hillPath1.moveTo(0, horizonY);
    hillPath1.quadraticBezierTo(size.width * 0.25, horizonY - 24, size.width * 0.52, horizonY);
    hillPath1.quadraticBezierTo(size.width * 0.78, horizonY - 32, size.width, horizonY - 4);
    hillPath1.lineTo(size.width, horizonY);
    hillPath1.close();
    canvas.drawPath(hillPath1, hillPaint1);

    final hillPaint2 = Paint()
      ..color = const Color(0xFFACD0A6).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final hillPath2 = Path();
    hillPath2.moveTo(0, horizonY);
    hillPath2.quadraticBezierTo(size.width * 0.35, horizonY - 16, size.width * 0.70, horizonY - 2);
    hillPath2.quadraticBezierTo(size.width * 0.90, horizonY - 14, size.width, horizonY);
    hillPath2.lineTo(size.width, horizonY);
    hillPath2.close();
    canvas.drawPath(hillPath2, hillPaint2);

    // Soft drifting clouds
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final cloudOffset1 = (ambientTime * 18) % (size.width + 100) - 50;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cloudOffset1, horizonY * 0.40), width: 90, height: 26),
      cloudPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cloudOffset1 + 18, horizonY * 0.36), width: 60, height: 22),
      cloudPaint,
    );

    final cloudOffset2 = ((ambientTime * 12) + 200) % (size.width + 120) - 60;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cloudOffset2, horizonY * 0.62), width: 110, height: 28),
      cloudPaint,
    );
  }

  void _paintGroundMeadow(Canvas canvas, Size size, double horizonY) {
    // Rich gradient green meadow
    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF90C28A), // Far meadow green
          Color(0xFF7CAE74), // Mid meadow green
          Color(0xFF6E9F65), // Fore meadow rich green
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY));

    canvas.drawRect(
      Rect.fromLTWH(0, horizonY, size.width, size.height - horizonY),
      groundPaint,
    );

    // Gentle terrain shading waves
    final patchPaint = Paint()
      ..color = const Color(0xFF629158).withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;

    final wavePath = Path();
    wavePath.moveTo(0, size.height * 0.60);
    wavePath.quadraticBezierTo(size.width * 0.4, size.height * 0.56, size.width, size.height * 0.65);
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();
    canvas.drawPath(wavePath, patchPaint);
  }

  void _paintPerspectiveRoad(Canvas canvas, Size size) {
    if (roadCenterline.length < 2) return;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFC7BAA5).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final roadSurfacePaint = Paint()
      ..color = const Color(0xFFF3EDE2)
      ..style = PaintingStyle.fill;

    final roadPebblePaint = Paint()
      ..color = const Color(0xFFE2D6C6)
      ..style = PaintingStyle.fill;

    // Calculate left and right road boundary ribbons in 3D, then project
    final leftBorder = <Offset>[];
    final rightBorder = <Offset>[];
    final leftInner = <Offset>[];
    final rightInner = <Offset>[];

    for (int i = 0; i < roadCenterline.length; i++) {
      final pCurr = roadCenterline[i];
      // Compute local tangent
      double tx = 0.0;
      double ty = 1.0;

      if (i < roadCenterline.length - 1) {
        tx = roadCenterline[i + 1].x - pCurr.x;
        ty = roadCenterline[i + 1].y - pCurr.y;
      } else if (i > 0) {
        tx = pCurr.x - roadCenterline[i - 1].x;
        ty = pCurr.y - roadCenterline[i - 1].y;
      }

      final len = math.sqrt(tx * tx + ty * ty);
      final nx = len > 0.001 ? -ty / len : -1.0;
      final ny = len > 0.001 ? tx / len : 0.0;

      final halfW = roadWidth * 0.5;
      final borderW = halfW + 3.5;

      // World positions of road edges
      final pLeftEdge = WorldPos(pCurr.x + nx * borderW, pCurr.y + ny * borderW, 0);
      final pRightEdge = WorldPos(pCurr.x - nx * borderW, pCurr.y - ny * borderW, 0);
      final pLeftInner = WorldPos(pCurr.x + nx * halfW, pCurr.y + ny * halfW, 0);
      final pRightInner = WorldPos(pCurr.x - nx * halfW, pCurr.y - ny * halfW, 0);

      // Project into screen space
      final projLeftEdge = camera.project(pLeftEdge, size);
      final projRightEdge = camera.project(pRightEdge, size);
      final projLeftInner = camera.project(pLeftInner, size);
      final projRightInner = camera.project(pRightInner, size);

      if (projLeftEdge.isVisible && projRightEdge.isVisible) {
        leftBorder.add(projLeftEdge.offset);
        rightBorder.add(projRightEdge.offset);
        leftInner.add(projLeftInner.offset);
        rightInner.add(projRightInner.offset);
      }
    }

    if (leftBorder.length < 2) return;

    // Draw earthy road border strip
    final borderPath = Path();
    borderPath.moveTo(leftBorder.first.dx, leftBorder.first.dy);
    for (int i = 1; i < leftBorder.length; i++) {
      borderPath.lineTo(leftBorder[i].dx, leftBorder[i].dy);
    }
    for (int i = rightBorder.length - 1; i >= 0; i--) {
      borderPath.lineTo(rightBorder[i].dx, rightBorder[i].dy);
    }
    borderPath.close();
    canvas.drawPath(borderPath, roadBorderPaint);

    // Draw main cream road surface
    final roadPath = Path();
    roadPath.moveTo(leftInner.first.dx, leftInner.first.dy);
    for (int i = 1; i < leftInner.length; i++) {
      roadPath.lineTo(leftInner[i].dx, leftInner[i].dy);
    }
    for (int i = rightInner.length - 1; i >= 0; i--) {
      roadPath.lineTo(rightInner[i].dx, rightInner[i].dy);
    }
    roadPath.close();
    canvas.drawPath(roadPath, roadSurfacePaint);

    // Subtle stone/cobblestone texture along the road
    for (int i = 0; i < roadCenterline.length; i += 3) {
      final p = roadCenterline[i];
      final proj = camera.project(WorldPos(p.x, p.y, 0), size);
      if (proj.isVisible && proj.scale > 0.4) {
        final radius = (2.2 * proj.scale).clamp(1.0, 5.5);
        canvas.drawCircle(
          Offset(proj.screenX + (i % 2 == 0 ? 5 : -5) * proj.scale, proj.screenY),
          radius,
          roadPebblePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ThirdPersonTerrainPainter oldDelegate) {
    return true; // Continuously repaints as camera moves and ambient loop ticks
  }
}
