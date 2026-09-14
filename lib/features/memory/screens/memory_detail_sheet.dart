import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';

/// Storybook keepsake page presenting memory details when a World Object is tapped.
/// Feels like turning to a dedicated illustrated page in a personal memory book.
class MemoryDetailSheet extends StatelessWidget {
  final Memory memory;

  const MemoryDetailSheet({super.key, required this.memory});

  static Future<void> show(BuildContext context, Memory memory) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: AppTheme.textPrimary.withValues(alpha: 0.35),
      builder: (context) => MemoryDetailSheet(memory: memory),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isPhoto = memory.type == MemoryType.photo;
    final hasImage = memory.imagePath != null &&
        File(memory.imagePath!).existsSync();
    final hasDescription = memory.description.trim().isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1.5,
        ),
        boxShadow: AppTheme.cardElevatedShadow,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag pill
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),

                // Storybook Header Stamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const StorybookLeaf(size: 14, angle: -0.3),
                    const SizedBox(width: 8),
                    Text(
                      isPhoto ? 'A PHOTO MOMENT' : 'A STORY MOMENT',
                      style: GoogleFonts.mali(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: isPhoto
                            ? AppTheme.primaryPinkDark
                            : AppTheme.sageGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const StorybookLeaf(size: 14, angle: 0.3),
                  ],
                ),
                const SizedBox(height: 16),

                // Photo Display inside warm keepsake frame (if Photo memory)
                if (isPhoto && hasImage) ...[
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 290),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFE5D5C5),
                        width: 2,
                      ),
                      boxShadow: AppTheme.paperShadow,
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            File(memory.imagePath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        // Tiny corner flower
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: StorybookFlower(size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Memory Title
                Text(
                  '${memory.title} ♡',
                  style: GoogleFonts.mali(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),

                // Formatted Date
                Text(
                  _formatDate(memory.memoryDate),
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // Story / Description styled like a warm keepsake note
                if (hasDescription) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.borderSubtle,
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '"${memory.description}"',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Close Button
                TactilePillButton(
                  onPressed: () => Navigator.pop(context),
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  text: 'Close story ♡',
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
