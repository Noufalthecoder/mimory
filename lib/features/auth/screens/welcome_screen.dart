import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mimory/features/auth/screens/login_screen.dart';

/// Landing Welcome Screen for MIMORY.
/// Displays the full-bleed storybook artwork and provides a responsive,
/// tactile touch interaction over the illustrated "Open our storybook ♡" button
/// without drawing duplicate overlapping widgets.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _imageFade;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();

    // Transparent status bar for full-bleed illustration
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _imageFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openStorybook() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          // In splash.jpg (576 x 1024), the illustrated button is painted at 82.4% - 89.4% height.
          // We provide a dedicated tactile hit-target directly over the illustrated button
          // with spring feedback, eliminating duplicate buttons.
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openStorybook,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Full-bleed Exact Storybook Illustration
                FadeTransition(
                  opacity: _imageFade,
                  child: Image.asset(
                    'assets/images/splash.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    width: screenWidth,
                    height: screenHeight,
                  ),
                ),

                // 2. Tactile Interactive Hit Target directly over the illustrated button
                Positioned(
                  top: screenHeight * 0.815,
                  left: (screenWidth * 0.08).clamp(16.0, 48.0),
                  right: (screenWidth * 0.08).clamp(16.0, 48.0),
                  height: (screenHeight * 0.085).clamp(50.0, 70.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) {
                      setState(() => _isButtonPressed = true);
                      HapticFeedback.lightImpact();
                    },
                    onTapUp: (_) {
                      setState(() => _isButtonPressed = false);
                      _openStorybook();
                    },
                    onTapCancel: () {
                      setState(() => _isButtonPressed = false);
                    },
                    child: AnimatedScale(
                      scale: _isButtonPressed ? 0.96 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: _isButtonPressed
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
