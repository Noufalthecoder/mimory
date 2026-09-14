import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/models/avatar_definition.dart';
import 'package:mimory/services/world_service.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/widgets/world_environment.dart';
import 'package:mimory/widgets/world_camera.dart';
import 'package:mimory/widgets/world_header.dart';
import 'package:mimory/widgets/world_add_button.dart';
import 'package:mimory/widgets/world_nav_bar.dart';
import 'package:mimory/widgets/memory_object.dart';
import 'package:mimory/widgets/couple_character_pair_widget.dart';
import 'package:mimory/features/memory/screens/memory_detail_sheet.dart';
import 'package:mimory/features/memory/screens/first_memory_screen.dart';
import 'package:mimory/features/world/screens/your_worlds_screen.dart';
import 'package:mimory/widgets/memory_walk/stable_memory_walk_world.dart';
import 'package:mimory/models/world_environment_config.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';

/// The Living World Screen — Featuring the Interactive Memory Walk & Camera System.
/// In Normal World Mode, the couple stands peacefully in the meadow with subtle idle animation.
/// In Memory Walk Mode, the camera smoothly zooms in and follows the couple as they hold hands,
/// explore the winding storybook road via a soft joystick, and visit physical memory objects.
class WorldScreen extends StatefulWidget {
  final World world;
  final bool showEntryTransition;

  const WorldScreen({
    super.key,
    required this.world,
    this.showEntryTransition = false,
  });

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen>
    with TickerProviderStateMixin {
  WorldNavTab _activeTab = WorldNavTab.world;

  // Entry transition controller
  late AnimationController _transitionController;
  late Animation<double> _sparkScale;
  late Animation<double> _sparkFade;
  late Animation<double> _worldFade;
  late Animation<double> _welcomeTextFade;
  bool _transitionCompleted = false;

  // Ambient loop controller for drifting clouds & floating particles
  late AnimationController _ambientController;

  // Camera Zoom Controller (Distant 1.0 <-> Walking 1.85)
  late AnimationController _cameraZoomController;
  late Animation<double> _cameraZoomAnimation;

  // Memory Walk State
  bool _isMemoryWalkMode = false;
  bool _isHoldingHands = false;

  late WorldEnvironmentConfig _environmentConfig;

  Offset? _couplePosition;
  Offset? _cameraFocus;

  @override
  void initState() {
    super.initState();

    _environmentConfig = WorldEnvironmentConfig.fromNaturalTime(
      worldStyle: widget.world.worldStyle,
      memoryCount: 0,
    );

    // Entry Transition (used on initial first-memory reveal)
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _sparkScale = Tween<double>(begin: 0.2, end: 1.2).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
      ),
    );

    _sparkFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.35, 0.55, curve: Curves.easeOut),
      ),
    );

    _worldFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeIn),
      ),
    );

    _welcomeTextFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.showEntryTransition) {
      _transitionController.forward().then((_) {
        if (mounted) {
          setState(() {
            _transitionCompleted = true;
          });
        }
      });
    } else {
      _transitionCompleted = true;
      _transitionController.value = 1.0;
    }

    // Ambient loop
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Camera Zoom Controller (1.0 in Distant World View, 1.85 in Walking View)
    _cameraZoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _cameraZoomAnimation = Tween<double>(begin: 1.0, end: 1.85).animate(
      CurvedAnimation(
        parent: _cameraZoomController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _ambientController.dispose();
    _cameraZoomController.dispose();
    super.dispose();
  }

  void _skipTransition() {
    if (!_transitionCompleted) {
      _transitionController.stop();
      setState(() {
        _transitionCompleted = true;
      });
    }
  }

  // MEMORY WALK MODE TRANSITIONS

  void _enterMemoryWalk() {
    setState(() {
      _isMemoryWalkMode = true;
    });
  }

  void _exitMemoryWalk() {
    setState(() {
      _isMemoryWalkMode = false;
      _isHoldingHands = false;
    });
  }

  void _handleTabSelected(WorldNavTab tab) {
    if (tab == WorldNavTab.timeline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Timeline will unfold as your story grows. ♡',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.textPrimary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    if (tab == WorldNavTab.memories) {
      _showMemoriesOverview();
      return;
    }

    setState(() {
      _activeTab = tab;
    });
  }

  void _showMemoriesOverview() {
    final memories = WorldService().getMemoriesForWorld(widget.world.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCCFBE),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Moments in this World',
                    style: GoogleFonts.mali(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${memories.length} ${memories.length == 1 ? 'memory' : 'memories'} resting here. ♡',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: memories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const StorybookSprout(size: 32),
                                const SizedBox(height: 12),
                                Text(
                                  'Every little world starts somewhere.',
                                  style: GoogleFonts.mali(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add your first moment to bring it to life. ♡',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: memories.length,
                            physics: const BouncingScrollPhysics(),
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final mem = memories[index];
                              final isPhoto = mem.type == MemoryType.photo;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  MemoryDetailSheet.show(context, mem);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFEFE8DE),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isPhoto
                                              ? AppTheme.primaryPink.withValues(alpha: 0.12)
                                              : const Color(0xFF90C2A3).withValues(alpha: 0.18),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isPhoto
                                              ? Icons.photo_camera_back_rounded
                                              : Icons.menu_book_rounded,
                                          color: isPhoto
                                              ? AppTheme.primaryPink
                                              : const Color(0xFF4C7B5D),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              mem.title,
                                              style: GoogleFonts.nunito(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${mem.memoryDate.day}/${mem.memoryDate.month}/${mem.memoryDate.year}',
                                              style: GoogleFonts.nunito(
                                                fontSize: 12,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppTheme.textSecondary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ALWAYS fetch memories strictly matching this World's id
    final memories = WorldService().getMemoriesForWorld(widget.world.id);
    final memoryCount = memories.length;

    // Characters for this world
    final characters = WorldService().getCharactersForWorld(widget.world.id);
    final userCharacter = characters.firstWhere(
      (c) => c.isCurrentUser,
      orElse: () => characters.isNotEmpty
          ? characters.first
          : AvatarDefinition.getById(widget.world.userAvatarId).toCharacter(
              id: 'user_${widget.world.id}',
              worldId: widget.world.id,
              personName: 'You',
              isCurrentUser: true,
            ),
    );
    final companionCharacter = characters.firstWhere(
      (c) => !c.isCurrentUser,
      orElse: () => characters.length > 1
          ? characters[1]
          : AvatarDefinition.getById(widget.world.companionAvatarId).toCharacter(
              id: 'companion_${widget.world.id}',
              worldId: widget.world.id,
              personName: widget.world.personName,
              isCurrentUser: false,
              photoPath: widget.world.personPhotoPath,
            ),
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _skipTransition,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 550),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          child: _isMemoryWalkMode
              ? StableMemoryWalkWorldWidget(
                  key: const ValueKey('stable_memory_walk_world_active'),
                  world: widget.world,
                  userCharacter: userCharacter,
                  companionCharacter: companionCharacter,
                  memories: memories,
                  initialConfig: _environmentConfig,
                  onExit: _exitMemoryWalk,
                  onVisitMemory: (mem) {
                    MemoryDetailSheet.show(context, mem);
                  },
                )
              : LayoutBuilder(
                  key: const ValueKey('distant_world_overview'),
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;
                    final screenSize = Size(width, height);

                    // Default couple & camera coordinates
                    _couplePosition ??= Offset(width * 0.50, height * 0.52);
                    _cameraFocus ??= Offset(width * 0.50, height * 0.54);

                    return Stack(
                      children: [
                        // WorldCamera with Zoom, Follow, and Multi-Layer Parallax
                        AnimatedBuilder(
                          animation: Listenable.merge([_cameraZoomAnimation, _ambientController]),
                          builder: (context, _) {
                            final currentZoom = _cameraZoomAnimation.value;
                            final targetFocus = Offset(width * 0.50, height * 0.54);

                            return WorldCamera(
                              zoom: currentZoom,
                              cameraFocus: targetFocus,
                              screenSize: screenSize,
                              worldSize: screenSize,
                              backgroundLayer: WorldEnvironment.buildSky(width, height),
                              distantHillsLayer: WorldEnvironment.buildDistantHills(width, height),
                              midgroundLayer: WorldEnvironment.buildMidgroundHills(width, height, memoryCount),
                              walkingLayer: Stack(
                                children: [
                                  // Rich Meadow & Wide Countryside Winding Road
                                  WorldEnvironment.buildWalkingMeadow(width, height, memoryCount),

                                  // Deterministic Physical Memory Objects
                                  ..._buildMeadowMemoryObjects(context, memories, width, height),

                                  // The Couple Characters
                                  Positioned(
                                    left: _couplePosition!.dx - 28,
                                    top: _couplePosition!.dy - 38,
                                    child: CoupleCharacterPairWidget(
                                      userCharacter: userCharacter,
                                      companionCharacter: companionCharacter,
                                      isHoldingHands: _isHoldingHands,
                                      isWalking: false,
                                      facingRight: true,
                                      isLookingAtMemory: false,
                                      isPlatonic: widget.world.relationshipType == 'best_friend',
                                      isRaining: _environmentConfig.condition == WorldCondition.rain,
                                      isSnowing: _environmentConfig.condition == WorldCondition.snow,
                                      onHandHoldingToggled: () {
                                        setState(() {
                                          _isHoldingHands = !_isHoldingHands;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              foregroundLayer: WorldEnvironment.buildForegroundAtmosphere(
                                width,
                                height,
                                _ambientController.value,
                                memoryCount,
                              ),
                            );
                          },
                        ),

                        // Layer: Empty State Banner (if 0 memories and in normal mode)
                        if (memoryCount == 0 &&
                            (_transitionCompleted || !widget.showEntryTransition))
                          _buildEmptyStateBanner(context),

                        // Layer: NORMAL WORLD HUD (Top Header + Navigation)
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: WorldHeader(
                              world: widget.world,
                              memoryCount: memoryCount,
                              onBack: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const YourWorldsScreen(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return FadeTransition(
                                            opacity: animation, child: child);
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 350),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        // Bottom Controls (Take Memory Walk Button + Nav Bar + Add Button)
                        SafeArea(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                                bottom: 12.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // "Take a Memory Walk ♡" Primary Action
                                  _buildTakeMemoryWalkButton(),
                                  const SizedBox(height: 12),

                                  // Standard Bottom Row (Nav + Add Button)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      WorldNavBar(
                                        activeTab: _activeTab,
                                        onTabSelected: _handleTabSelected,
                                      ),
                                      WorldAddButton(
                                        world: widget.world,
                                        onMemoryAdded: () {
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Layer: Optional Entry Transition Overlay
                        if (!_transitionCompleted && widget.showEntryTransition)
                          _buildEntryTransitionOverlay(),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  /// Primary button to initiate the immersive Memory Walk
  Widget _buildTakeMemoryWalkButton() {
    return TactilePillButton(
      onPressed: _enterMemoryWalk,
      height: 48,
      backgroundColor: AppTheme.creamLight.withValues(alpha: 0.95),
      foregroundColor: AppTheme.textPrimary,
      isSecondary: true,
      leading: const Icon(
        Icons.directions_walk_rounded,
        color: AppTheme.primaryPink,
        size: 20,
      ),
      trailing: const Text(
        '♡',
        style: TextStyle(
          color: AppTheme.primaryPink,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      text: 'Take a Memory Walk',
    );
  }

  /// Builds physical memory objects placed deterministically in the world meadow
  List<Widget> _buildMeadowMemoryObjects(
    BuildContext context,
    List<Memory> memories,
    double width,
    double height,
  ) {
    const List<Offset> deterministicSlots = [
      Offset(0.20, 0.60), // Slot 0
      Offset(0.78, 0.62), // Slot 1
      Offset(0.32, 0.74), // Slot 2
      Offset(0.74, 0.76), // Slot 3
      Offset(0.14, 0.72), // Slot 4
      Offset(0.52, 0.81), // Slot 5
      Offset(0.18, 0.50), // Slot 6
      Offset(0.82, 0.51), // Slot 7
    ];

    return [
      for (int i = 0; i < memories.length; i++) ...[
        () {
          final memory = memories[i];
          final slot = deterministicSlots[i % deterministicSlots.length];
          final posX = slot.dx * width;
          final posY = slot.dy * height;
          final isHighlighted = false;

          return Positioned(
            left: posX - 45,
            top: posY - 45,
            child: MemoryObject(
              memory: memory,
              animationPhase: (i * 0.28) % 1.0,
              isHighlighted: isHighlighted,
              onTap: () {
                MemoryDetailSheet.show(context, memory);
              },
            ),
          );
        }(),
      ],
    ];
  }

  /// Storybook Empty State Banner when world has 0 memories
  Widget _buildEmptyStateBanner(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 140, left: 32, right: 32),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: AppTheme.creamLight.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.borderSubtle,
            width: 1.5,
          ),
          boxShadow: AppTheme.paperShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.sageGreenLight,
                shape: BoxShape.circle,
              ),
              child: const StorybookSprout(size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              'Every little world starts somewhere.',
              style: GoogleFonts.mali(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Add the first moment to watch your world bloom.',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            TactilePillButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FirstMemoryScreen(world: widget.world),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 350),
                  ),
                );
                setState(() {});
              },
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              text: 'Add the first moment ♡',
            ),
          ],
        ),
      ),
    );
  }

  /// Magical Storybook Entry Reveal Transition
  Widget _buildEntryTransitionOverlay() {
    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        return Container(
          color: AppTheme.backgroundColor.withValues(
            alpha: (1.0 - _worldFade.value).clamp(0.0, 1.0),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _sparkScale,
                  child: FadeTransition(
                    opacity: _sparkFade,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF90C2A3).withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.eco_rounded,
                          color: Color(0xFF5B8A6E),
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _welcomeTextFade,
                  child: Column(
                    children: [
                      Text(
                        widget.world.name,
                        style: GoogleFonts.mali(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome to your world. ♡',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryPink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
