import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/avatar_definition.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/widgets/storybook_avatar_widget.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';
import 'package:mimory/features/world/screens/create_world_details_screen.dart';

/// Phase 1: Avatar Selection Screen for MIMORY World Creation.
/// Allows selecting "Your avatar" and "Their avatar" from a curated grid of
/// hand-painted anime/storybook avatars.
class ChooseAvatarsScreen extends StatefulWidget {
  final String relationshipId;
  final String relationshipLabel;
  final String personName;
  final String? nickname;
  final String? photoPath;
  final String? personGender;

  const ChooseAvatarsScreen({
    super.key,
    required this.relationshipId,
    required this.relationshipLabel,
    required this.personName,
    this.nickname,
    this.photoPath,
    this.personGender,
  });

  @override
  State<ChooseAvatarsScreen> createState() => _ChooseAvatarsScreenState();
}

class _ChooseAvatarsScreenState extends State<ChooseAvatarsScreen> {
  late String _userAvatarId;
  late String _companionAvatarId;
  int _activeSelectorIndex = 0; // 0 = You, 1 = Companion

  @override
  void initState() {
    super.initState();
    // Default sensible avatar pairing
    _userAvatarId = 'boy_01';
    _companionAvatarId = widget.personGender == 'male' ? 'boy_02' : 'girl_01';
  }

  void _onContinue() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CreateWorldDetailsScreen(
          relationshipId: widget.relationshipId,
          relationshipLabel: widget.relationshipLabel,
          personName: widget.personName,
          nickname: widget.nickname,
          photoPath: widget.photoPath,
          personGender: widget.personGender,
          userAvatarId: _userAvatarId,
          companionAvatarId: _companionAvatarId,
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
    final isBestFriend = widget.relationshipId == 'best_friend';
    final companionDisplayName = widget.nickname?.isNotEmpty == true
        ? widget.nickname!
        : widget.personName;

    final userAvatar = AvatarDefinition.getById(_userAvatarId);
    final companionAvatar = AvatarDefinition.getById(_companionAvatarId);

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
                      'Step 3 of 5',
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
                      'A world is better with you two ♡',
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
                      'Choose how you’ll appear in your little world.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Best Friend friendship callout (strictly platonic)
                    if (isBestFriend) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.sageGreenLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.sageGreen.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const StorybookLeaf(size: 14),
                            const SizedBox(width: 8),
                            Text(
                              'Best Friends Adventure — Exploring side-by-side',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Dual Selection Preview Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.creamLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.borderSubtle,
                          width: 1.2,
                        ),
                        boxShadow: AppTheme.paperShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // User Avatar Slot
                          _buildPreviewSlot(
                            label: 'Your avatar',
                            name: 'You',
                            avatar: userAvatar,
                            isSelectedSlot: _activeSelectorIndex == 0,
                            onTap: () => setState(() => _activeSelectorIndex = 0),
                          ),

                          // Connector
                          Column(
                            children: [
                              Text(
                                isBestFriend ? '★' : '♡',
                                style: GoogleFonts.mali(
                                  fontSize: 18,
                                  color: isBestFriend
                                      ? AppTheme.sageGreen
                                      : AppTheme.primaryPink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '&',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          // Companion Avatar Slot
                          _buildPreviewSlot(
                            label: "Their avatar",
                            name: companionDisplayName,
                            avatar: companionAvatar,
                            isSelectedSlot: _activeSelectorIndex == 1,
                            onTap: () => setState(() => _activeSelectorIndex = 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Selector Tab Header
                    Row(
                      children: [
                        Expanded(
                          child: _buildSelectorTabButton(
                            title: 'Your avatar',
                            isActive: _activeSelectorIndex == 0,
                            onTap: () => setState(() => _activeSelectorIndex = 0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildSelectorTabButton(
                            title: "$companionDisplayName's avatar",
                            isActive: _activeSelectorIndex == 1,
                            onTap: () => setState(() => _activeSelectorIndex = 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Avatar Palette Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: AvatarDefinition.all.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.82,
                      ),
                      itemBuilder: (context, index) {
                        final avatar = AvatarDefinition.all[index];
                        final isSelected = _activeSelectorIndex == 0
                            ? _userAvatarId == avatar.id
                            : _companionAvatarId == avatar.id;

                        return StorybookAvatarWidget(
                          avatar: avatar,
                          isSelected: isSelected,
                          size: 68,
                          subtitle: avatar.gender == 'female' ? 'Girl' : 'Boy',
                          onTap: () {
                            setState(() {
                              if (_activeSelectorIndex == 0) {
                                _userAvatarId = avatar.id;
                              } else {
                                _companionAvatarId = avatar.id;
                              }
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Continue Tactile Button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
              child: SizedBox(
                width: double.infinity,
                child: TactilePillButton(
                  onPressed: _onContinue,
                  text: 'Continue to World Name ♡',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSlot({
    required String label,
    required String name,
    required AvatarDefinition avatar,
    required bool isSelectedSlot,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelectedSlot
              ? AppTheme.primaryPinkLight.withValues(alpha: 0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelectedSlot
                ? AppTheme.primaryPink
                : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelectedSlot
                    ? AppTheme.primaryPinkDark
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            StorybookAvatarWidget(
              avatar: avatar,
              isSelected: isSelectedSlot,
              size: 58,
              showLabel: false,
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: GoogleFonts.mali(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryPink : AppTheme.creamLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppTheme.primaryPink : AppTheme.borderSubtle,
            width: 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPink.withValues(alpha: 0.22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : AppTheme.paperShadow,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
