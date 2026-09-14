import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/world_point.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/widgets/memory_walk_joystick.dart';
import 'package:mimory/widgets/memory_walk/third_person_camera.dart';
import 'package:mimory/widgets/memory_walk/third_person_terrain.dart';
import 'package:mimory/widgets/memory_walk/third_person_couple.dart';
import 'package:mimory/widgets/memory_walk/memory_landmark.dart';
import 'package:mimory/widgets/memory_walk/direction_signboard.dart';
import 'package:mimory/widgets/memory_walk/animal_entity.dart';
import 'package:mimory/widgets/memory_walk/world_nature_object.dart';

/// The Third-Person Cozy Adventure Memory Walk World.
/// Implements:
/// - True 3D/2.5D perspective camera positioned behind and slightly above the couple
/// - Natural winding road tapering into the distance
/// - Left joystick movement + Right swipe camera look
/// - Visually connected hand holding (👩🏻🤝👨🏻) with synchronized walking
/// - True world-space coordinates and depth perspective
/// - Physical environmental memory landmarks & cute wooden direction boards
/// - Living roaming animals (rabbit, squirrel, bird, butterfly) with speech and feeding
class ThirdPersonWorldWidget extends StatefulWidget {
  final World world;
  final Character userCharacter;
  final Character companionCharacter;
  final List<Memory> memories;
  final VoidCallback onExit;
  final Function(Memory) onVisitMemory;

  const ThirdPersonWorldWidget({
    super.key,
    required this.world,
    required this.userCharacter,
    required this.companionCharacter,
    required this.memories,
    required this.onExit,
    required this.onVisitMemory,
  });

  @override
  State<ThirdPersonWorldWidget> createState() => _ThirdPersonWorldWidgetState();
}

class _ThirdPersonWorldWidgetState extends State<ThirdPersonWorldWidget>
    with TickerProviderStateMixin {
  // Player state
  WorldPos _playerPos = const WorldPos(0.0, 20.0, 0.0);
  double _playerYaw = 0.0; // in radians
  double _targetPlayerYaw = 0.0;
  bool _isWalking = false;
  bool _isHoldingHands = false;

  // Camera system
  late Camera3D _camera;
  double _cameraTargetYaw = 0.0;

  // Joystick & update loop
  Offset _joystickDirection = Offset.zero;
  Timer? _gameLoopTimer;

  // Environmental road spline
  final List<WorldPos> _roadCenterline = [];

  // World objects
  final List<_WorldFeature> _natureFeatures = [];
  final List<_DirectionSign> _directionSigns = [];
  final List<AnimalEntity> _animals = [];

  // Active contextual targets
  Memory? _nearbyMemory;
  AnimalEntity? _nearbyAnimal;

  // Ambient time for swaying and drifting
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();

    // 1. Initialize Camera
    _camera = Camera3D(
      position: const WorldPos(0.0, -100.0, 65.0),
      yaw: 0.0,
      pitch: 0.36,
      focalLength: 520.0,
      distanceBehind: 115.0,
      heightAbove: 62.0,
    );

    // 2. Generate natural winding road centerline
    _generateRoadCenterline();

    // 3. Populate world with trees, flowers, signs, and landmarks
    _populateWorld();

    // 4. Ambient controller for breeze and clouds
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    // 5. Game loop for smooth 60fps movement and camera follow
    _startGameLoop();
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _ambientController.dispose();
    super.dispose();
  }

  void _generateRoadCenterline() {
    _roadCenterline.clear();
    // Natural gentle S-curves extending into the distance
    for (double y = -40; y <= 900; y += 20) {
      final curve1 = math.sin(y * 0.012) * 28.0;
      final curve2 = math.cos(y * 0.005) * 14.0;
      final x = curve1 + curve2 - 12.0;
      _roadCenterline.add(WorldPos(x, y, 0.0));
    }
  }

  void _populateWorld() {
    _natureFeatures.clear();
    _directionSigns.clear();
    _animals.clear();

    // Nature along the roadside
    for (int i = 0; i < _roadCenterline.length; i += 2) {
      final rp = _roadCenterline[i];
      // Left side trees and bushes
      _natureFeatures.add(_WorldFeature(
        pos: WorldPos(rp.x - 42.0 - (i % 3) * 10, rp.y + 4, 0),
        type: i % 4 == 0 ? NatureObjectType.treeLarge : NatureObjectType.treeSmall,
      ));
      _natureFeatures.add(_WorldFeature(
        pos: WorldPos(rp.x - 28.0, rp.y - 6, 0),
        type: i % 2 == 0 ? NatureObjectType.bush : NatureObjectType.flowerPatch,
      ));

      // Right side trees and flowers
      _natureFeatures.add(_WorldFeature(
        pos: WorldPos(rp.x + 44.0 + (i % 2) * 12, rp.y + 8, 0),
        type: i % 3 == 0 ? NatureObjectType.treeLarge : NatureObjectType.bush,
      ));
      _natureFeatures.add(_WorldFeature(
        pos: WorldPos(rp.x + 29.0, rp.y - 2, 0),
        type: NatureObjectType.flowerPatch,
      ));

      // Occasional roadside rocks
      if (i % 5 == 0) {
        _natureFeatures.add(_WorldFeature(
          pos: WorldPos(rp.x - 24.0, rp.y + 12, 0),
          type: NatureObjectType.rock,
        ));
      }
    }

    // Direction Boards along the path
    _directionSigns.add(_DirectionSign(
      pos: const WorldPos(24.0, 70.0, 0),
      label: widget.memories.isNotEmpty ? '📷 ${widget.memories.first.title.toUpperCase()}' : '📷 MEETUP',
      arrow: '→',
    ));
    _directionSigns.add(_DirectionSign(
      pos: const WorldPos(-25.0, 220.0, 0),
      label: widget.memories.length > 1 ? '🌸 ${widget.memories[1].title.toUpperCase()}' : '🌸 FIRST TRIP',
      arrow: '←',
    ));
    _directionSigns.add(_DirectionSign(
      pos: const WorldPos(26.0, 390.0, 0),
      label: '🌱 KEEP GOING',
      arrow: '↑',
    ));

    // Living roaming animals
    _animals.add(AnimalEntity(
      id: 'rabbit_1',
      type: AnimalType.rabbit,
      worldPos: const WorldPos(20.0, 55.0, 0),
      speechText: 'Come with me ♡',
    ));
    _animals.add(AnimalEntity(
      id: 'squirrel_1',
      type: AnimalType.squirrel,
      worldPos: const WorldPos(-32.0, 150.0, 0),
      speechText: 'Look what I found!',
    ));
    _animals.add(AnimalEntity(
      id: 'bird_1',
      type: AnimalType.bird,
      worldPos: const WorldPos(22.0, 190.0, 0),
    ));
    _animals.add(AnimalEntity(
      id: 'butterfly_1',
      type: AnimalType.butterfly,
      worldPos: const WorldPos(-16.0, 90.0, 6.0),
    ));
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 24), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateSimulation();
    });
  }

  void _updateSimulation() {
    // 1. Move player if joystick is active
    if (_isWalking && _joystickDirection != Offset.zero) {
      // Calculate movement angle in screen space
      final moveAngle = math.atan2(_joystickDirection.dx, -_joystickDirection.dy);

      // Desired world facing angle = camera yaw + joystick angle
      _targetPlayerYaw = _camera.yaw + moveAngle;

      // Smooth turn interpolation
      final yawDiff = (_targetPlayerYaw - _playerYaw);
      final normalizedDiff = math.atan2(math.sin(yawDiff), math.cos(yawDiff));
      _playerYaw += normalizedDiff * 0.18;

      // Move in the facing direction
      const speed = 2.4;
      final moveX = math.sin(_playerYaw) * speed;
      final moveY = math.cos(_playerYaw) * speed;

      _playerPos = WorldPos(
        _playerPos.x + moveX,
        _playerPos.y + moveY,
        _playerPos.z,
      );

      // Camera smoothly rotates to face the direction the player is traveling
      _cameraTargetYaw = _playerYaw;
    }

    // 2. Camera follows player with calm soft dead-zone and smooth yaw follow
    _camera.followPlayer(
      playerPos: _playerPos,
      targetYaw: _cameraTargetYaw,
      lagT: 0.08,
      yawLagT: 0.035,
      isMoving: _isWalking,
    );

    // 3. Proximity detection for Memories
    _updateMemoryProximity();

    // 4. Proximity detection for Animals
    _updateAnimalProximity();

    setState(() {});
  }

  void _updateMemoryProximity() {
    Memory? closest;
    double minDistance = 56.0;

    for (int i = 0; i < widget.memories.length; i++) {
      final memPos = _getMemoryWorldPos(i);
      final dist = _playerPos.horizontalDistanceTo(memPos);
      if (dist < minDistance) {
        closest = widget.memories[i];
        minDistance = dist;
      }
    }

    if (_nearbyMemory != closest) {
      setState(() {
        _nearbyMemory = closest;
      });
    }
  }

  void _updateAnimalProximity() {
    AnimalEntity? closest;
    double minDistance = 42.0;

    for (final animal in _animals) {
      final dist = _playerPos.horizontalDistanceTo(animal.worldPos);
      if (dist < minDistance) {
        closest = animal;
        minDistance = dist;
      }
    }

    if (_nearbyAnimal != closest) {
      setState(() {
        _nearbyAnimal = closest;
      });
    }
  }

  WorldPos _getMemoryWorldPos(int index) {
    // Deterministic positions along the scenic winding road
    const offsets = [
      WorldPos(30.0, 110.0, 0),
      WorldPos(-32.0, 240.0, 0),
      WorldPos(32.0, 370.0, 0),
      WorldPos(-30.0, 510.0, 0),
      WorldPos(28.0, 650.0, 0),
    ];
    return offsets[index % offsets.length];
  }

  void _handleJoystickChanged(Offset dir, bool isMoving) {
    _joystickDirection = dir;
    _isWalking = isMoving;
  }


  void _handleFeedAnimal(AnimalEntity animal) {
    setState(() {
      animal.isFed = true;
      animal.speechText = 'Thank you ♡';
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          animal.speechText = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        // Prepare all renderable entities for Painter's Algorithm depth sorting
        final renderables = <_RenderItem>[];

        // 1. Nature features
        for (final item in _natureFeatures) {
          final proj = _camera.project(item.pos, size);
          if (proj.isVisible) {
            renderables.add(_RenderItem(
              depth: proj.depth,
              screenPos: proj.offset,
              scale: proj.scale,
              widget: WorldNatureObjectWidget(
                type: item.type,
                scale: proj.scale,
              ),
            ));
          }
        }

        // 2. Direction Signs
        for (final sign in _directionSigns) {
          final proj = _camera.project(sign.pos, size);
          if (proj.isVisible) {
            renderables.add(_RenderItem(
              depth: proj.depth,
              screenPos: proj.offset,
              scale: proj.scale,
              widget: DirectionSignboardWidget(
                label: sign.label,
                arrow: sign.arrow,
                scale: proj.scale,
              ),
            ));
          }
        }

        // 3. Environmental Memory Landmarks
        for (int i = 0; i < widget.memories.length; i++) {
          final mem = widget.memories[i];
          final memPos = _getMemoryWorldPos(i);
          final proj = _camera.project(memPos, size);
          if (proj.isVisible) {
            final isNear = _nearbyMemory == mem;
            renderables.add(_RenderItem(
              depth: proj.depth,
              screenPos: proj.offset,
              scale: proj.scale,
              widget: MemoryLandmarkWidget(
                memory: mem,
                isNearby: isNear,
                scale: proj.scale,
                onTap: () => widget.onVisitMemory(mem),
              ),
            ));
          }
        }

        // 4. Roaming Animals
        for (final animal in _animals) {
          final proj = _camera.project(animal.worldPos, size);
          if (proj.isVisible) {
            renderables.add(_RenderItem(
              depth: proj.depth,
              screenPos: proj.offset,
              scale: proj.scale,
              widget: AnimalWidget(
                animal: animal,
                scale: proj.scale,
                onTap: () => _handleFeedAnimal(animal),
              ),
            ));
          }
        }

        // 5. The Couple Characters
        final playerProj = _camera.project(_playerPos, size);
        if (playerProj.isVisible) {
          renderables.add(_RenderItem(
            depth: playerProj.depth,
            screenPos: playerProj.offset,
            scale: playerProj.scale,
            widget: ThirdPersonCoupleWidget(
              userCharacter: widget.userCharacter,
              companionCharacter: widget.companionCharacter,
              isHoldingHands: _isHoldingHands,
              isWalking: _isWalking,
              facingAngle: _playerYaw - _camera.yaw,
              scale: playerProj.scale,
              onHandHoldingToggled: () {
                setState(() {
                  _isHoldingHands = !_isHoldingHands;
                });
              },
            ),
          ));
        }

        // Depth sort: Farthest (largest depth) rendered first, nearest (smallest depth) on top!
        renderables.sort((a, b) => b.depth.compareTo(a.depth));

        return ClipRect(
          child: Stack(
            children: [
              // 1. 3D Terrain: Perspective winding road, meadow, sky & horizon
              Positioned.fill(
                child: CustomPaint(
                  painter: ThirdPersonTerrainPainter(
                    camera: _camera,
                    roadCenterline: _roadCenterline,
                    roadWidth: 46.0,
                    ambientTime: _ambientController.value,
                  ),
                ),
              ),

              // 2. Depth-Sorted World Objects & Characters
              ...renderables.map((item) {
                return Positioned(
                  left: item.screenPos.dx - 50,
                  bottom: size.height - item.screenPos.dy,
                  child: item.widget,
                );
              }),

              // 4. TOP HUD: Exit Walk Button & Memory Walk Title
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Exit Walk Button
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: widget.onExit,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE8DECF),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      size: 14,
                                      color: AppTheme.textPrimary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Exit Walk',
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Cozy Walk Title Badge
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primaryPink.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                'Memory Walk ♡',
                                style: GoogleFonts.mali(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryPink,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. CONTEXTUAL PROMPT: "Visit Memory ♡"
              if (_nearbyMemory != null)
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 120.0, left: 16.0, right: 16.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GestureDetector(
                          onTap: () => widget.onVisitMemory(_nearbyMemory!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: AppTheme.primaryPink,
                                width: 1.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryPink.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_stories_rounded,
                                  color: AppTheme.primaryPink,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Visit "${_nearbyMemory!.title}" ♡',
                                  style: GoogleFonts.mali(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // 6. CONTEXTUAL PROMPT: Animal Feed / Talk
              if (_nearbyAnimal != null && !_nearbyAnimal!.isFed)
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 120.0, left: 16.0, right: 16.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GestureDetector(
                          onTap: () => _handleFeedAnimal(_nearbyAnimal!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFFFA500),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFA500).withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🥕', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  'Give carrot ♡',
                                  style: GoogleFonts.mali(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // 7. BOTTOM CONTROLS: Left Joystick + Right "Hold Hands" button
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Left Movement Joystick
                        MemoryWalkJoystick(
                          onDirectionChanged: _handleJoystickChanged,
                        ),
                        const SizedBox(width: 8),

                        // "🤝 Hold Hands" Floating Button
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isHoldingHands = !_isHoldingHands;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isHoldingHands
                                      ? AppTheme.primaryPink
                                      : Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: _isHoldingHands
                                        ? AppTheme.primaryPink
                                        : AppTheme.primaryPink.withValues(alpha: 0.5),
                                    width: 1.4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isHoldingHands
                                          ? AppTheme.primaryPink
                                          : Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _isHoldingHands ? '❤️' : '🤝',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isHoldingHands ? 'Holding Hands' : 'Hold Hands',
                                      style: GoogleFonts.mali(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _isHoldingHands ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RenderItem {
  final double depth;
  final Offset screenPos;
  final double scale;
  final Widget widget;

  _RenderItem({
    required this.depth,
    required this.screenPos,
    required this.scale,
    required this.widget,
  });
}

class _WorldFeature {
  final WorldPos pos;
  final NatureObjectType type;

  _WorldFeature({
    required this.pos,
    required this.type,
  });
}

class _DirectionSign {
  final WorldPos pos;
  final String label;
  final String arrow;

  _DirectionSign({
    required this.pos,
    required this.label,
    required this.arrow,
  });
}
