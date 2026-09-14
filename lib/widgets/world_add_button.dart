import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/memory/screens/first_memory_screen.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';

/// Small, organic illustrated action button to add a memory into the current world.
/// Replaces standard Material FABs with a warm storybook motif and pulsing glow.
class WorldAddButton extends StatefulWidget {
  final World world;
  final VoidCallback onMemoryAdded;

  const WorldAddButton({
    super.key,
    required this.world,
    required this.onMemoryAdded,
  });

  @override
  State<WorldAddButton> createState() => _WorldAddButtonState();
}

class _WorldAddButtonState extends State<WorldAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppTheme.textPrimary.withValues(alpha: 0.3),
      builder: (context) => _buildAddSheet(context),
    );
  }

  Widget _buildAddSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: AppTheme.cardElevatedShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Storybook Pill
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title with gentle leaf motif
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const StorybookLeaf(size: 16, angle: -0.3),
                  const SizedBox(width: 8),
                  Text(
                    'Add a little moment ♡',
                    style: GoogleFonts.mali(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 8),
                  const StorybookLeaf(size: 16, angle: 0.3),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Something worth keeping.',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Option 1: Photo
              _buildAddOption(
                context: context,
                type: MemoryType.photo,
                title: 'A photo',
                subtitle: 'A little framed keepsake.',
                icon: Icons.photo_camera_back_rounded,
                accentColor: AppTheme.primaryPink,
                bgColor: AppTheme.primaryPinkLight,
              ),
              const SizedBox(height: 12),

              // Option 2: Story
              _buildAddOption(
                context: context,
                type: MemoryType.story,
                title: 'A story',
                subtitle: 'Thoughts and feelings in words.',
                icon: Icons.menu_book_rounded,
                accentColor: AppTheme.sageGreen,
                bgColor: AppTheme.sageGreenLight,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOption({
    required BuildContext context,
    required MemoryType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context); // Close sheet
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                FirstMemoryScreen(
              world: widget.world,
              initialType: type,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
        widget.onMemoryAdded();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.creamLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.35),
            width: 1.4,
          ),
          boxShadow: AppTheme.paperShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.mali(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add a little moment ♡',
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () => _showAddModal(context),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryPink,
              border: Border.all(
                color: Colors.white,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                ...AppTheme.paperShadow,
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
