import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/core/theme/app_theme.dart';

/// Renders a tiny, persistent, illustrated anime/storybook character inhabiting the Living World.
/// Designed with cute chibi proportions (~38px tall), expressive features, blushing cheeks,
/// dynamic direction flipping, walking step bobbing, and idle breathing.
class AnimeCharacterWidget extends StatefulWidget {
  final Character character;
  final bool isWalking;
  final bool facingRight;
  final bool isLookingAtMemory;
  final VoidCallback? onTap;

  const AnimeCharacterWidget({
    super.key,
    required this.character,
    this.isWalking = false,
    this.facingRight = true,
    this.isLookingAtMemory = false,
    this.onTap,
  });

  @override
  State<AnimeCharacterWidget> createState() => _AnimeCharacterWidgetState();
}

class _AnimeCharacterWidgetState extends State<AnimeCharacterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _showCard = false;

  @override
  void initState() {
    super.initState();
    // Looping animation controller for walking cadence or idle breathing
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _showCard = true;
    });

    // Auto-dismiss the floating name tag card after 2.8 seconds
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        setState(() {
          _showCard = false;
        });
      }
    });

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Floating Info Bubble when tapped
          if (_showCard)
            Positioned(
              bottom: 44,
              child: _buildNameTagCard(),
            ),

          // Tiny Anime Character with Direction Flip & Walking Bob
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final t = _animController.value;
              // Vertical bobbing: walking bobs faster and higher, idle breathes gently
              final bobY = widget.isWalking
                  ? math.sin(t * math.pi * 2).abs() * -2.8
                  : math.sin(t * math.pi) * -0.8;

              // Head tilt when looking at a memory
              final tiltAngle = widget.isLookingAtMemory
                  ? (widget.facingRight ? 0.12 : -0.12)
                  : 0.0;

              return Transform.translate(
                offset: Offset(0, bobY),
                child: Transform.scale(
                  scaleX: widget.facingRight ? 1.0 : -1.0,
                  alignment: Alignment.bottomCenter,
                  child: Transform.rotate(
                    angle: tiltAngle,
                    alignment: Alignment.bottomCenter,
                    child: child,
                  ),
                ),
              );
            },
            child: _buildCharacterIllustration(context),
          ),
        ],
      ),
    );
  }

  /// Small elegant storybook card displaying the character's exploration status
  Widget _buildNameTagCard() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.character.outfitColor.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A3E2B).withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.character.personName,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Exploring our world ♡',
              style: GoogleFonts.nunito(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryPink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Illustrated tiny anime character with chibi proportions
  Widget _buildCharacterIllustration(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 40,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Soft Oval Ground Shadow
          Positioned(
            bottom: 0,
            child: Container(
              width: 22,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFF4A3423).withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // 2. Tiny Feet/Shoes
          Positioned(
            bottom: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A3E39),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 5,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A3E39),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          // 3. Tiny Body / Cozy Sweater Outfit
          Positioned(
            bottom: 5,
            child: Container(
              width: 14,
              height: 13,
              decoration: BoxDecoration(
                color: widget.character.outfitColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // 4. Little Hands
          Positioned(
            bottom: 8,
            left: 7,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: widget.character.skinTone,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 7,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: widget.character.skinTone,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 5. Chibi Head & Facial Features
          Positioned(
            top: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Head base
                Container(
                  width: 22,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.character.skinTone,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5A3E2B).withValues(alpha: 0.12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // Blushing Cheeks
                Positioned(
                  bottom: 5,
                  left: 3,
                  child: Container(
                    width: 4,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9E9E).withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 3,
                  child: Container(
                    width: 4,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9E9E).withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Cute Anime Eyes (peaceful dot/arc)
                Positioned(
                  bottom: 8,
                  left: 6,
                  child: Container(
                    width: 2.2,
                    height: 2.8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2523),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 6,
                  child: Container(
                    width: 2.2,
                    height: 2.8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2523),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),

                // Tiny Smile
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 3,
                    height: 1.5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7A4E3A),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(2),
                        bottomRight: Radius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Hair Overlay
                _buildHair(widget.character),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Stylized anime hair based on character configuration
  Widget _buildHair(Character char) {
    switch (char.hairStyle) {
      case 'twin_tails':
        return SizedBox(
          width: 26,
          height: 24,
          child: Stack(
            children: [
              // Top fringe
              Positioned(
                top: 0,
                left: 2,
                right: 2,
                height: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              // Left Pigtail
              Positioned(
                top: 6,
                left: 0,
                width: 6,
                height: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Right Pigtail
              Positioned(
                top: 6,
                right: 0,
                width: 6,
                height: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Little pink ribbon
              Positioned(
                top: 5,
                left: 3,
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

      case 'side_part':
        return SizedBox(
          width: 24,
          height: 22,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 1,
                right: 1,
                height: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(2),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 1,
                width: 4,
                height: 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'wavy_bob':
        return SizedBox(
          width: 26,
          height: 22,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 1,
                right: 1,
                height: 11,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned(
                top: 7,
                left: 0,
                width: 5,
                height: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                top: 7,
                right: 0,
                width: 5,
                height: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'high_ponytail':
        return SizedBox(
          width: 26,
          height: 24,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 2,
                right: 2,
                height: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Side ponytail tail
              Positioned(
                top: 2,
                right: 0,
                width: 7,
                height: 14,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Tiny ribbon
              Positioned(
                top: 3,
                right: 5,
                child: Container(
                  width: 3.5,
                  height: 3.5,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryPink,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );

      case 'messy_fringe':
        return SizedBox(
          width: 24,
          height: 22,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 1,
                right: 1,
                height: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 4,
                width: 5,
                height: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 4,
                width: 5,
                height: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'short_fringe':
      default:
        return SizedBox(
          width: 24,
          height: 22,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 2,
                right: 2,
                height: 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),
              ),
              // Fringe spike
              Positioned(
                top: 5,
                left: 8,
                width: 4,
                height: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: char.hairColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
