import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';

/// A physical, illustrated World Object representing a memory inside the Living World.
/// Photos appear as framed pictures on illustrated mini easels / stands.
/// Stories appear as illustrated storybooks / journals resting in the meadow.
class MemoryObject extends StatefulWidget {
  final Memory memory;
  final VoidCallback onTap;
  final double animationPhase; // 0.0 to 1.0 to desynchronize gentle floating
  final bool isHighlighted;

  const MemoryObject({
    super.key,
    required this.memory,
    required this.onTap,
    this.animationPhase = 0.0,
    this.isHighlighted = false,
  });

  @override
  State<MemoryObject> createState() => _MemoryObjectState();
}

class _MemoryObjectState extends State<MemoryObject>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _hoverAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Apply phase offset
    final startValue = (widget.animationPhase % 1.0);
    _hoverController.value = startValue;
    _hoverController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPhoto = widget.memory.type == MemoryType.photo;

    return Semantics(
      button: true,
      label: '${isPhoto ? "Photo memory" : "Story memory"}: ${widget.memory.title}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _hoverAnimation,
          builder: (context, child) {
            final hoverOffset = _hoverAnimation.value;
            final scale = _isPressed ? 0.94 : 1.0;

            return Transform.translate(
              offset: Offset(0, hoverOffset),
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isHighlighted)
                _buildFloatingHeartBadge(),
              isPhoto
                  ? _buildFramedPhotoObject(context)
                  : _buildStoryBookObject(context),
              const SizedBox(height: 6),
              _buildParchmentLabel(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHeartBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPink.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, color: AppTheme.primaryPink, size: 11),
          const SizedBox(width: 4),
          Text(
            'Visiting ♡',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryPink,
            ),
          ),
        ],
      ),
    );
  }

  /// Illustrated Framed Keepsake Photo Object resting in the world
  Widget _buildFramedPhotoObject(BuildContext context) {
    final hasImage = widget.memory.imagePath != null &&
        File(widget.memory.imagePath!).existsSync();

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Easel legs (illustrated wooden backstand)
        CustomPaint(
          size: const Size(82, 88),
          painter: _EaselLegsPainter(),
        ),

        // The Framed Photo Keepsake itself
        Container(
          width: 74,
          height: 74,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppTheme.creamLight, // Warm paper keepsake border
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isHighlighted
                  ? AppTheme.primaryPink
                  : const Color(0xFFE2CDBA), // Warm wood/paper edge
              width: 2.2,
            ),
            boxShadow: [
              if (widget.isHighlighted) ...[
                BoxShadow(
                  color: AppTheme.softYellowDark.withValues(alpha: 0.65),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
              ...AppTheme.paperShadow,
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hasImage
                ? Image.file(
                    File(widget.memory.imagePath!),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppTheme.primaryPinkLight,
                    child: Center(
                      child: Icon(
                        Icons.photo_camera_back_rounded,
                        color: AppTheme.primaryPink.withValues(alpha: 0.7),
                        size: 26,
                      ),
                    ),
                  ),
          ),
        ),

        // Little hanging antique gold pin at top
        Positioned(
          top: -2,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.softYellowDark,
              border: Border.all(color: const Color(0xFFB89F70), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),

        // Tiny botanical keepsake decoration on corner
        const Positioned(
          bottom: -4,
          right: -3,
          child: StorybookFlower(size: 14),
        ),
      ],
    );
  }

  /// Illustrated Storybook Journal Object resting in the world
  Widget _buildStoryBookObject(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Mossy stone or wooden pedestal base
        Container(
          margin: const EdgeInsets.only(top: 48),
          width: 68,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFE5DDD0),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A3423).withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),

        // Illustrated Bound Book
        Container(
          width: 70,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF9), // Book pages
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(12),
            ),
            border: Border.all(
              color: widget.isHighlighted
                  ? AppTheme.primaryPink
                  : const Color(0xFF947B65), // Leather spine color
              width: 2.5,
            ),
            boxShadow: [
              if (widget.isHighlighted) ...[
                BoxShadow(
                  color: const Color(0xFFFFD166).withValues(alpha: 0.65),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: const Color(0xFF90C2A3).withValues(alpha: 0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
              BoxShadow(
                color: const Color(0xFF4A3423).withValues(alpha: 0.16),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF90C2A3).withValues(alpha: 0.25),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Spine highlight on left
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 14,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFB89F88), // Warm brown leather spine
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                  ),
                ),
              ),

              // Embossed heart and subtle text lines on cover
              Positioned.fill(
                left: 14,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: AppTheme.primaryPink.withValues(alpha: 0.8),
                        size: 16,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5DDD0),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 24,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5DDD0),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Ribbon bookmark dangling from top
              Positioned(
                top: 0,
                right: 14,
                child: Container(
                  width: 5,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Small organic parchment label displaying the memory title
  Widget _buildParchmentLabel(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 104),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFDCCFBE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.memory.title,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

/// Custom painter for mini easel tripod legs behind the photo frame
class _EaselLegsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final woodPaint = Paint()
      ..color = const Color(0xFFCBB29C)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    // Left leg
    canvas.drawLine(
      Offset(centerX - 10, 16),
      Offset(12, size.height - 2),
      woodPaint,
    );
    // Right leg
    canvas.drawLine(
      Offset(centerX + 10, 16),
      Offset(size.width - 12, size.height - 2),
      woodPaint,
    );
    // Center back strut
    final backPaint = Paint()
      ..color = const Color(0xFFA68D77)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, 8),
      Offset(centerX, size.height - 8),
      backPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
