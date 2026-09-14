import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/world_environment_config.dart';
import 'package:mimory/models/world_point.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/widgets/couple_character_pair_widget.dart';
import 'package:mimory/widgets/memory_walk_joystick.dart';
import 'package:mimory/widgets/memory_walk/animal_entity.dart';
import 'package:mimory/widgets/memory_walk/direction_signboard.dart';
import 'package:mimory/widgets/memory_walk/living_world_layers.dart';
import 'package:mimory/widgets/memory_walk/memory_landmark.dart';

/// The Stable Long-Range Memory Walk World.
/// Key Design Principles:
/// - Camera is STABLE and FIXED overlooking the expansive storybook world.
/// - NO camera rotation, NO tight chasing, NO progressive zooming.
/// - Single, comfortable movement joystick with generous touch area.
/// - Characters walk freely across the landscape; the world remains steady.
/// - Both characters are always visible side-by-side (👩🏻🤝👨🏻).
/// - Real connected hand-holding with heart pop.
/// - Dynamic Living World: World Style, Time of Day, Rain with shared umbrella,
///   Snow with footprints and accumulation, Night with moon & glowing lanterns,
///   and organic memory growth.
class StableMemoryWalkWorldWidget extends StatefulWidget {
  final World world;
  final Character userCharacter;
  final Character companionCharacter;
  final List<Memory> memories;
  final WorldEnvironmentConfig? initialConfig;
  final VoidCallback onExit;
  final Function(Memory) onVisitMemory;

  const StableMemoryWalkWorldWidget({
    super.key,
    required this.world,
    required this.userCharacter,
    required this.companionCharacter,
    required this.memories,
    this.initialConfig,
    required this.onExit,
    required this.onVisitMemory,
  });

  @override
  State<StableMemoryWalkWorldWidget> createState() =>
      _StableMemoryWalkWorldWidgetState();
}

class _StableMemoryWalkWorldWidgetState
    extends State<StableMemoryWalkWorldWidget>
    with TickerProviderStateMixin {
  // Couple state
  Offset? _couplePos;
  bool _isWalking = false;
  bool _facingRight = true;
  bool _isHoldingHands = false;

  // Living environment state
  late WorldEnvironmentConfig _environmentConfig;

  // Joystick & game loop
  Offset _joystickDirection = Offset.zero;
  Timer? _gameLoopTimer;

  // Ambient controller for drifting clouds & swaying elements
  late AnimationController _ambientController;

  // Living animals
  final List<AnimalEntity> _animals = [];

  // Proximity states
  Memory? _nearbyMemory;
  AnimalEntity? _nearbyAnimal;

  @override
  void initState() {
    super.initState();

    _environmentConfig = widget.initialConfig ??
        WorldEnvironmentConfig.fromNaturalTime(
          worldStyle: widget.world.worldStyle,
          memoryCount: widget.memories.length,
        );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _initializeAnimals();
    _startGameLoop();
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _ambientController.dispose();
    super.dispose();
  }

  void _initializeAnimals() {
    _animals.clear();
    final isRain = _environmentConfig.condition == WorldCondition.rain;
    _animals.add(AnimalEntity(
      id: 'rabbit_1',
      type: AnimalType.rabbit,
      worldPos: const WorldPos(0.0, 0.0, 0.0),
      speechText: isRain ? 'Rainy day ♡' : 'Come with me ♡',
    ));
    _animals.add(AnimalEntity(
      id: 'squirrel_1',
      type: AnimalType.squirrel,
      worldPos: const WorldPos(0.0, 0.0, 0.0),
      speechText: 'Look what I found!',
    ));
    _animals.add(AnimalEntity(
      id: 'bird_1',
      type: AnimalType.bird,
      worldPos: const WorldPos(0.0, 0.0, 0.0),
    ));
    _animals.add(AnimalEntity(
      id: 'butterfly_1',
      type: AnimalType.butterfly,
      worldPos: const WorldPos(0.0, 0.0, 0.0),
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
    if (_couplePos == null) return;

    if (_isWalking && _joystickDirection != Offset.zero) {
      const speed = 2.6;
      final dx = _joystickDirection.dx * speed;
      final dy = _joystickDirection.dy * speed;

      if (_joystickDirection.dx > 0.08) {
        _facingRight = true;
      } else if (_joystickDirection.dx < -0.08) {
        _facingRight = false;
      }

      setState(() {
        _couplePos = Offset(_couplePos!.dx + dx, _couplePos!.dy + dy);
      });
    }

    _updateProximities();
  }

  void _updateProximities() {
    if (_couplePos == null) return;

    // Check memory proximity
    Memory? closestMem;
    double minMemDist = 58.0;

    for (int i = 0; i < widget.memories.length; i++) {
      final memPos = _getMemoryPosition(i, MediaQuery.of(context).size);
      final dist = (_couplePos! - memPos).distance;
      if (dist < minMemDist) {
        closestMem = widget.memories[i];
        minMemDist = dist;
      }
    }

    if (_nearbyMemory != closestMem) {
      setState(() {
        _nearbyMemory = closestMem;
      });
    }

    // Check animal proximity
    AnimalEntity? closestAnimal;
    double minAnimalDist = 48.0;

    for (int i = 0; i < _animals.length; i++) {
      final animal = _animals[i];
      final aPos = _getAnimalPosition(i, MediaQuery.of(context).size);
      final dist = (_couplePos! - aPos).distance;
      if (dist < minAnimalDist) {
        closestAnimal = animal;
        minAnimalDist = dist;
      }
    }

    if (_nearbyAnimal != closestAnimal) {
      setState(() {
        _nearbyAnimal = closestAnimal;
      });
    }
  }

  Offset _getMemoryPosition(int index, Size size) {
    final positions = [
      Offset(size.width * 0.68, size.height * 0.52),
      Offset(size.width * 0.30, size.height * 0.68),
      Offset(size.width * 0.72, size.height * 0.78),
      Offset(size.width * 0.26, size.height * 0.44),
      Offset(size.width * 0.75, size.height * 0.38),
    ];
    return positions[index % positions.length];
  }

  Offset _getAnimalPosition(int index, Size size) {
    // In rain, rabbit seeks shelter under the left storybook tree/bush
    final isRain = _environmentConfig.condition == WorldCondition.rain;
    final rabbitPos = isRain
        ? Offset(size.width * 0.20, size.height * 0.50)
        : Offset(size.width * 0.46, size.height * 0.58);

    final positions = [
      rabbitPos, // Rabbit
      Offset(size.width * 0.82, size.height * 0.65), // Squirrel
      Offset(size.width * 0.22, size.height * 0.48), // Bird
      Offset(size.width * 0.55, size.height * 0.74), // Butterfly
    ];
    return positions[index % positions.length];
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

  /// Discreet developer debug control to preview all Living World states.
  void _showEnvironmentDebugSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Living World Environment',
                          style: GoogleFonts.mali(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.creamDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Debug / Preview',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Time of Day selector
                    Text('Time of Day',
                        style: GoogleFonts.nunito(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: TimeOfDayState.values.map((tod) {
                        final isSel = _environmentConfig.timeOfDay == tod;
                        return ChoiceChip(
                          label: Text(tod.label),
                          selected: isSel,
                          onSelected: (_) {
                            setState(() {
                              _environmentConfig =
                                  _environmentConfig.copyWith(timeOfDay: tod);
                            });
                            setModalState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // World Condition (Weather) selector
                    Text('Atmosphere & Weather',
                        style: GoogleFonts.nunito(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: WorldCondition.values.map((cond) {
                        final isSel = _environmentConfig.condition == cond;
                        return ChoiceChip(
                          label: Text(cond.label),
                          selected: isSel,
                          onSelected: (_) {
                            setState(() {
                              _environmentConfig =
                                  _environmentConfig.copyWith(condition: cond);
                              if (cond == WorldCondition.rain) {
                                _animals.first.speechText = 'Rainy day ♡';
                              }
                            });
                            setModalState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Seasons selector
                    Text('Season',
                        style: GoogleFonts.nunito(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: SeasonState.values.map((s) {
                        final isSel = _environmentConfig.season == s;
                        return ChoiceChip(
                          label: Text(s.label),
                          selected: isSel,
                          onSelected: (_) {
                            setState(() {
                              _environmentConfig =
                                  _environmentConfig.copyWith(season: s);
                            });
                            setModalState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // World Style selector
                    Text('World Style',
                        style: GoogleFonts.nunito(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ('cozy_town', 'Cozy Town 🏡'),
                        ('starlit_forest', 'Forest 🌲'),
                        ('blooming_meadow', 'Garden 🌸'),
                        ('sunlit_valley', 'Seaside 🌊'),
                      ].map((tuple) {
                        final isSel = _environmentConfig.worldStyle == tuple.$1;
                        return ChoiceChip(
                          label: Text(tuple.$2),
                          selected: isSel,
                          onSelected: (_) {
                            setState(() {
                              _environmentConfig =
                                  _environmentConfig.copyWith(worldStyle: tuple.$1);
                            });
                            setModalState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        _couplePos ??= Offset(size.width * 0.50, size.height * 0.64);

        final clampedX = _couplePos!.dx.clamp(36.0, size.width - 36.0);
        final clampedY = _couplePos!.dy.clamp(size.height * 0.34, size.height - 90.0);
        if (_couplePos!.dx != clampedX || _couplePos!.dy != clampedY) {
          _couplePos = Offset(clampedX, clampedY);
        }

        final isRain = _environmentConfig.condition == WorldCondition.rain;
        final isSnow = _environmentConfig.condition == WorldCondition.snow;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. BASE STORYBOOK LANDSCAPE with Dynamic Environment
              CustomPaint(
                size: size,
                painter: _StableLongRangeWorldPainter(
                  ambientTime: _ambientController.value,
                  memoryCount: widget.memories.length,
                  config: _environmentConfig,
                ),
              ),

              // 2. NIGHT SKY LAYER (Moon & Stars)
              if (_environmentConfig.timeOfDay == TimeOfDayState.night)
                StarsAndMoonLayer(animationValue: _ambientController.value),

              // 3. DIRECTION BOARDS along the path
              _buildDirectionSign(
                pos: Offset(size.width * 0.24, size.height * 0.56),
                label: widget.memories.isNotEmpty
                    ? '📷 ${widget.memories.first.title.toUpperCase()}'
                    : '📷 MEETUP',
                arrow: '→',
              ),
              _buildDirectionSign(
                pos: Offset(size.width * 0.74, size.height * 0.44),
                label: widget.memories.length > 1
                    ? '🌸 ${widget.memories[1].title.toUpperCase()}'
                    : '🌸 FIRST TRIP',
                arrow: '←',
              ),
              _buildDirectionSign(
                pos: Offset(size.width * 0.52, size.height * 0.36),
                label: '🌱 KEEP EXPLORING',
                arrow: '↑',
              ),

              // 4. PHYSICAL MEMORY LANDMARKS (Reacting to Environment)
              ...List.generate(widget.memories.length, (i) {
                final mem = widget.memories[i];
                final pos = _getMemoryPosition(i, size);
                final isNear = _nearbyMemory == mem;

                return Positioned(
                  left: pos.dx - 45,
                  top: pos.dy - 48,
                  child: MemoryLandmarkWidget(
                    memory: mem,
                    isNearby: isNear,
                    scale: 0.92,
                    condition: _environmentConfig.condition,
                    timeOfDay: _environmentConfig.timeOfDay,
                    onTap: () => widget.onVisitMemory(mem),
                  ),
                );
              }),

              // 5. LIVING ROAMING ANIMALS (Reacting to Weather)
              ...List.generate(_animals.length, (i) {
                final animal = _animals[i];
                final pos = _getAnimalPosition(i, size);

                return Positioned(
                  left: pos.dx - 24,
                  top: pos.dy - 24,
                  child: AnimalWidget(
                    animal: animal,
                    scale: 0.95,
                    isRaining: isRain,
                    isSnowing: isSnow,
                    onTap: () => _handleFeedAnimal(animal),
                  ),
                );
              }),

              // 6. THE COUPLE CHARACTERS (Shared Umbrella in Rain, Warm Accents in Snow)
              Positioned(
                left: _couplePos!.dx - 28,
                top: _couplePos!.dy - 38,
                child: CoupleCharacterPairWidget(
                  userCharacter: widget.userCharacter,
                  companionCharacter: widget.companionCharacter,
                  isHoldingHands: _isHoldingHands,
                  isWalking: _isWalking,
                  facingRight: _facingRight,
                  isLookingAtMemory: _nearbyMemory != null,
                  isPlatonic: widget.world.relationshipType == 'best_friend',
                  isRaining: isRain,
                  isSnowing: isSnow,
                  onHandHoldingToggled: () {
                    setState(() {
                      _isHoldingHands = !_isHoldingHands;
                    });
                  },
                ),
              ),

              // 7. ISOLATED ATMOSPHERIC & PARTICLE LAYERS
              if (isRain) RainLayer(animationValue: _ambientController.value),
              if (isSnow) SnowLayer(animationValue: _ambientController.value),
              if (_environmentConfig.timeOfDay == TimeOfDayState.night ||
                  _environmentConfig.worldStyle == 'starlit_forest')
                FireflyLayer(animationValue: _ambientController.value),
              if (_environmentConfig.condition == WorldCondition.sunny &&
                  (_environmentConfig.timeOfDay == TimeOfDayState.day ||
                      _environmentConfig.worldStyle == 'blooming_meadow'))
                ButterflyLayer(animationValue: _ambientController.value),
              if (_environmentConfig.season == SeasonState.autumn)
                FallingLeavesLayer(animationValue: _ambientController.value),
              if (_environmentConfig.ambientLightOverlayColor != null)
                AmbientLightLayer(
                    overlayColor: _environmentConfig.ambientLightOverlayColor!),

              // 8. TOP HUD: Exit Walk & Living Memory Walk Title
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE8DECF),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
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

                        // Cozy Walk Title Badge (Tapping opens debug preview in debug mode)
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _showEnvironmentDebugSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.90),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.primaryPink
                                        .withValues(alpha: 0.35),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _environmentConfig.timeOfDay ==
                                              TimeOfDayState.night
                                          ? '🌙'
                                          : (isRain
                                              ? '🌧️'
                                              : (isSnow ? '❄️' : '♡')),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Memory Walk ♡',
                                      style: GoogleFonts.mali(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryPink,
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

              // 9. CONTEXTUAL PROMPT: "Visit Memory ♡"
              if (_nearbyMemory != null)
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 110.0, left: 16.0, right: 16.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GestureDetector(
                          onTap: () => widget.onVisitMemory(_nearbyMemory!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: AppTheme.primaryPink,
                                width: 1.6,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryPink
                                      .withValues(alpha: 0.35),
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

              // 10. CONTEXTUAL PROMPT: Animal Feed / Carrot
              if (_nearbyAnimal != null && !_nearbyAnimal!.isFed)
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 110.0, left: 16.0, right: 16.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GestureDetector(
                          onTap: () => _handleFeedAnimal(_nearbyAnimal!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFFFA500),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFA500)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🥕', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  'Feed ${_nearbyAnimal!.type.name} ♡',
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

              // 11. BOTTOM CONTROLS: Joystick & Hold Hands Button
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isHoldingHands
                                      ? AppTheme.primaryPink
                                      : Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: _isHoldingHands
                                        ? AppTheme.primaryPink
                                        : AppTheme.primaryPink
                                            .withValues(alpha: 0.5),
                                    width: 1.4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isHoldingHands
                                          ? AppTheme.primaryPink
                                              .withValues(alpha: 0.4)
                                          : Colors.black
                                              .withValues(alpha: 0.08),
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
                                      _isHoldingHands
                                          ? 'Holding Hands'
                                          : 'Hold Hands',
                                      style: GoogleFonts.mali(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _isHoldingHands
                                            ? Colors.white
                                            : AppTheme.textPrimary,
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

  Widget _buildDirectionSign({
    required Offset pos,
    required String label,
    required String arrow,
  }) {
    return Positioned(
      left: pos.dx - 45,
      top: pos.dy - 20,
      child: DirectionSignboardWidget(
        label: label,
        arrow: arrow,
        scale: 0.88,
      ),
    );
  }
}

/// Dynamic Living Storybook World Painter:
/// - World Style specific architecture & flora
/// - Time of Day sky gradients & ambient lighting
/// - Snow drifts and accumulation
/// - Road surface with rain reflections
/// - Storybook cottages with warm glowing windows
class _StableLongRangeWorldPainter extends CustomPainter {
  final double ambientTime;
  final int memoryCount;
  final WorldEnvironmentConfig config;

  _StableLongRangeWorldPainter({
    required this.ambientTime,
    required this.memoryCount,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.28;

    // 1. Dynamic Sky Gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: config.skyColors,
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, horizonY + 2));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, horizonY + 2), skyPaint);

    // 2. Distant Horizon Mountains
    final mountainPaint = Paint()
      ..color = config.mountainColor
      ..style = PaintingStyle.fill;
    final mPath = Path();
    mPath.moveTo(0, horizonY);
    mPath.quadraticBezierTo(size.width * 0.25, horizonY - 22, size.width * 0.52, horizonY);
    mPath.quadraticBezierTo(size.width * 0.78, horizonY - 28, size.width, horizonY - 4);
    mPath.lineTo(size.width, horizonY);
    mPath.close();
    canvas.drawPath(mPath, mountainPaint);

    // 3. Drifting Clouds (Unless Night)
    if (config.timeOfDay != TimeOfDayState.night) {
      final cloudPaint = Paint()
        ..color = (config.condition == WorldCondition.rain)
            ? const Color(0xFFBAC9D6).withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      final cloudX1 = (ambientTime * 16) % (size.width + 120) - 60;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cloudX1, horizonY * 0.45), width: 85, height: 24),
        cloudPaint,
      );
      final cloudX2 = ((ambientTime * 10) + 180) % (size.width + 120) - 60;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cloudX2, horizonY * 0.65), width: 100, height: 26),
        cloudPaint,
      );
    }

    // 4. Layered Rolling Meadow Knolls
    final grassColors = config.meadowGrassColors;
    final farMeadowPaint = Paint()..color = grassColors[0];
    final midMeadowPaint = Paint()..color = grassColors[1];
    final foreMeadowPaint = Paint()..color = grassColors[2];

    // Far Meadow Knoll
    final farPath = Path();
    farPath.moveTo(0, horizonY);
    farPath.quadraticBezierTo(size.width * 0.35, horizonY + 20, size.width * 0.70, horizonY + 8);
    farPath.quadraticBezierTo(size.width * 0.90, horizonY + 16, size.width, horizonY + 10);
    farPath.lineTo(size.width, size.height);
    farPath.lineTo(0, size.height);
    farPath.close();
    canvas.drawPath(farPath, farMeadowPaint);

    // Mid Meadow Knoll
    final midY = size.height * 0.44;
    final midPath = Path();
    midPath.moveTo(0, midY);
    midPath.quadraticBezierTo(size.width * 0.4, midY - 20, size.width * 0.8, midY + 18);
    midPath.lineTo(size.width, size.height);
    midPath.lineTo(0, size.height);
    midPath.close();
    canvas.drawPath(midPath, midMeadowPaint);

    // Fore Meadow Knoll
    final foreY = size.height * 0.62;
    final forePath = Path();
    forePath.moveTo(0, foreY + 15);
    forePath.quadraticBezierTo(size.width * 0.45, foreY - 25, size.width, foreY + 10);
    forePath.lineTo(size.width, size.height);
    forePath.lineTo(0, size.height);
    forePath.close();
    canvas.drawPath(forePath, foreMeadowPaint);

    // 5. Winding Countryside Road
    _drawWindingRoad(canvas, size);

    // 6. World Style Specific Landscape Flora & Structures
    _drawStyleSpecificWorld(canvas, size);
  }

  void _drawWindingRoad(Canvas canvas, Size size) {
    final startY = size.height * 0.32;

    // Outer Road Border
    final borderPaint = Paint()
      ..color = config.roadBorderColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 48.0;

    // Main Road Surface
    final roadPaint = Paint()
      ..color = config.roadColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 42.0;

    final roadPath = Path();
    roadPath.moveTo(size.width * 0.52, startY);
    roadPath.quadraticBezierTo(
      size.width * 0.36,
      size.height * 0.48,
      size.width * 0.54,
      size.height * 0.65,
    );
    roadPath.quadraticBezierTo(
      size.width * 0.68,
      size.height * 0.78,
      size.width * 0.46,
      size.height + 20,
    );

    canvas.drawPath(roadPath, borderPaint);
    canvas.drawPath(roadPath, roadPaint);

    // Road Cobblestone & Environment Accents
    if (config.condition == WorldCondition.snow) {
      // Snow drifts along road border
      final snowDriftPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
      canvas.drawCircle(Offset(size.width * 0.39, size.height * 0.50), 7, snowDriftPaint);
      canvas.drawCircle(Offset(size.width * 0.59, size.height * 0.68), 8, snowDriftPaint);
      canvas.drawCircle(Offset(size.width * 0.44, size.height * 0.80), 9, snowDriftPaint);
    } else if (config.condition == WorldCondition.rain) {
      // Puddle ripples on the road
      final puddlePaint = Paint()
        ..color = const Color(0xFF9EAFBF).withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.48, size.height * 0.60),
            width: 18,
            height: 6),
        puddlePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.58, size.height * 0.73),
            width: 14,
            height: 5),
        puddlePaint,
      );
    } else {
      // Regular storybook pebbles
      final pebblePaint = Paint()..color = const Color(0xFFE2D6C6);
      canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.52), 3.0, pebblePaint);
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.61), 2.5, pebblePaint);
      canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.72), 3.2, pebblePaint);
      canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.82), 2.8, pebblePaint);
    }
  }

  void _drawStyleSpecificWorld(Canvas canvas, Size size) {
    // 1. World Style Base Architecture
    switch (config.worldStyle) {
      case 'cozy_town':
        _drawCozyTownElements(canvas, size);
        break;
      case 'starlit_forest':
        _drawForestElements(canvas, size);
        break;
      case 'blooming_meadow':
        _drawGardenElements(canvas, size);
        break;
      case 'sunlit_valley':
        _drawSeasideElements(canvas, size);
        break;
      default:
        _drawCozyTownElements(canvas, size);
    }

    // 2. Standard Storybook Trees & Bushes (Colored by Season / Environment)
    _drawStorybookTree(canvas, size.width * 0.14, size.height * 0.48, 28, 48);
    _drawStorybookTree(canvas, size.width * 0.86, size.height * 0.55, 32, 54);
    _drawStorybookTree(canvas, size.width * 0.72, size.height * 0.35, 18, 30);

    _drawStorybookBush(canvas, size.width * 0.18, size.height * 0.70, 24);
    _drawStorybookBush(canvas, size.width * 0.78, size.height * 0.72, 22);

    // 3. Flowers
    _drawFlowerCluster(canvas, Offset(size.width * 0.28, size.height * 0.62));
    _drawFlowerCluster(canvas, Offset(size.width * 0.64, size.height * 0.58));
    _drawFlowerCluster(canvas, Offset(size.width * 0.38, size.height * 0.78));

    // 4. Memory Growth Enrichments
    if (config.memoryCount >= 2) {
      _drawFlowerCluster(canvas, Offset(size.width * 0.72, size.height * 0.84));
      _drawStorybookBush(canvas, size.width * 0.32, size.height * 0.82, 18);
    }
    if (config.memoryCount >= 4) {
      _drawStorybookTree(canvas, size.width * 0.28, size.height * 0.36, 16, 26);
      _drawFlowerCluster(canvas, Offset(size.width * 0.82, size.height * 0.80));
    }
  }

  /// Cozy Town: Storybook cottages with warm glowing windows, wooden fences, lanterns.
  void _drawCozyTownElements(Canvas canvas, Size size) {
    // Left Hillside Cottage
    _drawCottage(canvas, size.width * 0.12, size.height * 0.32, 38, 30);
    // Right Hillside Cottage
    _drawCottage(canvas, size.width * 0.82, size.height * 0.33, 34, 26);

    // Wooden picket fences along path
    final fencePaint = Paint()
      ..color = const Color(0xFFC7A779)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final fenceY = size.height * 0.65;
    for (int i = 0; i < 4; i++) {
      final fx = size.width * 0.16 + (i * 9);
      canvas.drawLine(Offset(fx, fenceY), Offset(fx, fenceY + 12), fencePaint);
    }
    canvas.drawLine(
      Offset(size.width * 0.14, fenceY + 4),
      Offset(size.width * 0.20, fenceY + 4),
      fencePaint..strokeWidth = 2.0,
    );
  }

  /// Storybook Cottage with roof and warm windows
  void _drawCottage(
      Canvas canvas, double x, double y, double width, double height) {
    // Cottage walls (warm cream)
    final wallPaint = Paint()..color = const Color(0xFFFFF2DC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y + 10, width, height - 10),
        const Radius.circular(3),
      ),
      wallPaint,
    );

    // Terracotta roof
    final roofPaint = Paint()..color = const Color(0xFFC2614B);
    final roofPath = Path();
    roofPath.moveTo(x - 4, y + 10);
    roofPath.lineTo(x + width / 2, y - 2);
    roofPath.lineTo(x + width + 4, y + 10);
    roofPath.close();
    canvas.drawPath(roofPath, roofPaint);

    // Snow on roof in Snow mode
    if (config.condition == WorldCondition.snow) {
      final snowRoofPaint = Paint()..color = Colors.white.withValues(alpha: 0.95);
      final snowPath = Path();
      snowPath.moveTo(x - 5, y + 8);
      snowPath.lineTo(x + width / 2, y - 4);
      snowPath.lineTo(x + width + 5, y + 8);
      snowPath.lineTo(x + width + 5, y + 11);
      snowPath.lineTo(x - 5, y + 11);
      snowPath.close();
      canvas.drawPath(snowPath, snowRoofPaint);
    }

    // Warm Window (Glows at Night / Sunset)
    final windowPaint = Paint()
      ..color = config.areLightsGlowing
          ? const Color(0xFFFFE066)
          : const Color(0xFFB5D4E8);

    if (config.areLightsGlowing) {
      // Soft window light glow
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(x + width / 2, y + 18), 8, glowPaint);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(x + width / 2, y + 18), width: 10, height: 10),
        const Radius.circular(2),
      ),
      windowPaint,
    );
  }

  /// Forest: Dense pine trees, moss patches, mushrooms, rocks.
  void _drawForestElements(Canvas canvas, Size size) {
    // Dense evergreen pines
    _drawPineTree(canvas, size.width * 0.08, size.height * 0.38, 20, 50);
    _drawPineTree(canvas, size.width * 0.88, size.height * 0.36, 22, 55);

    // Forest mushrooms
    _drawMushroom(canvas, size.width * 0.22, size.height * 0.66);
    _drawMushroom(canvas, size.width * 0.74, size.height * 0.68);

    // Mossy rocks
    final rockPaint = Paint()..color = const Color(0xFF7A8B7B);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(size.width * 0.16, size.height * 0.58),
          width: 22,
          height: 12),
      rockPaint,
    );
  }

  void _drawPineTree(
      Canvas canvas, double x, double y, double width, double height) {
    // Trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF5A3818)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, y + height * 0.4), Offset(x, y + height), trunkPaint);

    // Tiered triangular pine foliage
    final pineColor = (config.condition == WorldCondition.snow)
        ? const Color(0xFF68897E)
        : const Color(0xFF386641);
    final pinePaint = Paint()..color = pineColor;

    for (int tier = 0; tier < 3; tier++) {
      final tierY = y + (tier * 12);
      final tierW = width + (tier * 6);
      final pPath = Path();
      pPath.moveTo(x, tierY - 10);
      pPath.lineTo(x - tierW / 2, tierY + 12);
      pPath.lineTo(x + tierW / 2, tierY + 12);
      pPath.close();
      canvas.drawPath(pPath, pinePaint);
    }
  }

  void _drawMushroom(Canvas canvas, double x, double y) {
    // White stem
    final stemPaint = Paint()..color = const Color(0xFFFAF0E6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 2, y, 4, 7),
        const Radius.circular(2),
      ),
      stemPaint,
    );
    // Red spotted cap
    final capPaint = Paint()..color = const Color(0xFFD63447);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(x, y + 1), width: 12, height: 10),
      math.pi,
      math.pi,
      true,
      capPaint,
    );
    // White dot
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(x, y - 2), 1.0, dotPaint);
  }

  /// Garden: Rich flowerbeds, pond with water ripples.
  void _drawGardenElements(Canvas canvas, Size size) {
    // Small garden pond
    final pondPaint = Paint()..color = const Color(0xFF8AC4D0);
    final pondCenter = Offset(size.width * 0.80, size.height * 0.46);
    canvas.drawOval(
      Rect.fromCenter(center: pondCenter, width: 42, height: 20),
      pondPaint,
    );
    // Lily pad in pond
    final lilyPaint = Paint()..color = const Color(0xFF539165);
    canvas.drawCircle(Offset(pondCenter.dx - 6, pondCenter.dy), 4.5, lilyPaint);
  }

  /// Seaside: Coastal stream with ripples and smooth beach stones.
  void _drawSeasideElements(Canvas canvas, Size size) {
    // Coastal water stream
    final waterPaint = Paint()..color = const Color(0xFF78C0E0);
    final wavePath = Path();
    wavePath.moveTo(size.width * 0.70, size.height * 0.30);
    wavePath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.45,
      size.width,
      size.height * 0.48,
    );
    wavePath.lineTo(size.width, size.height * 0.30);
    wavePath.close();
    canvas.drawPath(wavePath, waterPaint);

    // Beach reeds
    final reedPaint = Paint()
      ..color = const Color(0xFFBDC581)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(size.width * 0.74, size.height * 0.44),
        Offset(size.width * 0.73, size.height * 0.36), reedPaint);
    canvas.drawLine(Offset(size.width * 0.77, size.height * 0.46),
        Offset(size.width * 0.78, size.height * 0.38), reedPaint);
  }

  void _drawStorybookTree(
      Canvas canvas, double x, double y, double radius, double height) {
    final shadowPaint = Paint()
      ..color = const Color(0xFF2E4624).withValues(alpha: 0.25);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + height), width: radius * 1.6, height: 8),
      shadowPaint,
    );

    // Trunk
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B5A2B)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, y + height * 0.25), Offset(x, y + height), trunkPaint);

    // Foliage from config colors
    final (foliageBack, foliageFront) = config.treeFoliageColors;
    final backPaint = Paint()..color = foliageBack;
    final frontPaint = Paint()..color = foliageFront;

    canvas.drawCircle(Offset(x - 5, y - 4), radius * 0.65, backPaint);
    canvas.drawCircle(Offset(x + 6, y - 2), radius * 0.70, backPaint);
    canvas.drawCircle(Offset(x, y - 14), radius * 0.75, frontPaint);

    // Snow caps on trees in snow mode
    if (config.condition == WorldCondition.snow) {
      final snowPaint = Paint()..color = Colors.white.withValues(alpha: 0.90);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(x, y - 14), radius: radius * 0.75),
        math.pi * 1.1,
        math.pi * 0.8,
        true,
        snowPaint,
      );
    }
  }

  void _drawStorybookBush(Canvas canvas, double x, double y, double radius) {
    final shadowPaint = Paint()
      ..color = const Color(0xFF2E4624).withValues(alpha: 0.20);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 4), width: radius * 1.5, height: 6),
      shadowPaint,
    );

    final (foliageBack, foliageFront) = config.treeFoliageColors;
    final bushPaint = Paint()..color = foliageBack;
    canvas.drawCircle(Offset(x - 6, y - 2), radius * 0.55, bushPaint);
    canvas.drawCircle(Offset(x + 6, y - 1), radius * 0.60, bushPaint);
    canvas.drawCircle(Offset(x, y - 8), radius * 0.65, Paint()..color = foliageFront);
  }

  void _drawFlowerCluster(Canvas canvas, Offset center) {
    if (config.condition == WorldCondition.snow) {
      // In snow, winter berries appear
      final redPaint = Paint()..color = const Color(0xFFD62828);
      canvas.drawCircle(Offset(center.dx - 3, center.dy), 2.2, redPaint);
      canvas.drawCircle(Offset(center.dx + 3, center.dy), 2.2, redPaint);
      return;
    }

    final pinkPaint = Paint()..color = AppTheme.primaryPink;
    final yellowPaint = Paint()..color = const Color(0xFFFFD166);

    canvas.drawCircle(Offset(center.dx - 4, center.dy), 2.5, pinkPaint);
    canvas.drawCircle(Offset(center.dx + 4, center.dy), 2.5, yellowPaint);
    canvas.drawCircle(Offset(center.dx, center.dy - 3), 2.2, pinkPaint);
  }

  @override
  bool shouldRepaint(covariant _StableLongRangeWorldPainter oldDelegate) => true;
}
