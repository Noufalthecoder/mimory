import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';
import 'package:mimory/features/world/screens/world_screen.dart';
import 'package:mimory/features/memory/screens/first_memory_screen.dart';

class WorldCreatedScreen extends StatefulWidget {
  final World world;

  const WorldCreatedScreen({
    super.key,
    required this.world,
  });

  @override
  State<WorldCreatedScreen> createState() => _WorldCreatedScreenState();
}

class _WorldCreatedScreenState extends State<WorldCreatedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WorldScreen(world: widget.world),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Miniature Storybook Landscape Vignette
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppTheme.creamLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.borderSubtle,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPink.withValues(alpha: 0.18),
                          blurRadius: 30,
                          spreadRadius: 6,
                        ),
                        ...AppTheme.paperShadow,
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Miniature landscape painter
                          CustomPaint(
                            size: const Size(140, 140),
                            painter: _MiniatureLandscapePainter(),
                          ),
                          // Tiny decorative blossom
                          const Positioned(
                            top: 18,
                            right: 24,
                            child: StorybookSparkle(size: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Heading
                  Text(
                    'Our world is ready. ♡',
                    style: GoogleFonts.mali(
                      color: AppTheme.primaryPinkDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // World Name
                  Text(
                    widget.world.name,
                    style: GoogleFonts.mali(
                      color: AppTheme.textPrimary,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Every world starts with one little moment.',
                    style: GoogleFonts.nunito(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Primary Tactile Button
                  SizedBox(
                    width: double.infinity,
                    child: TactilePillButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    FirstMemoryScreen(world: widget.world),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            transitionDuration:
                                const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      text: 'Add our first moment ♡',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Secondary action
                  TextButton(
                    onPressed: _navigateToHome,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Explore our world',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter rendering a cute miniature landscape vignette
class _MiniatureLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Sky gradient background
    final skyPaint = Paint()..color = const Color(0xFFFFF8EE);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Warm little sun
    final sunPaint = Paint()..color = const Color(0xFFFFECC7);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.32), 16, sunPaint);

    // Distant soft hill
    final hillPaint1 = Paint()..color = const Color(0xFFBED8C0);
    final path1 = Path();
    path1.moveTo(0, size.height * 0.65);
    path1.quadraticBezierTo(
        size.width * 0.45, size.height * 0.48, size.width, size.height * 0.62);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, hillPaint1);

    // Foreground lush meadow
    final hillPaint2 = Paint()..color = const Color(0xFFA2C7A0);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.76);
    path2.quadraticBezierTo(
        size.width * 0.55, size.height * 0.62, size.width, size.height * 0.78);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, hillPaint2);

    // One gentle tree on left
    final trunk = Paint()
      ..color = const Color(0xFF947B65)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.28, size.height * 0.74),
        Offset(size.width * 0.28, size.height * 0.52), trunk);
    final foliage = Paint()..color = const Color(0xFF7FA882);
    canvas.drawCircle(
        Offset(size.width * 0.28, size.height * 0.48), 16, foliage);

    // Two tiny characters standing close
    final c1 = Paint()..color = AppTheme.primaryPink;
    final c2 = Paint()..color = const Color(0xFF5A8E65);
    canvas.drawCircle(Offset(size.width * 0.56, size.height * 0.68), 5.5, c1);
    canvas.drawCircle(Offset(size.width * 0.66, size.height * 0.68), 5.5, c2);

    // One little flower
    final flowerPaint = Paint()..color = AppTheme.primaryPink;
    canvas.drawCircle(
        Offset(size.width * 0.46, size.height * 0.74), 4.0, flowerPaint);
    canvas.drawCircle(Offset(size.width * 0.46, size.height * 0.74), 2.0,
        Paint()..color = AppTheme.softYellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
