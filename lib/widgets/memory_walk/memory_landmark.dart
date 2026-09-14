import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/core/theme/app_theme.dart';

import 'package:mimory/models/world_environment_config.dart';

/// Environmental Memory Landmark in the 3D world.
/// Replaces floating generic cards with integrated physical landmarks:
/// - Photo memories: Wooden photo pergola archway with ivy, fairy lights & framed picture
/// - Story memories: Cozy storybook wooden park bench with open journal & wildflower garden
/// When approached, gently glows with pulsing aura and floating hearts.
class MemoryLandmarkWidget extends StatefulWidget {
  final Memory memory;
  final bool isNearby;
  final double scale;
  final WorldCondition condition;
  final TimeOfDayState timeOfDay;
  final VoidCallback onTap;

  const MemoryLandmarkWidget({
    super.key,
    required this.memory,
    required this.isNearby,
    this.scale = 1.0,
    this.condition = WorldCondition.sunny,
    this.timeOfDay = TimeOfDayState.day,
    required this.onTap,
  });

  @override
  State<MemoryLandmarkWidget> createState() => _MemoryLandmarkWidgetState();
}

class _MemoryLandmarkWidgetState extends State<MemoryLandmarkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveScale = widget.scale.clamp(0.42, 2.2);
    final isPhoto = widget.memory.type == MemoryType.photo;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          final pulse = _pulseController.value;
          final auraOpacity = widget.isNearby ? (0.35 + pulse * 0.3) : 0.0;
          final floatY = widget.isNearby ? -math.sin(pulse * math.pi) * 3 : 0.0;

          return Transform.scale(
            scale: effectiveScale,
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, floatY),
              child: SizedBox(
                width: 90,
                height: 96,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Proximity Glowing Aura
                    if (widget.isNearby)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.primaryPink.withValues(alpha: auraOpacity),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                    // 2. Ground Shadow
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 58,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E4624).withValues(alpha: 0.32),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // 3. The Physical Landmark Structure
                    Positioned(
                      bottom: 4,
                      child: isPhoto
                          ? _buildPhotoPergola()
                          : _buildStorybookBench(),
                    ),

                    // 4. Proximity Heart Sparkle
                    if (widget.isNearby)
                      Positioned(
                        top: -12,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryPink.withValues(alpha: 0.6),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryPink.withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.favorite_rounded,
                                    color: AppTheme.primaryPink,
                                    size: 10,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.memory.title,
                                    style: GoogleFonts.mali(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
          );
        },
      ),
    );
  }

  /// Wooden photo pergola archway with hanging picture and fairy lights
  Widget _buildPhotoPergola() {
    return SizedBox(
      width: 72,
      height: 78,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Wooden archway pillars
          Positioned(
            left: 8,
            bottom: 0,
            width: 6,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8B5A2B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 0,
            width: 6,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8B5A2B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Arch top beam
          Positioned(
            top: 14,
            left: 2,
            right: 2,
            height: 7,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF9E6838),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          // Snow Cap on Pergola Beam in Winter/Snow
          if (widget.condition == WorldCondition.snow)
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              height: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB0C8D8).withValues(alpha: 0.4),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          // Vines on top beam with warm fairy lights at Night
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF7FA86D),
                shape: BoxShape.circle,
                boxShadow: (widget.timeOfDay == TimeOfDayState.night ||
                        widget.timeOfDay == TimeOfDayState.sunset)
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFE57F).withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
          Positioned(
            top: 9,
            right: 14,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: const Color(0xFF6B9B58),
                shape: BoxShape.circle,
                boxShadow: (widget.timeOfDay == TimeOfDayState.night ||
                        widget.timeOfDay == TimeOfDayState.sunset)
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFE57F).withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),

          // Hanging Framed Photo (Glows warmly in Night mode)
          Positioned(
            top: 24,
            child: Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFFDCCFBE),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.timeOfDay == TimeOfDayState.night)
                        ? const Color(0xFFFFD54F).withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.16),
                    blurRadius: (widget.timeOfDay == TimeOfDayState.night) ? 8 : 5,
                    spreadRadius: (widget.timeOfDay == TimeOfDayState.night) ? 2 : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: widget.memory.imagePath != null &&
                        File(widget.memory.imagePath!).existsSync()
                    ? Image.file(
                        File(widget.memory.imagePath!),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppTheme.primaryPink.withValues(alpha: 0.15),
                        child: const Center(
                          child: Icon(
                            Icons.photo_camera_rounded,
                            size: 18,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Storybook park bench holding open journal & flowers
  Widget _buildStorybookBench() {
    return SizedBox(
      width: 68,
      height: 48,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Wooden Bench Backrest
          Positioned(
            bottom: 14,
            width: 58,
            height: 24,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF9E6838),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF7A4E27),
                  width: 1.2,
                ),
              ),
            ),
          ),
          // Snow Cap on Bench Backrest in Snow mode
          if (widget.condition == WorldCondition.snow)
            Positioned(
              bottom: 35,
              width: 60,
              height: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB0C8D8).withValues(alpha: 0.35),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          // Wooden Bench Seat
          Positioned(
            bottom: 10,
            width: 62,
            height: 9,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFB87D47),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          // Legs
          Positioned(
            bottom: 0,
            left: 8,
            width: 4,
            height: 12,
            child: Container(color: const Color(0xFF5A3818)),
          ),
          Positioned(
            bottom: 0,
            right: 8,
            width: 4,
            height: 12,
            child: Container(color: const Color(0xFF5A3818)),
          ),

          // Open Journal resting on bench
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9EE),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: const Color(0xFFC7BAA5),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 14,
                    color: Color(0xFF7A4E27),
                  ),
                ],
              ),
            ),
          ),

          // Wildflowers beside bench
          Positioned(
            bottom: 2,
            right: 0,
            child: const Icon(
              Icons.local_florist_rounded,
              size: 14,
              color: AppTheme.primaryPink,
            ),
          ),
        ],
      ),
    );
  }
}
