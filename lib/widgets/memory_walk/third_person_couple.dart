import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/core/theme/app_theme.dart';

/// Renders the couple viewed naturally from behind in the third-person camera perspective.
/// Supports:
/// - True hand-holding clasp with connected hands and arms
/// - Synchronized walking animation with alternating foot steps and cute bobbing
/// - Smooth turning and tilting
/// - Heart pop celebration when hands connect
class ThirdPersonCoupleWidget extends StatefulWidget {
  final Character userCharacter;
  final Character companionCharacter;
  final bool isHoldingHands;
  final bool isWalking;
  final double facingAngle; // in radians (0 = straight ahead, -pi/2 = left, +pi/2 = right)
  final double scale; // perspective scale from Camera3D
  final VoidCallback? onHandHoldingToggled;

  const ThirdPersonCoupleWidget({
    super.key,
    required this.userCharacter,
    required this.companionCharacter,
    required this.isHoldingHands,
    required this.isWalking,
    this.facingAngle = 0.0,
    this.scale = 1.0,
    this.onHandHoldingToggled,
  });

  @override
  State<ThirdPersonCoupleWidget> createState() => _ThirdPersonCoupleWidgetState();
}

class _ThirdPersonCoupleWidgetState extends State<ThirdPersonCoupleWidget>
    with TickerProviderStateMixin {
  late AnimationController _walkCycleController;
  late AnimationController _heartPopController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartFadeAnimation;

  @override
  void initState() {
    super.initState();
    // Synchronized walk cycle (footsteps, bobbing)
    _walkCycleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    // Heart pop controller when hands connect
    _heartPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _heartScaleAnimation = Tween<double>(begin: 0.1, end: 1.35).animate(
      CurvedAnimation(
        parent: _heartPopController,
        curve: Curves.easeOutBack,
      ),
    );

    _heartFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _heartPopController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.isHoldingHands) {
      _heartPopController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ThirdPersonCoupleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isHoldingHands && widget.isHoldingHands) {
      _heartPopController.reset();
      _heartPopController.forward();
    }
  }

  @override
  void dispose() {
    _walkCycleController.dispose();
    _heartPopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clamping scale between reasonable min/max to maintain crisp storybook readability
    final effectiveScale = widget.scale.clamp(0.45, 2.5);

    return AnimatedBuilder(
      animation: _walkCycleController,
      builder: (context, _) {
        final t = _walkCycleController.value;
        // Natural walking bob: two steps per cycle
        final bobY = widget.isWalking
            ? -math.sin(t * math.pi * 2).abs() * 3.5
            : -math.sin(t * math.pi) * 0.8;

        // Subtle side-to-side sway when walking
        final swayAngle = widget.isWalking
            ? math.sin(t * math.pi * 2) * 0.04
            : 0.0;

        // Character turn angle based on movement direction
        final turnTilt = math.sin(widget.facingAngle) * 0.08;

        return Transform.translate(
          offset: Offset(0, bobY * effectiveScale),
          child: Transform.rotate(
            angle: swayAngle + turnTilt,
            alignment: Alignment.bottomCenter,
            child: Transform.scale(
              scale: effectiveScale,
              alignment: Alignment.bottomCenter,
              child: _buildCoupleBody(t),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoupleBody(double walkT) {
    // When holding hands: characters stand ~10px apart; when separate: ~28px apart
    final spacing = widget.isHoldingHands ? 8.0 : 26.0;

    // Alternating leg swing offsets
    final leftLegOffset = widget.isWalking ? math.sin(walkT * math.pi * 2) * 3.2 : 0.0;
    final rightLegOffset = widget.isWalking ? -math.sin(walkT * math.pi * 2) * 3.2 : 0.0;

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // 1. Shared Soft Ground Shadow
        Positioned(
          bottom: -2,
          child: Container(
            width: widget.isHoldingHands ? 46 : 58,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF334A29).withValues(alpha: 0.32),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),

        // 2. Heart Pop Celebration when hands connect
        if (widget.isHoldingHands)
          Positioned(
            top: -24,
            child: AnimatedBuilder(
              animation: _heartPopController,
              builder: (context, _) {
                if (_heartFadeAnimation.value <= 0.0) return const SizedBox.shrink();
                return Opacity(
                  opacity: _heartFadeAnimation.value,
                  child: Transform.scale(
                    scale: _heartScaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPink.withValues(alpha: 0.55),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppTheme.primaryPink,
                        size: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // 3. The Two Characters standing together
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Character 1 (User) viewed from behind
            _buildBackCharacter(
              char: widget.userCharacter,
              isLeft: true,
              legOffset1: leftLegOffset,
              legOffset2: rightLegOffset,
              isHoldingHands: widget.isHoldingHands,
            ),

            // Connected Hand Space
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              width: spacing,
              height: 24,
              alignment: Alignment.center,
              child: widget.isHoldingHands
                  ? _buildConnectedHandClasp()
                  : const SizedBox.shrink(),
            ),

            // Character 2 (Companion) viewed from behind
            _buildBackCharacter(
              char: widget.companionCharacter,
              isLeft: false,
              legOffset1: rightLegOffset,
              legOffset2: leftLegOffset,
              isHoldingHands: widget.isHoldingHands,
            ),
          ],
        ),
      ],
    );
  }

  /// Visually connected interlocking hands & arms
  Widget _buildConnectedHandClasp() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 14,
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left partner arm extending right
          Positioned(
            left: 0,
            child: Container(
              width: 7,
              height: 4,
              decoration: BoxDecoration(
                color: widget.userCharacter.skinTone,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Right partner arm extending left
          Positioned(
            right: 0,
            child: Container(
              width: 7,
              height: 4,
              decoration: BoxDecoration(
                color: widget.companionCharacter.skinTone,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Interlocked hands clasp
          Container(
            width: 8,
            height: 7,
            decoration: BoxDecoration(
              color: widget.userCharacter.skinTone,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF5A3E2B).withValues(alpha: 0.25),
                width: 0.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Single anime character viewed naturally from behind
  Widget _buildBackCharacter({
    required Character char,
    required bool isLeft,
    required double legOffset1,
    required double legOffset2,
    required bool isHoldingHands,
  }) {
    return SizedBox(
      width: 28,
      height: 44,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Feet / Shoes walking
          Positioned(
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(0, legOffset1),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF382E2B),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Transform.translate(
                  offset: Offset(0, legOffset2),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF382E2B),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lower outfit / pants
          Positioned(
            bottom: 4,
            child: Container(
              width: 13,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4E54),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Cozy Sweater Back
          Positioned(
            bottom: 10,
            child: Container(
              width: 17,
              height: 15,
              decoration: BoxDecoration(
                color: char.outfitColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                // Subtle sweater center seam line
                child: Container(
                  width: 1,
                  height: 10,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),

          // Outer arm relaxed at side
          Positioned(
            bottom: 11,
            left: isLeft ? 1 : null,
            right: !isLeft ? 1 : null,
            child: Container(
              width: 4,
              height: 10,
              decoration: BoxDecoration(
                color: char.outfitColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Inner arm (holding hand or relaxed)
          if (!isHoldingHands)
            Positioned(
              bottom: 11,
              left: !isLeft ? 1 : null,
              right: isLeft ? 1 : null,
              child: Container(
                width: 4,
                height: 10,
                decoration: BoxDecoration(
                  color: char.outfitColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

          // Chibi Head & Back of Hair
          Positioned(
            top: 2,
            child: _buildBackOfHead(char),
          ),
        ],
      ),
    );
  }

  /// Detailed back of hair matching the character's hairstyle and color
  Widget _buildBackOfHead(Character char) {
    switch (char.hairStyle) {
      case 'twin_tails':
        return SizedBox(
          width: 28,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Main head base
              Container(
                width: 19,
                height: 18,
                decoration: BoxDecoration(
                  color: char.hairColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              // Left Pigtail
              Positioned(
                left: -2,
                top: 4,
                child: Container(
                  width: 6,
                  height: 15,
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Right Pigtail
              Positioned(
                right: -2,
                top: 4,
                child: Container(
                  width: 6,
                  height: 15,
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Cute pink ribbons
              Positioned(
                left: 1,
                top: 3,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 1,
                top: 3,
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );

      case 'wavy_long':
        return SizedBox(
          width: 24,
          height: 26,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Main head
              Container(
                width: 19,
                height: 18,
                decoration: BoxDecoration(
                  color: char.hairColor,
                  shape: BoxShape.circle,
                ),
              ),
              // Long cascading wavy hair
              Positioned(
                top: 8,
                child: Container(
                  width: 22,
                  height: 17,
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

      case 'side_part':
      case 'short_fringe':
      default:
        return Container(
          width: 19,
          height: 18,
          decoration: BoxDecoration(
            color: char.hairColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        );
    }
  }
}
