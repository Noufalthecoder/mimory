import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/avatar_definition.dart';
import 'package:mimory/services/world_service.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/widgets/storybook_avatar_widget.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';
import 'package:mimory/features/world/screens/relationship_selection_screen.dart';
import 'package:mimory/features/world/screens/world_screen.dart';
import 'package:mimory/features/auth/screens/welcome_screen.dart';
import 'package:mimory/services/revenue_cat_service.dart';
import 'package:mimory/features/monetization/screens/mimory_plus_paywall.dart';

/// Phase 5: Your Worlds Screen for returning users.
/// Displays all saved storybook worlds, memory counts, and avatar previews.
class YourWorldsScreen extends StatefulWidget {
  const YourWorldsScreen({super.key});

  @override
  State<YourWorldsScreen> createState() => _YourWorldsScreenState();
}

class _YourWorldsScreenState extends State<YourWorldsScreen> {
  final WorldService _worldService = WorldService();

  void _openWorld(World world) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WorldScreen(world: world),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((_) {
      // Refresh list on return to update memory counts
      if (mounted) setState(() {});
    });
  }

  void _createNewWorld() {
    final worlds = _worldService.worlds;
    // Gate creating more than 2 worlds for free tier
    if (!RevenueCatService().isPremium && worlds.length >= 2) {
      MimoryPlusPaywall.show(context, featureSource: 'unlimited_worlds').then((purchased) {
        if (purchased && mounted) {
          _navigateToCreateWorld();
        }
      });
      return;
    }

    _navigateToCreateWorld();
  }

  void _navigateToCreateWorld() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RelationshipSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _handleLogout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: AppTheme.creamLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: AppTheme.paperShadow,
            border: Border.all(
              color: AppTheme.borderSubtle,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Signed in as ${_worldService.currentUserName}',
                style: GoogleFonts.mali(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _worldService.currentUserEmail,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Logging out will keep all your saved worlds and memories safe on this device.',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TactilePillButton(
                  onPressed: () async {
                    Navigator.pop(sheetContext);
                    await _worldService.logout();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const WelcomeScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                      (route) => false,
                    );
                  },
                  backgroundColor: AppTheme.primaryPink,
                  foregroundColor: Colors.white,
                  text: 'Log out of MIMORY ♡',
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final worlds = _worldService.worlds;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Title / Brand
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const StorybookLeaf(size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'MIMORY',
                        style: GoogleFonts.mali(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  // Actions
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // MIMORY+ Premium Status Badge
                        ListenableBuilder(
                          listenable: RevenueCatService(),
                          builder: (context, _) {
                            final isPremium = RevenueCatService().isPremium;
                            return GestureDetector(
                              onTap: () {
                                MimoryPlusPaywall.show(context).then((_) {
                                  if (mounted) setState(() {});
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isPremium
                                      ? AppTheme.primaryPink.withValues(alpha: 0.12)
                                      : AppTheme.creamLight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isPremium
                                        ? AppTheme.primaryPink
                                        : const Color(0xFFE2CDBA),
                                    width: 1.2,
                                  ),
                                  boxShadow: AppTheme.paperShadow,
                                ),
                                child: Text(
                                  isPremium ? 'PLUS ♡' : '✦ PLUS',
                                  style: GoogleFonts.nunito(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isPremium
                                        ? AppTheme.primaryPink
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Profile & Logout Button
                        Flexible(
                          child: GestureDetector(
                            onTap: _handleLogout,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.creamLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.borderSubtle,
                                  width: 1,
                                ),
                                boxShadow: AppTheme.paperShadow,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    size: 14,
                                    color: AppTheme.primaryPinkDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      _worldService.currentUserName,
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.logout_rounded,
                                    size: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: worlds.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // Heading
                          Text(
                            'Your little worlds ♡',
                            style: GoogleFonts.mali(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Subheading
                          Text(
                            'Every one holds a different story.',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Worlds List
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: worlds.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final world = worlds[index];
                              return _buildWorldCard(world);
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),

            // Bottom "Create a new world" Action
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: SizedBox(
                width: double.infinity,
                child: TactilePillButton(
                  onPressed: _createNewWorld,
                  text: 'Create a new world ♡',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Storybook Card for a single World
  Widget _buildWorldCard(World world) {
    final memories = _worldService.getMemoriesForWorld(world.id);
    final count = memories.length;
    final countLabel = count == 0
        ? 'A waiting world'
        : count == 1
            ? '1 little moment'
            : '$count little moments';

    final userAvatar = AvatarDefinition.getById(world.userAvatarId);
    final companionAvatar = AvatarDefinition.getById(world.companionAvatarId);

    final relationshipLabel = _formatRelationship(world.relationshipType);

    return GestureDetector(
      onTap: () => _openWorld(world),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.creamLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.borderSubtle,
            width: 1.2,
          ),
          boxShadow: AppTheme.paperShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges
            Row(
              children: [
                // Relationship tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: world.relationshipType == 'best_friend'
                        ? AppTheme.sageGreenLight
                        : AppTheme.primaryPinkLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: world.relationshipType == 'best_friend'
                          ? AppTheme.sageGreen.withValues(alpha: 0.3)
                          : AppTheme.primaryPink.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    relationshipLabel,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: world.relationshipType == 'best_friend'
                          ? AppTheme.textPrimary
                          : AppTheme.primaryPinkDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // World Style tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.creamLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _formatWorldStyle(world.worldStyle),
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                const StorybookSparkle(size: 14),
              ],
            ),
            const SizedBox(height: 14),

            // World Name & Person
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              world.name,
                              style: GoogleFonts.mali(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '♡',
                            style: GoogleFonts.mali(
                              fontSize: 16,
                              color: AppTheme.primaryPink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'with ${world.personName}',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selected Avatars Preview
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StorybookAvatarWidget(
                      avatar: userAvatar,
                      size: 42,
                      showLabel: false,
                    ),
                    const SizedBox(width: 6),
                    StorybookAvatarWidget(
                      avatar: companionAvatar,
                      size: 42,
                      showLabel: false,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bottom row: Memory count and Enter arrow
            Row(
              children: [
                Icon(
                  Icons.collections_bookmark_outlined,
                  size: 14,
                  color: count > 0 ? AppTheme.sageGreen : AppTheme.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  countLabel,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color:
                        count > 0 ? AppTheme.sageGreen : AppTheme.textTertiary,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter world',
                      style: GoogleFonts.mali(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppTheme.primaryPink,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state when no worlds have been created yet
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppTheme.creamLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1.5,
                ),
                boxShadow: AppTheme.paperShadow,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.park_outlined,
                      size: 44,
                      color: AppTheme.sageGreen,
                    ),
                    const SizedBox(height: 2),
                    const StorybookFlower(size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Every world starts with one little moment.',
              style: GoogleFonts.mali(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a peaceful place for you and your favorite person.',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: (MediaQuery.of(context).size.width * 0.75).clamp(240.0, 320.0),
              child: TactilePillButton(
                onPressed: _createNewWorld,
                text: 'Create your first world ♡',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelationship(String id) {
    switch (id) {
      case 'partner':
        return 'Partner';
      case 'best_friend':
        return 'Best Friend';
      case 'family':
        return 'Family';
      case 'friend_group':
        return 'Friend Group';
      default:
        return 'Friend';
    }
  }

  String _formatWorldStyle(String style) {
    switch (style) {
      case 'cozy_town':
        return 'Cozy Town';
      case 'blooming_meadow':
        return 'Blooming Meadow';
      case 'starlit_forest':
        return 'Starlit Forest';
      case 'sunlit_valley':
        return 'Sunlit Valley';
      default:
        return 'Cozy World';
    }
  }
}
