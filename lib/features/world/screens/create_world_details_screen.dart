import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/services/world_service.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/core/widgets/mimory_text_field.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';
import 'package:mimory/features/world/screens/world_created_screen.dart';

/// Phase 8: Steps 4 & 5 of World Creation.
/// Selects World Name & World Style, persists the World to local storage,
/// then transitions to WorldCreatedScreen -> Growth animation.
class CreateWorldDetailsScreen extends StatefulWidget {
  final String relationshipId;
  final String relationshipLabel;
  final String personName;
  final String? nickname;
  final String? photoPath;
  final String? personGender;
  final String userAvatarId;
  final String companionAvatarId;

  const CreateWorldDetailsScreen({
    super.key,
    required this.relationshipId,
    required this.relationshipLabel,
    required this.personName,
    this.nickname,
    this.photoPath,
    this.personGender,
    required this.userAvatarId,
    required this.companionAvatarId,
  });

  @override
  State<CreateWorldDetailsScreen> createState() =>
      _CreateWorldDetailsScreenState();
}

class _CreateWorldDetailsScreenState extends State<CreateWorldDetailsScreen> {
  final TextEditingController _worldNameController = TextEditingController();
  String _selectedStyle = 'cozy_town';
  bool _isCreating = false;

  final List<Map<String, dynamic>> _styles = [
    {
      'id': 'cozy_town',
      'label': 'Cozy Town',
      'description': 'Warm cottages, cobblestone paths & friendly cafes',
      'icon': Icons.cottage_rounded,
      'color': const Color(0xFFE5B068),
    },
    {
      'id': 'blooming_meadow',
      'label': 'Blooming Meadow',
      'description': 'Lush rolling hills, wildflowers & fluttering butterflies',
      'icon': Icons.filter_vintage_rounded,
      'color': AppTheme.primaryPink,
    },
    {
      'id': 'starlit_forest',
      'label': 'Starlit Forest',
      'description': 'Enchanted woods under twilight & peaceful fireflies',
      'icon': Icons.park_rounded,
      'color': AppTheme.sageGreen,
    },
    {
      'id': 'sunlit_valley',
      'label': 'Sunlit Valley',
      'description': 'Golden pastures, winding rivers & gentle morning sun',
      'icon': Icons.wb_sunny_rounded,
      'color': const Color(0xFFD49340),
    },
  ];

  @override
  void initState() {
    super.initState();
    _worldNameController.text = _getDefaultWorldName();
  }

  @override
  void dispose() {
    _worldNameController.dispose();
    super.dispose();
  }

  String _getDefaultWorldName() {
    switch (widget.relationshipId) {
      case 'partner':
        return 'My Love';
      case 'best_friend':
        return 'Our Little Chaos';
      case 'family':
        return 'Warm Roots';
      case 'friend_group':
        return 'Our Gang';
      default:
        return '${widget.personName}\'s World';
    }
  }

  Future<void> _createWorld() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);

    final worldName = _worldNameController.text.trim().isEmpty
        ? _getDefaultWorldName()
        : _worldNameController.text.trim();

    // Persist world BEFORE navigating onward
    final world = await WorldService().createWorld(
      name: worldName,
      relationshipType: widget.relationshipId,
      personName: widget.personName,
      nickname: widget.nickname,
      personPhotoPath: widget.photoPath,
      personGender: widget.personGender,
      userAvatarId: widget.userAvatarId,
      companionAvatarId: widget.companionAvatarId,
      worldStyle: _selectedStyle,
    );

    if (!mounted) return;
    setState(() => _isCreating = false);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WorldCreatedScreen(world: world),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      'Steps 4 & 5 of 5',
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 14),

                    // Heading
                    Text(
                      'Give your world a name ♡',
                      style: GoogleFonts.mali(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.25,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // Subheading
                    Text(
                      'Pick a cozy style and title for your story.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // World Name Input Field
                    MimoryTextField(
                      label: 'Our world is called...',
                      hint: 'e.g. Our Little Chaos',
                      controller: _worldNameController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 28),

                    // World Style Section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const StorybookLeaf(size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'World Style',
                            style: GoogleFonts.mali(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // World Style Cards Grid
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _styles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final style = _styles[index];
                        final isSelected = _selectedStyle == style['id'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedStyle = style['id'] as String;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryPinkLight
                                  : AppTheme.creamLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryPink
                                    : AppTheme.borderSubtle,
                                width: isSelected ? 1.8 : 1.2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryPink
                                            .withValues(alpha: 0.16),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : AppTheme.paperShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: (style['color'] as Color)
                                        .withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    style['icon'] as IconData,
                                    color: style['color'] as Color,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        style['label'] as String,
                                        style: GoogleFonts.mali(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? AppTheme.primaryPinkDark
                                              : AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        style['description'] as String,
                                        style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.primaryPink,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Create World Tactile Button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
              child: SizedBox(
                width: double.infinity,
                child: TactilePillButton(
                  onPressed: _isCreating ? null : _createWorld,
                  text: _isCreating ? 'Creating our world...' : 'Create our world ♡',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
