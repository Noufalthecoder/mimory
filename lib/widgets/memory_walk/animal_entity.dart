import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mimory/models/world_point.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/widgets/memory_walk/animal_speech_bubble.dart';

enum AnimalType {
  rabbit,
  squirrel,
  bird,
  butterfly,
}

/// A living storybook creature roaming the miniature world.
class AnimalEntity {
  final String id;
  final AnimalType type;
  WorldPos worldPos;
  String? speechText;
  bool isNearby;
  bool isFed;

  AnimalEntity({
    required this.id,
    required this.type,
    required this.worldPos,
    this.speechText,
    this.isNearby = false,
    this.isFed = false,
  });
}

/// Renders a cute animated animal with perspective scaling and speech bubbles.
class AnimalWidget extends StatefulWidget {
  final AnimalEntity animal;
  final double scale;
  final bool isRaining;
  final bool isSnowing;
  final VoidCallback? onTap;

  const AnimalWidget({
    super.key,
    required this.animal,
    this.scale = 1.0,
    this.isRaining = false,
    this.isSnowing = false,
    this.onTap,
  });

  @override
  State<AnimalWidget> createState() => _AnimalWidgetState();
}

class _AnimalWidgetState extends State<AnimalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleAnimController;

  @override
  void initState() {
    super.initState();
    _idleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveScale = widget.scale.clamp(0.40, 2.0);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _idleAnimController,
        builder: (context, _) {
          final t = _idleAnimController.value;

          return Transform.scale(
            scale: effectiveScale,
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                // Speech Cloud Bubble if speaking
                if (widget.animal.speechText != null)
                  Positioned(
                    bottom: 34,
                    child: AnimalSpeechBubbleWidget(
                      text: widget.animal.speechText!,
                    ),
                  ),

                // Tiny hearts when fed
                if (widget.animal.isFed)
                  Positioned(
                    top: -14,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: Offset(0, -t * 6),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 10,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Transform.translate(
                          offset: Offset(0, -(1 - t) * 6),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 8,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Tiny snowy footprints behind rabbit
                if (widget.isSnowing && widget.animal.type == AnimalType.rabbit)
                  Positioned(
                    bottom: -2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC0D8E8).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 4,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC0D8E8).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Ground shadow
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E4624).withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Specific Animal Body
                _buildAnimalBody(t),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimalBody(double t) {
    switch (widget.animal.type) {
      case AnimalType.rabbit:
        // Cute hopping bunny with long white ears & pink inners
        final hopY = -math.sin(t * math.pi) * (widget.isRaining ? 1.5 : 3.5);
        // Playful ear shake when it is snowing
        final earShake = widget.isSnowing ? math.sin(t * math.pi * 6) * 0.18 : 0.0;
        return Transform.translate(
          offset: Offset(0, hopY),
          child: SizedBox(
            width: 24,
            height: 28,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Fluffy tail
                Positioned(
                  bottom: 4,
                  left: 1,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Body
                Positioned(
                  bottom: 2,
                  child: Container(
                    width: 15,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // Head
                Positioned(
                  top: 7,
                  right: 3,
                  child: Container(
                    width: 12,
                    height: 11,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Ears with occasional snow-shake rotation
                Positioned(
                  top: 0,
                  right: 4,
                  child: Transform.rotate(
                    angle: earShake,
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Left Ear
                        Container(
                          width: 3,
                          height: 9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Container(
                              width: 1.5,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC0CB),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 1),
                        // Right Ear
                        Container(
                          width: 3,
                          height: 9,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Container(
                              width: 1.5,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC0CB),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Eye dot
                Positioned(
                  top: 11,
                  right: 5,
                  child: Container(
                    width: 1.8,
                    height: 1.8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A2E2C),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case AnimalType.squirrel:
        // Chibi squirrel with bushy tail
        return SizedBox(
          width: 26,
          height: 26,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Bushy arched tail
              Positioned(
                bottom: 6,
                left: 2,
                child: Transform.rotate(
                  angle: -0.3 + t * 0.15,
                  child: Container(
                    width: 10,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC07038),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Body
              Positioned(
                bottom: 2,
                right: 5,
                child: Container(
                  width: 13,
                  height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD98246),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              // Head
              Positioned(
                top: 5,
                right: 3,
                child: Container(
                  width: 11,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD98246),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Eye
              Positioned(
                top: 8,
                right: 5,
                child: Container(
                  width: 1.6,
                  height: 1.6,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );

      case AnimalType.bird:
        // Cute songbird perched or fluttering
        final flutterY = -math.sin(t * math.pi) * 2;
        return Transform.translate(
          offset: Offset(0, flutterY),
          child: SizedBox(
            width: 18,
            height: 18,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 12,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7CB9E8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7CB9E8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Tiny yellow beak
                Positioned(
                  top: 5,
                  right: 0,
                  child: Container(
                    width: 3,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA500),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case AnimalType.butterfly:
        // Fluttering pastel butterfly
        final wingScale = 0.5 + 0.5 * math.sin(t * math.pi * 3).abs();
        return SizedBox(
          width: 16,
          height: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scaleX: wingScale,
                child: Container(
                  width: 6,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB7B2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Container(width: 1.5, height: 8, color: const Color(0xFF5A3E2B)),
              Transform.scale(
                scaleX: wingScale,
                child: Container(
                  width: 6,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB7B2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
