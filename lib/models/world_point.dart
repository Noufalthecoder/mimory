import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D World Position in the Memory Walk miniature world coordinate system.
/// [x]: lateral position (left is negative, center is 0, right is positive)
/// [y]: forward distance along the world path (forward is positive)
/// [z]: elevation above ground (0 is ground level)
class WorldPos {
  final double x;
  final double y;
  final double z;

  const WorldPos(this.x, this.y, [this.z = 0.0]);

  WorldPos copyWith({double? x, double? y, double? z}) {
    return WorldPos(
      x ?? this.x,
      y ?? this.y,
      z ?? this.z,
    );
  }

  WorldPos operator +(WorldPos other) =>
      WorldPos(x + other.x, y + other.y, z + other.z);

  WorldPos operator -(WorldPos other) =>
      WorldPos(x - other.x, y - other.y, z - other.z);

  double distanceTo(WorldPos other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  double horizontalDistanceTo(WorldPos other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  static WorldPos lerp(WorldPos a, WorldPos b, double t) {
    return WorldPos(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
      a.z + (b.z - a.z) * t,
    );
  }
}

/// Projected 2D coordinates on the device screen after perspective transformation.
class ProjectedPoint {
  final double screenX;
  final double screenY;
  final double scale;
  final double depth; // viewDepth for Painter's algorithm depth sorting
  final bool isVisible;

  const ProjectedPoint({
    required this.screenX,
    required this.screenY,
    required this.scale,
    required this.depth,
    required this.isVisible,
  });

  Offset get offset => Offset(screenX, screenY);
}

/// Third-Person Perspective Camera.
/// Positioned behind the couple, slightly elevated, angled downward along the winding road.
class Camera3D {
  WorldPos position;
  double yaw; // horizontal rotation in radians (0 = facing straight ahead along +y)
  double pitch; // downward tilt in radians (~0.35 rad = ~20 degrees down)
  double focalLength; // projection scale factor (controls field of view)
  double distanceBehind; // distance behind player
  double heightAbove; // height above player

  // Soft camera dead-zone anchor
  WorldPos? focusAnchor;
  double deadZoneX;
  double deadZoneY;

  Camera3D({
    required this.position,
    this.yaw = 0.0,
    this.pitch = 0.38,
    this.focalLength = 480.0,
    this.distanceBehind = 130.0,
    this.heightAbove = 65.0,
    this.deadZoneX = 22.0,
    this.deadZoneY = 26.0,
    this.focusAnchor,
  });

  /// Updates camera position to follow a player world position with a calm soft dead-zone and smooth yaw follow.
  void followPlayer({
    required WorldPos playerPos,
    required double targetYaw,
    double lagT = 0.10,
    double yawLagT = 0.045,
    bool isMoving = true,
  }) {
    // Initialize focus anchor if not yet set
    focusAnchor ??= playerPos;

    // 1. Soft Dead-Zone calculation:
    // Couple can move naturally within deadZoneX / deadZoneY without camera constantly shifting.
    final dx = playerPos.x - focusAnchor!.x;
    final dy = playerPos.y - focusAnchor!.y;

    double newAnchorX = focusAnchor!.x;
    double newAnchorY = focusAnchor!.y;

    if (dx.abs() > deadZoneX) {
      newAnchorX += (dx.sign * (dx.abs() - deadZoneX));
    }
    if (dy.abs() > deadZoneY) {
      newAnchorY += (dy.sign * (dy.abs() - deadZoneY));
    }

    focusAnchor = WorldPos(newAnchorX, newAnchorY, playerPos.z);

    // 2. Smoothly ease yaw toward travel direction only when moving
    if (isMoving) {
      final yawDiff = (targetYaw - yaw);
      final normalizedYawDiff = math.atan2(math.sin(yawDiff), math.cos(yawDiff));
      yaw += normalizedYawDiff * yawLagT;
    }

    // 3. Ideal camera position behind the focus anchor
    final targetCamX = focusAnchor!.x - math.sin(yaw) * distanceBehind;
    final targetCamY = focusAnchor!.y - math.cos(yaw) * distanceBehind;
    final targetCamZ = focusAnchor!.z + heightAbove;

    position = WorldPos(
      position.x + (targetCamX - position.x) * lagT,
      position.y + (targetCamY - position.y) * lagT,
      position.z + (targetCamZ - position.z) * lagT,
    );
  }

  /// Projects a 3D world coordinate to 2D screen coordinate.
  ProjectedPoint project(WorldPos worldPoint, Size screenSize) {
    final dx = worldPoint.x - position.x;
    final dy = worldPoint.y - position.y;
    final dz = worldPoint.z - position.z;

    // 1. Rotate around vertical Z axis by -yaw
    final cosY = math.cos(-yaw);
    final sinY = math.sin(-yaw);
    final rx = dx * cosY - dy * sinY;
    final forwardY = dx * sinY + dy * cosY;

    // 2. Rotate around lateral pitch axis
    final cosP = math.cos(pitch);
    final sinP = math.sin(pitch);
    final viewDepth = forwardY * cosP + dz * sinP;
    final viewHeight = dz * cosP - forwardY * sinP;

    // Near clipping plane: points behind or directly on the camera lens are not drawn
    if (viewDepth < 18.0) {
      return ProjectedPoint(
        screenX: screenSize.width * 0.5,
        screenY: screenSize.height * 0.5,
        scale: 0.0,
        depth: viewDepth,
        isVisible: false,
      );
    }

    final scale = focalLength / viewDepth;

    // Perspective horizon positioned at ~36% of screen height
    final horizonY = screenSize.height * 0.38;
    final screenCenterX = screenSize.width * 0.5;

    final screenX = screenCenterX + rx * scale;
    final screenY = horizonY - viewHeight * scale;

    return ProjectedPoint(
      screenX: screenX,
      screenY: screenY,
      scale: scale,
      depth: viewDepth,
      isVisible: true,
    );
  }
}
