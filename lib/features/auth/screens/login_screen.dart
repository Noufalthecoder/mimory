import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/services/world_service.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/core/widgets/mimory_text_field.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';
import 'package:mimory/core/widgets/google_logo_widget.dart';
import 'package:mimory/features/world/screens/relationship_selection_screen.dart';
import 'package:mimory/features/world/screens/your_worlds_screen.dart';

/// Storybook Mock Login Screen for MIMORY.
/// Simulates seamless Google and Email mock sign-in, creating a persistent session.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _showEmailField = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    await WorldService().loginWithGoogle();
    if (!mounted) return;
    setState(() => _isLoading = false);
    _navigateAfterLogin();
  }

  Future<void> _handleEmailSignIn() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    await WorldService().loginWithEmail(email);
    if (!mounted) return;
    setState(() => _isLoading = false);
    _navigateAfterLogin();
  }

  void _navigateAfterLogin() {
    final hasWorlds = WorldService().worlds.isNotEmpty;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            hasWorlds ? const YourWorldsScreen() : const RelationshipSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button (if can pop)
              Align(
                alignment: Alignment.centerLeft,
                child: Navigator.canPop(context)
                    ? GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppTheme.creamLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.borderSubtle,
                              width: 1,
                            ),
                            boxShadow: AppTheme.paperShadow,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.textPrimary,
                            size: 18,
                          ),
                        ),
                      )
                    : const SizedBox(height: 38),
              ),
              const SizedBox(height: 18),

              // Decorative illustrated storybook emblem
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppTheme.creamLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2CDBA),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPink.withValues(alpha: 0.15),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                        ...AppTheme.paperShadow,
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 38,
                            color: AppTheme.primaryPink,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '♡',
                            style: GoogleFonts.mali(
                              color: AppTheme.primaryPinkDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 2,
                    right: 4,
                    child: StorybookSparkle(size: 16),
                  ),
                  const Positioned(
                    bottom: 2,
                    left: 4,
                    child: StorybookFlower(size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Storybook Heading
              Text(
                'Welcome back to your little world ♡',
                style: GoogleFonts.mali(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Subheading
              Text(
                'Your people and moments are waiting.',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 38),

              if (_isLoading) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  color: AppTheme.primaryPink,
                  strokeWidth: 2.5,
                ),
                const SizedBox(height: 24),
              ] else ...[
                // Continue with Google Button
                SizedBox(
                  width: double.infinity,
                  child: TactilePillButton(
                    onPressed: _handleGoogleSignIn,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3C4043), // Google's standard dark gray text color
                    border: Border.all(
                      color: const Color(0xFFDADCE0), // Google's standard border color
                      width: 1.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Authentic 4-color Google "G" Logo
                        const GoogleLogoWidget(size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3C4043),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Divider or alternate choice
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Color(0xFFE2CDBA),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text(
                        'or',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Color(0xFFE2CDBA),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                if (!_showEmailField) ...[
                  // Continue with email prompt
                  SizedBox(
                    width: double.infinity,
                    child: TactilePillButton(
                      onPressed: () {
                        setState(() {
                          _showEmailField = true;
                        });
                      },
                      backgroundColor: AppTheme.primaryPink,
                      foregroundColor: Colors.white,
                      text: 'Continue with email ♡',
                    ),
                  ),
                ] else ...[
                  // Simple email input
                  MimoryTextField(
                    label: 'Your email',
                    hint: 'e.g. noufal@mimory.app',
                    controller: _emailController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TactilePillButton(
                      onPressed: _emailController.text.trim().isNotEmpty
                          ? _handleEmailSignIn
                          : null,
                      backgroundColor: AppTheme.primaryPink,
                      foregroundColor: Colors.white,
                      text: 'Sign in to our story ♡',
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 32),

              // Soft botanical footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const StorybookLeaf(size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Handmade with love for cherished memories',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const StorybookFlower(size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
