import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/core/widgets/mimory_text_field.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';
import 'package:mimory/features/world/screens/choose_avatars_screen.dart';

/// Step 2 of World Creation: Person Information
/// Collects Person Name, Photo, Nickname, and Character Gender before proceeding to Avatar Selection.
class CreateWorldScreen extends StatefulWidget {
  final String relationshipId;
  final String relationshipLabel;

  const CreateWorldScreen({
    super.key,
    required this.relationshipId,
    required this.relationshipLabel,
  });

  @override
  State<CreateWorldScreen> createState() => _CreateWorldScreenState();
}

class _CreateWorldScreenState extends State<CreateWorldScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  String? _photoPath;
  String _selectedGender = 'female';
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  void _continueToAvatars() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChooseAvatarsScreen(
          relationshipId: widget.relationshipId,
          relationshipLabel: widget.relationshipLabel,
          personName: name,
          nickname: _nicknameController.text.trim().isEmpty
              ? null
              : _nicknameController.text.trim(),
          photoPath: _photoPath,
          personGender: _selectedGender,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = _nameController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back button and step indicator
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 20.0),
              child: Row(
                children: [
                  GestureDetector(
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
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.creamLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Step 2 of 5',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    // Heading
                    Text(
                      "Who is this world for? ♡",
                      style: GoogleFonts.mali(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Every story begins with someone special.",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Keepsake Photo Frame
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 124,
                            height: 124,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppTheme.creamLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _photoPath != null
                                    ? AppTheme.primaryPink
                                    : const Color(0xFFE2CDBA),
                                width: 2.5,
                              ),
                              boxShadow: AppTheme.paperShadow,
                            ),
                            child: ClipOval(
                              child: _photoPath != null
                                  ? Image.file(
                                      File(_photoPath!),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: AppTheme.primaryPinkLight,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.photo_camera_outlined,
                                            size: 28,
                                            color: AppTheme.primaryPinkDark,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Add photo',
                                            style: GoogleFonts.mali(
                                              color: AppTheme.primaryPinkDark,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                          // Illustrated corner flower badge
                          const Positioned(
                            bottom: 2,
                            right: 2,
                            child: StorybookFlower(size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Handwritten story fields
                    MimoryTextField(
                      label: 'Their name',
                      hint: 'e.g. Ayaan',
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // Gender Selection for anime characters
                    _buildGenderSelector(),
                    const SizedBox(height: 20),

                    MimoryTextField(
                      label: 'Nickname',
                      hint: 'What do you call them? (optional)',
                      controller: _nicknameController,
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // Bottom Tactile Pill Button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
              child: SizedBox(
                width: double.infinity,
                child: TactilePillButton(
                  onPressed: canSubmit ? _continueToAvatars : null,
                  text: 'Choose our avatars ♡',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Their character',
          style: GoogleFonts.mali(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                gender: 'female',
                label: 'Female',
                icon: Icons.face_3_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGenderOption(
                gender: 'male',
                label: 'Male',
                icon: Icons.face_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGenderOption(
                gender: 'other',
                label: 'Other',
                icon: Icons.auto_awesome_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required String gender,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryPinkLight
              : AppTheme.creamLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryPink
                : AppTheme.borderSubtle,
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPink.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppTheme.paperShadow,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppTheme.primaryPinkDark
                  : AppTheme.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? AppTheme.primaryPinkDark
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
