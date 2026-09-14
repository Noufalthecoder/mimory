import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/services/world_service.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/core/widgets/mimory_text_field.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';
import 'package:mimory/features/monetization/screens/world_just_grew_screen.dart';

class FirstMemoryScreen extends StatefulWidget {
  final World world;
  final MemoryType initialType;

  const FirstMemoryScreen({
    super.key,
    required this.world,
    this.initialType = MemoryType.photo,
  });

  @override
  State<FirstMemoryScreen> createState() => _FirstMemoryScreenState();
}

class _FirstMemoryScreenState extends State<FirstMemoryScreen> {
  late MemoryType _selectedType;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _photoPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPink,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
              surface: AppTheme.creamLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMemory() async {
    if (!_canSave()) return;

    final memory = await WorldService().createMemory(
      worldId: widget.world.id,
      type: _selectedType,
      title: _titleController.text.trim(),
      description: _storyController.text.trim(),
      imagePath: _selectedType == MemoryType.photo ? _photoPath : null,
      memoryDate: _selectedDate,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WorldJustGrewScreen(world: widget.world, memory: memory),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  bool _canSave() {
    final hasTitle = _titleController.text.trim().isNotEmpty;
    if (_selectedType == MemoryType.photo) {
      return hasTitle && _photoPath != null;
    } else {
      return hasTitle && _storyController.text.trim().isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back button and world badge
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPinkLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryPink.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const StorybookLeaf(size: 13, angle: -0.2),
                        const SizedBox(width: 6),
                        Text(
                          widget.world.name,
                          style: GoogleFonts.mali(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryPinkDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Emotional Storybook Header
                    Text(
                      'Add a little moment ♡',
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
                      'Something worth keeping.',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Type Selection as little storybook keepsake cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeCard(
                            type: MemoryType.photo,
                            title: 'A photo',
                            subtitle: 'A moment you can see.',
                            icon: Icons.photo_camera_back_rounded,
                            accentColor: AppTheme.primaryPink,
                            bgColor: AppTheme.primaryPinkLight,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildTypeCard(
                            type: MemoryType.story,
                            title: 'A story',
                            subtitle: 'Words to hold close.',
                            icon: Icons.menu_book_rounded,
                            accentColor: AppTheme.sageGreen,
                            bgColor: AppTheme.sageGreenLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Dynamic Flow
                    if (_selectedType == MemoryType.photo)
                      _buildPhotoFlow()
                    else
                      _buildStoryFlow(),

                    const SizedBox(height: 32),
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
                  onPressed: _canSave() ? _saveMemory : null,
                  text: 'Add to our world ♡',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required MemoryType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Transform.scale(
        scale: isSelected ? 1.03 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.creamLight : AppTheme.creamLight.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? accentColor : AppTheme.borderSubtle,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppTheme.paperShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.mali(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildPhotoFlow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.creamLight,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: _photoPath != null
                      ? AppTheme.primaryPink
                      : AppTheme.borderSubtle,
                  width: 1.8,
                ),
                image: _photoPath != null
                    ? DecorationImage(
                        image: FileImage(File(_photoPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: AppTheme.paperShadow,
              ),
              child: _photoPath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryPinkLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 28,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Choose a keepsake photo',
                          style: GoogleFonts.mali(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to select from your gallery',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.all(14),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.textPrimary.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _buildSharedDetails(),
      ],
    );
  }

  Widget _buildStoryFlow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What happened?',
          style: GoogleFonts.mali(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.creamLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.borderSubtle,
              width: 1.4,
            ),
            boxShadow: AppTheme.paperShadow,
          ),
          child: TextField(
            controller: _storyController,
            onChanged: (_) => setState(() {}),
            maxLines: 5,
            style: GoogleFonts.nunito(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Tell your little story...',
              hintStyle: GoogleFonts.nunito(
                fontSize: 14,
                color: AppTheme.textTertiary,
              ),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 28),
        _buildSharedDetails(),
      ],
    );
  }

  Widget _buildSharedDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MimoryTextField(
          label: 'Give this moment a name',
          hint: 'e.g. Our first trip',
          controller: _titleController,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),

        Text(
          'When did it happen?',
          style: GoogleFonts.mali(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.creamLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.borderSubtle,
                width: 1.2,
              ),
              boxShadow: AppTheme.paperShadow,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppTheme.primaryPink,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(_selectedDate),
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppTheme.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_selectedType == MemoryType.photo) ...[
          const SizedBox(height: 20),
          MimoryTextField(
            label: 'Why is this moment special?',
            hint: 'Story note (optional)',
            controller: _storyController,
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}
