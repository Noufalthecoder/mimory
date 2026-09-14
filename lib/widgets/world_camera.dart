import 'package:flutter/material.dart';

/// Manages camera zoom, camera follow, and multi-layer parallax depth for the Living World.
/// Transforms world-space coordinates into screen-space coordinates.
class WorldCamera extends StatelessWidget {
  final double zoom;
  final Offset cameraFocus; // Center point in world coordinates
  final Size screenSize;
  final Size worldSize;
  final Widget backgroundLayer;
  final Widget distantHillsLayer;
  final Widget midgroundLayer;
  final Widget walkingLayer; // Road, characters, memory objects
  final Widget foregroundLayer; // Butterflies, floating petals, foreground leaves

  const WorldCamera({
    super.key,
    required this.zoom,
    required this.cameraFocus,
    required this.screenSize,
    required this.worldSize,
    required this.backgroundLayer,
    required this.distantHillsLayer,
    required this.midgroundLayer,
    required this.walkingLayer,
    required this.foregroundLayer,
  });

  @override
  Widget build(BuildContext context) {
    final screenCenter = Offset(screenSize.width / 2, screenSize.height * 0.55);

    // Calculate camera delta relative to world center
    final worldCenter = Offset(worldSize.width / 2, worldSize.height / 2);
    final deltaFromCenter = cameraFocus - worldCenter;

    // Parallax matrix calculations
    final distantOffset = deltaFromCenter * 0.18;
    final midgroundOffset = deltaFromCenter * 0.45;
    final foregroundOffset = deltaFromCenter * 1.15;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Static Warm Sky & Sun Glow
          backgroundLayer,

          // 2. Distant Hills with Slow Parallax (0.18x)
          Transform.translate(
            offset: -distantOffset,
            child: distantHillsLayer,
          ),

          // 3. Midground Hills & Trees with Moderate Parallax (0.45x)
          Transform.translate(
            offset: -midgroundOffset,
            child: midgroundLayer,
          ),

          // 4. Main Walking Layer (Road, Couple, Memories, Meadow)
          // Transformed by camera zoom and centered on couple focus
          Transform(
            alignment: Alignment.topLeft,
            // ignore: deprecated_member_use
            transform: Matrix4.identity()
              // ignore: deprecated_member_use
              ..translate(screenCenter.dx, screenCenter.dy)
              // ignore: deprecated_member_use
              ..scale(zoom)
              // ignore: deprecated_member_use
              ..translate(-cameraFocus.dx, -cameraFocus.dy),
            child: SizedBox(
              width: worldSize.width,
              height: worldSize.height,
              child: walkingLayer,
            ),
          ),

          // 5. Foreground Framing Layer with Faster Parallax (1.15x)
          Transform.translate(
            offset: -foregroundOffset,
            child: foregroundLayer,
          ),
        ],
      ),
    );
  }
}
