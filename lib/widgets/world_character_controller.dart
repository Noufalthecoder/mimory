import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/widgets/anime_character_widget.dart';

class _Waypoint {
  final Offset position; // Normalized coordinates (0.0 to 1.0)
  final String? memoryId;
  final Duration pauseDuration;

  _Waypoint({
    required this.position,
    this.memoryId,
    this.pauseDuration = const Duration(seconds: 1),
  });
}

/// Coordinates autonomous movement for the two living anime characters inside the World.
/// They walk together down the pebble path, pause beside memories, admire them,
/// and continue exploring peacefully.
class WorldCharacterController extends StatefulWidget {
  final Character userCharacter;
  final Character companionCharacter;
  final List<Memory> memories;
  final double width;
  final double height;
  final ValueChanged<String?> onMemoryVisited;

  const WorldCharacterController({
    super.key,
    required this.userCharacter,
    required this.companionCharacter,
    required this.memories,
    required this.width,
    required this.height,
    required this.onMemoryVisited,
  });

  @override
  State<WorldCharacterController> createState() => _WorldCharacterControllerState();
}

class _WorldCharacterControllerState extends State<WorldCharacterController> {
  late List<_Waypoint> _waypoints;
  int _currentWaypointIndex = 0;

  // Person 1 (Lead) state
  Offset _leadPos = const Offset(0.50, 0.44);
  bool _leadWalking = false;
  bool _leadFacingRight = true;

  // Person 2 (Companion) state
  Offset _companionPos = const Offset(0.53, 0.44);
  bool _companionWalking = false;
  bool _companionFacingRight = true;

  bool _isLookingAtMemory = false;
  Timer? _stepTimer;
  Timer? _pauseTimer;

  @override
  void initState() {
    super.initState();
    _buildWaypoints();
    _startMovementLoop();
  }

  @override
  void didUpdateWidget(covariant WorldCharacterController oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.memories.length != widget.memories.length) {
      _buildWaypoints();
    }
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pauseTimer?.cancel();
    super.dispose();
  }

  void _buildWaypoints() {
    final List<_Waypoint> points = [];

    // Start at Clearing / Bench
    points.add(_Waypoint(
      position: const Offset(0.50, 0.44),
      pauseDuration: const Duration(seconds: 2),
    ));

    // Trail entry
    points.add(_Waypoint(
      position: const Offset(0.48, 0.52),
      pauseDuration: const Duration(milliseconds: 800),
    ));

    // If Memory 0 exists (Slot 0 is at 0.20, 0.60)
    if (widget.memories.isNotEmpty) {
      points.add(_Waypoint(
        position: const Offset(0.44, 0.58),
        pauseDuration: const Duration(milliseconds: 500),
      ));
      // Branch to Memory 0
      points.add(_Waypoint(
        position: const Offset(0.28, 0.60),
        memoryId: widget.memories[0].id,
        pauseDuration: const Duration(seconds: 4),
      ));
      // Return to path
      points.add(_Waypoint(
        position: const Offset(0.44, 0.62),
        pauseDuration: const Duration(milliseconds: 600),
      ));
    }

    // Mid Trail
    points.add(_Waypoint(
      position: const Offset(0.48, 0.68),
      pauseDuration: const Duration(milliseconds: 800),
    ));

    // If Memory 1 exists (Slot 1 is at 0.78, 0.62)
    if (widget.memories.length >= 2) {
      points.add(_Waypoint(
        position: const Offset(0.68, 0.62),
        memoryId: widget.memories[1].id,
        pauseDuration: const Duration(seconds: 4),
      ));
      // Return to path
      points.add(_Waypoint(
        position: const Offset(0.52, 0.72),
        pauseDuration: const Duration(milliseconds: 600),
      ));
    }

    // Lower Trail
    points.add(_Waypoint(
      position: const Offset(0.54, 0.78),
      pauseDuration: const Duration(milliseconds: 800),
    ));

    // If Memory 2 exists (Slot 2 is at 0.32, 0.74)
    if (widget.memories.length >= 3) {
      points.add(_Waypoint(
        position: const Offset(0.39, 0.74),
        memoryId: widget.memories[2].id,
        pauseDuration: const Duration(seconds: 4),
      ));
      points.add(_Waypoint(
        position: const Offset(0.54, 0.80),
        pauseDuration: const Duration(milliseconds: 600),
      ));
    }

    // Bottom Meadow Clearing / Flowers
    points.add(_Waypoint(
      position: const Offset(0.48, 0.86),
      pauseDuration: const Duration(seconds: 2),
    ));

    // Loop back up path
    points.add(_Waypoint(
      position: const Offset(0.52, 0.68),
      pauseDuration: const Duration(milliseconds: 800),
    ));

    _waypoints = points;
  }

  void _startMovementLoop() {
    _stepTimer?.cancel();
    _pauseTimer?.cancel();

    if (_waypoints.isEmpty) return;

    // Peaceful 50ms tick loop for smooth slow movement
    _stepTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _tickMovement();
    });
  }

  void _tickMovement() {
    if (!mounted || _waypoints.isEmpty) return;

    final targetWaypoint = _waypoints[_currentWaypointIndex];
    final targetPos = targetWaypoint.position;

    final dx = targetPos.dx - _leadPos.dx;
    final dy = targetPos.dy - _leadPos.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    // Speed: ~0.0018 normalized units per tick (~36 pixels/sec on typical screen)
    const stepSpeed = 0.0018;

    if (dist < stepSpeed) {
      // Reached waypoint!
      _leadPos = targetPos;
      _leadWalking = false;
      _companionWalking = false;

      // Check if this waypoint is visiting a memory
      final isMemoryVisit = targetWaypoint.memoryId != null;
      _isLookingAtMemory = isMemoryVisit;

      if (isMemoryVisit) {
        widget.onMemoryVisited(targetWaypoint.memoryId);
      }

      _stepTimer?.cancel();

      // Pause at waypoint for its duration
      _pauseTimer = Timer(targetWaypoint.pauseDuration, () {
        if (!mounted) return;

        if (isMemoryVisit) {
          widget.onMemoryVisited(null);
          _isLookingAtMemory = false;
        }

        // Advance to next waypoint in loop
        _currentWaypointIndex = (_currentWaypointIndex + 1) % _waypoints.length;
        _startMovementLoop();
      });

      setState(() {});
    } else {
      // Step lead towards target
      final angle = math.atan2(dy, dx);
      final newLeadX = _leadPos.dx + math.cos(angle) * stepSpeed;
      final newLeadY = _leadPos.dy + math.sin(angle) * stepSpeed;

      _leadPos = Offset(newLeadX, newLeadY);
      _leadWalking = true;
      _leadFacingRight = dx >= 0;

      // Companion smoothly follows slightly behind and to the side
      final companionTarget = Offset(
        _leadPos.dx + (_leadFacingRight ? -0.045 : 0.045),
        _leadPos.dy + 0.005,
      );

      final cdx = companionTarget.dx - _companionPos.dx;
      final cdy = companionTarget.dy - _companionPos.dy;
      final cDist = math.sqrt(cdx * cdx + cdy * cdy);

      if (cDist > 0.001) {
        final cAngle = math.atan2(cdy, cdx);
        final cSpeed = math.min(stepSpeed * 1.15, cDist);
        _companionPos = Offset(
          _companionPos.dx + math.cos(cAngle) * cSpeed,
          _companionPos.dy + math.sin(cAngle) * cSpeed,
        );
        _companionWalking = true;
        _companionFacingRight = cdx >= 0;
      } else {
        _companionWalking = false;
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadPixelX = _leadPos.dx * widget.width;
    final leadPixelY = _leadPos.dy * widget.height;

    final compPixelX = _companionPos.dx * widget.width;
    final compPixelY = _companionPos.dy * widget.height;

    return Stack(
      children: [
        // Person 1: Lead (Current User)
        Positioned(
          left: leadPixelX - 16,
          top: leadPixelY - 38,
          child: AnimeCharacterWidget(
            character: widget.userCharacter,
            isWalking: _leadWalking,
            facingRight: _leadFacingRight,
            isLookingAtMemory: _isLookingAtMemory,
          ),
        ),

        // Person 2: Companion (Friend / Partner)
        Positioned(
          left: compPixelX - 16,
          top: compPixelY - 38,
          child: AnimeCharacterWidget(
            character: widget.companionCharacter,
            isWalking: _companionWalking,
            facingRight: _companionFacingRight,
            isLookingAtMemory: _isLookingAtMemory,
          ),
        ),
      ],
    );
  }
}
