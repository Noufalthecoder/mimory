import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';
import 'package:mimory/features/world/screens/world_screen.dart';

class WorldJustGrewScreen extends StatefulWidget {
  final World world;
  final Memory memory;

  const WorldJustGrewScreen({
    super.key,
    required this.world,
    required this.memory,
  });

  @override
  State<WorldJustGrewScreen> createState() => _WorldJustGrewScreenState();
}

class _WorldJustGrewScreenState extends State<WorldJustGrewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    // 7-step growth sequence over ~1.3 seconds
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enterWorld() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WorldScreen(world: widget.world, showEntryTransition: true),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _skipAnimation() {
    if (_controller.value < 0.95) {
      _controller.animateTo(1.0, duration: const Duration(milliseconds: 200));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhoto = widget.memory.type == MemoryType.photo;
    final hasImage = widget.memory.imagePath != null &&
        File(widget.memory.imagePath!).existsSync();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: _skipAnimation,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // 7-Stage Magical Sprout-to-Flower Animation Container
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppTheme.creamLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.borderSubtle,
                              width: 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.sageGreen.withValues(
                                  alpha: (0.15 + _controller.value * 0.2)
                                      .clamp(0.0, 0.35),
                                ),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                              ...AppTheme.paperShadow,
                            ],
                          ),
                          child: CustomPaint(
                            size: const Size(140, 140),
                            painter: _SeedToFlowerPainter(
                              progress: _controller.value,
                              isPhoto: isPhoto,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Content Animation
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            Text(
                              'Your world just grew. ♡',
                              style: GoogleFonts.mali(
                                color: AppTheme.primaryPinkDark,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'One little moment is now\npart of your story.',
                              style: GoogleFonts.nunito(
                                color: AppTheme.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),

                            // Keepsake Memory Card Preview
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.creamLight,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppTheme.borderSubtle,
                                  width: 1.4,
                                ),
                                boxShadow: AppTheme.paperShadow,
                              ),
                              child: Row(
                                children: [
                                  // Preview Image or Illustrated Icon
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: isPhoto
                                          ? AppTheme.primaryPinkLight
                                          : AppTheme.sageGreenLight,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppTheme.borderSubtle,
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: isPhoto && hasImage
                                          ? Image.file(
                                              File(widget.memory.imagePath!),
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              isPhoto
                                                  ? Icons.photo_camera_back_rounded
                                                  : Icons.menu_book_rounded,
                                              color: isPhoto
                                                  ? AppTheme.primaryPink
                                                  : AppTheme.sageGreen,
                                              size: 26,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.world.name,
                                          style: GoogleFonts.nunito(
                                            color: AppTheme.primaryPinkDark,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          widget.memory.title,
                                          style: GoogleFonts.mali(
                                            color: AppTheme.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const StorybookLeaf(size: 16, angle: 0.2),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Buttons
                    FadeTransition(
                      opacity: _contentFade,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: TactilePillButton(
                              onPressed: _enterWorld,
                              text: 'Enter our world ♡',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Add another moment',
                              style: GoogleFonts.nunito(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter implementing the 7-step growth sequence:
/// 1. Seed appears (0.00 - 0.15)
/// 2. Seed gently grows (0.15 - 0.30)
/// 3. Sprout emerges (0.30 - 0.45)
/// 4. Leaves expand (0.45 - 0.60)
/// 5. Flower blooms (0.60 - 0.80)
/// 6. Memory keepsake reveals (0.80 - 0.92)
/// 7. Sparkles & settles (0.92 - 1.00)
class _SeedToFlowerPainter extends CustomPainter {
  final double progress;
  final bool isPhoto;

  _SeedToFlowerPainter({
    required this.progress,
    required this.isPhoto,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Soft mound base
    final moundPaint = Paint()..color = const Color(0xFFE4EDE5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 34),
        width: 60,
        height: 16,
      ),
      moundPaint,
    );

    // Stage 1 & 2: Seed
    if (progress < 0.35) {
      final seedT = (progress / 0.35).clamp(0.0, 1.0);
      final seedSize = 4.0 + seedT * 5.0;
      final seedPaint = Paint()..color = const Color(0xFFC49A7E);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, cy + 28),
          width: seedSize,
          height: seedSize * 1.3,
        ),
        seedPaint,
      );
      return;
    }

    // Stage 3 & 4: Sprout emerging
    final sproutT = ((progress - 0.30) / 0.35).clamp(0.0, 1.0);
    final stemHeight = 10.0 + sproutT * 32.0;

    final stemPaint = Paint()
      ..color = AppTheme.sageGreen
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final stemPath = Path();
    stemPath.moveTo(cx, cy + 28);
    stemPath.quadraticBezierTo(cx - 3, cy + 28 - stemHeight * 0.5, cx, cy + 28 - stemHeight);
    canvas.drawPath(stemPath, stemPaint);

    // Leaves unfurling
    if (sproutT > 0.3) {
      final leafScale = ((sproutT - 0.3) / 0.7).clamp(0.0, 1.0);
      final leafPaint = Paint()..color = AppTheme.sageGreen;

      // Left leaf
      canvas.save();
      canvas.translate(cx - 2, cy + 28 - stemHeight * 0.6);
      canvas.rotate(-0.5 * leafScale);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(-8 * leafScale, 0), width: 14 * leafScale, height: 7 * leafScale),
        leafPaint,
      );
      canvas.restore();

      // Right leaf
      canvas.save();
      canvas.translate(cx + 2, cy + 28 - stemHeight * 0.7);
      canvas.rotate(0.5 * leafScale);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(8 * leafScale, 0), width: 14 * leafScale, height: 7 * leafScale),
        leafPaint,
      );
      canvas.restore();
    }

    // Stage 5 & 6 & 7: Flower blooming & keepsake heart
    if (progress > 0.55) {
      final bloomT = ((progress - 0.55) / 0.45).clamp(0.0, 1.0);
      final flowerCenter = Offset(cx, cy + 28 - stemHeight);
      final petalRadius = 9.0 * bloomT;

      final petalPaint = Paint()..color = AppTheme.primaryPink;
      for (int i = 0; i < 5; i++) {
        final angle = i * (2 * math.pi / 5) - math.pi / 2;
        final px = flowerCenter.dx + math.cos(angle) * (petalRadius * 1.1);
        final py = flowerCenter.dy + math.sin(angle) * (petalRadius * 1.1);
        canvas.drawCircle(Offset(px, py), petalRadius * 0.8, petalPaint);
      }

      // Golden center
      final centerPaint = Paint()..color = AppTheme.softYellow;
      canvas.drawCircle(flowerCenter, petalRadius * 0.7, centerPaint);

      // Tiny heart inside blossom
      final heartPaint = Paint()..color = AppTheme.primaryPinkDark;
      canvas.drawCircle(Offset(flowerCenter.dx - 1.8, flowerCenter.dy - 1), 2.2 * bloomT, heartPaint);
      canvas.drawCircle(Offset(flowerCenter.dx + 1.8, flowerCenter.dy - 1), 2.2 * bloomT, heartPaint);

      // Sparkles around bloom
      if (progress > 0.75) {
        final sparkleT = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);
        final sparklePaint = Paint()
          ..color = AppTheme.softYellowDark.withValues(alpha: sparkleT * 0.9);

        canvas.drawCircle(Offset(cx - 24, cy - 8), 2.5 * sparkleT, sparklePaint);
        canvas.drawCircle(Offset(cx + 26, cy - 14), 2.0 * sparkleT, sparklePaint);
        canvas.drawCircle(Offset(cx + 20, cy + 16), 1.8 * sparkleT, sparklePaint);
        canvas.drawCircle(Offset(cx - 20, cy + 12), 2.2 * sparkleT, sparklePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SeedToFlowerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
