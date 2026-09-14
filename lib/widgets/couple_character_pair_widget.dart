import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/widgets/anime_character_widget.dart';

/// Renders the two characters as a unified couple.
/// Supports holding hands (animated sliding together, connected hands clasp, heart pop)
/// and synchronized walking movement.
class CoupleCharacterPairWidget extends StatefulWidget {
  final Character userCharacter;
  final Character companionCharacter;
  final bool isHoldingHands;
  final bool isWalking;
  final bool facingRight;
  final bool isLookingAtMemory;
  final bool isPlatonic;
  final bool isRaining;
  final bool isSnowing;
  final VoidCallback? onHandHoldingToggled;

  const CoupleCharacterPairWidget({
    super.key,
    required this.userCharacter,
    required this.companionCharacter,
    required this.isHoldingHands,
    required this.isWalking,
    required this.facingRight,
    this.isLookingAtMemory = false,
    this.isPlatonic = false,
    this.isRaining = false,
    this.isSnowing = false,
    this.onHandHoldingToggled,
  });

  @override
  State<CoupleCharacterPairWidget> createState() =>
      _CoupleCharacterPairWidgetState();
}

class _CoupleCharacterPairWidgetState extends State<CoupleCharacterPairWidget>
    with TickerProviderStateMixin {
  late AnimationController _stepController;
  late AnimationController _heartPopController;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _heartFadeAnimation;

  @override
  void initState() {
    super.initState();
    // Walking cadence controller
    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat();

    // Heart pop controller when hands connect
    _heartPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _heartScaleAnimation = Tween<double>(begin: 0.2, end: 1.3).animate(
      CurvedAnimation(
        parent: _heartPopController,
        curve: Curves.easeOutBack,
      ),
    );

    _heartFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _heartPopController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.isHoldingHands) {
      _heartPopController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CoupleCharacterPairWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isHoldingHands && widget.isHoldingHands) {
      // Trigger heart pop when hands connect!
      _heartPopController.reset();
      _heartPopController.forward();
    }
  }

  @override
  void dispose() {
    _stepController.dispose();
    _heartPopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // When holding hands: characters stand ~13px apart; when separate: ~26px apart
    final spacing = widget.isHoldingHands ? 13.0 : 26.0;

    return AnimatedBuilder(
      animation: _stepController,
      builder: (context, child) {
        final t = _stepController.value;
        // Walking bob: cute vertical hop synchronized for the pair
        final bobY = widget.isWalking
            ? math.sin(t * math.pi * 2).abs() * -3.2
            : math.sin(t * math.pi) * -0.9;

        return Transform.translate(
          offset: Offset(0, bobY),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Sparkle Heart Pop when hands connect
          if (widget.isHoldingHands)
            Positioned(
              top: -18,
              child: AnimatedBuilder(
                animation: _heartPopController,
                builder: (context, _) {
                  return Opacity(
                    opacity: _heartFadeAnimation.value,
                    child: Transform.scale(
                      scale: _heartScaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (widget.isPlatonic
                                      ? AppTheme.sageGreen
                                      : AppTheme.primaryPink)
                                  .withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isPlatonic
                              ? Icons.auto_awesome_rounded
                              : Icons.favorite_rounded,
                          color: widget.isPlatonic
                              ? AppTheme.sageGreen
                              : AppTheme.primaryPink,
                          size: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // The Two Characters side-by-side
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Character 1 (Current User)
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimeCharacterWidget(
                    character: widget.userCharacter,
                    isWalking: widget.isWalking,
                    facingRight: widget.facingRight,
                    isLookingAtMemory: widget.isLookingAtMemory,
                  ),
                  if (widget.isSnowing)
                    const Positioned(
                      top: 14,
                      child: _WinterScarf(color: Color(0xFFD3524B)),
                    ),
                  if (widget.isSnowing)
                    const Positioned(
                      top: -6,
                      child: _WinterBeanie(color: Color(0xFFD3524B)),
                    ),
                ],
              ),

              // Spacing / Hand Connection
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: spacing,
                child: widget.isHoldingHands
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          width: 8,
                          height: 5,
                          decoration: BoxDecoration(
                            color: widget.userCharacter.skinTone,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Character 2 (Companion)
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  AnimeCharacterWidget(
                    character: widget.companionCharacter,
                    isWalking: widget.isWalking,
                    facingRight: widget.facingRight,
                    isLookingAtMemory: widget.isLookingAtMemory,
                  ),
                  if (widget.isSnowing)
                    const Positioned(
                      top: 14,
                      child: _WinterScarf(color: Color(0xFF4A7C59)),
                    ),
                  if (widget.isSnowing)
                    const Positioned(
                      top: -6,
                      child: _WinterBeanie(color: Color(0xFF4A7C59)),
                    ),
                ],
              ),
            ],
          ),

          // Shared Storybook Umbrella (Active in Rain)
          // Renders above both characters, resting shelter over both together!
          if (widget.isRaining)
            Positioned(
              top: -38,
              child: _SharedStorybookUmbrella(
                facingRight: widget.facingRight,
              ),
            ),
        ],
      ),
    );
  }
}

/// A cozy storybook umbrella sheltering both walking characters.
class _SharedStorybookUmbrella extends StatelessWidget {
  final bool facingRight;

  const _SharedStorybookUmbrella({
    required this.facingRight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 48,
      child: CustomPaint(
        painter: _UmbrellaPainter(facingRight: facingRight),
      ),
    );
  }
}

class _UmbrellaPainter extends CustomPainter {
  final bool facingRight;

  _UmbrellaPainter({required this.facingRight});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width * 0.50;
    final topY = 6.0;
    final canopyBottomY = 24.0;
    final canopyWidth = size.width - 6.0;

    // 1. Slender wooden shaft
    final shaftPaint = Paint()
      ..color = const Color(0xFF6B4226)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final shaftX = facingRight ? centerX - 6 : centerX + 6;
    canvas.drawLine(Offset(shaftX, topY), Offset(shaftX, size.height - 2), shaftPaint);

    // Curved J-handle at the bottom
    final handlePaint = Paint()
      ..color = const Color(0xFF5A351E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final handleRect = Rect.fromCircle(
      center: Offset(shaftX + (facingRight ? -4 : 4), size.height - 4),
      radius: 4.5,
    );
    canvas.drawArc(
      handleRect,
      facingRight ? 0 : math.pi,
      math.pi,
      false,
      handlePaint,
    );

    // 2. Umbrella Canopy Path (Soft Coral/Peach with warm storybook warmth)
    final canopyPath = Path();
    canopyPath.moveTo(centerX - canopyWidth / 2, canopyBottomY);
    // Smooth dome top
    canopyPath.quadraticBezierTo(
      centerX,
      topY - 8,
      centerX + canopyWidth / 2,
      canopyBottomY,
    );
    // Scalloped bottom rim
    final scallopStep = canopyWidth / 3.0;
    for (int i = 0; i < 3; i++) {
      final start = (centerX + canopyWidth / 2) - (i * scallopStep);
      final end = start - scallopStep;
      canopyPath.quadraticBezierTo(
        (start + end) / 2,
        canopyBottomY - 2.5,
        end,
        canopyBottomY,
      );
    }
    canopyPath.close();

    final canopyPaint = Paint()
      ..color = const Color(0xFFF18F89)
      ..style = PaintingStyle.fill;
    canvas.drawPath(canopyPath, canopyPaint);

    // Canopy ribs highlight
    final ribPaint = Paint()
      ..color = const Color(0xFFFFF2EE).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(centerX, topY), Offset(centerX, canopyBottomY), ribPaint);
    canvas.drawLine(
      Offset(centerX, topY),
      Offset(centerX - canopyWidth * 0.32, canopyBottomY - 1),
      ribPaint,
    );
    canvas.drawLine(
      Offset(centerX, topY),
      Offset(centerX + canopyWidth * 0.32, canopyBottomY - 1),
      ribPaint,
    );

    // Tiny umbrella finial cap on very top
    final tipPaint = Paint()..color = const Color(0xFFD4706A);
    canvas.drawCircle(Offset(centerX, topY - 3), 2.2, tipPaint);
  }

  @override
  bool shouldRepaint(covariant _UmbrellaPainter oldDelegate) =>
      oldDelegate.facingRight != facingRight;
}

/// Subtle storybook winter scarf with trailing tassels.
class _WinterScarf extends StatelessWidget {
  final Color color;

  const _WinterScarf({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.only(right: 2, top: 4),
          width: 5,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

/// Cute winter beanie hat with small pom-pom.
class _WinterBeanie extends StatelessWidget {
  final Color color;

  const _WinterBeanie({required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        // Fluffy pom-pom
        Positioned(
          top: -3.5,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Beanie cap dome
        Container(
          width: 20,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(2),
              bottomRight: Radius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
