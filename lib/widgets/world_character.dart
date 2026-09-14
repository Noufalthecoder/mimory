import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/core/theme/app_theme.dart';

/// Decoupled character representation inside the Living World.
/// Displays the person's photo inside a stylized illustrated frame,
/// or a charming storybook avatar placeholder if no photo was provided.
/// Designed for easy drop-in replacement with future AI-generated characters.
class WorldCharacter extends StatelessWidget {
  final World world;
  final double size;

  const WorldCharacter({
    super.key,
    required this.world,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = world.personPhotoPath != null &&
        File(world.personPhotoPath!).existsSync();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: AppTheme.primaryPink.withValues(alpha: 0.8),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5A3E2B).withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppTheme.primaryPink.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: ClipOval(
              child: hasPhoto
                  ? Image.file(
                      File(world.personPhotoPath!),
                      fit: BoxFit.cover,
                      width: size,
                      height: size,
                    )
                  : Container(
                      color: const Color(0xFFFFF2EE),
                      child: Center(
                        child: Text(
                          world.personName.isNotEmpty
                              ? world.personName[0].toUpperCase()
                              : '♡',
                          style: GoogleFonts.mali(
                            fontSize: size * 0.45,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8D8177).withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            world.nickname?.isNotEmpty == true
                ? world.nickname!
                : world.personName,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
