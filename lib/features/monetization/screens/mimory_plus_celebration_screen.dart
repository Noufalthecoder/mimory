import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:mimory/models/mimory_plus_capability.dart';
import 'package:mimory/services/revenue_cat_service.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/miniature_living_world_hero.dart';
import 'package:mimory/features/monetization/widgets/storybook_capability_card.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';

/// Post-purchase celebration experience for MIMORY+.
///
/// Designed not as a transactional receipt, but as an intimate, emotional
/// continuation of the user's living storybook world.
///
/// Strictly gated by [RevenueCatService.isMimoryPlusActive]. If the entitlement
/// is not verified active, the screen quietly dismisses to avoid false claims.
class MimoryPlusCelebrationScreen extends StatefulWidget {
  final bool isRestore;
  final Package? purchasedPackage;

  const MimoryPlusCelebrationScreen({
    super.key,
    this.isRestore = false,
    this.purchasedPackage,
  });

  /// Presents the celebration screen as a smooth, immersive page transition
  static Future<void> show(
    BuildContext context, {
    bool isRestore = false,
    Package? purchasedPackage,
  }) async {
    // Strictly verify entitlement before navigating
    if (!RevenueCatService().isMimoryPlusActive()) {
      return;
    }

    await Navigator.push<void>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MimoryPlusCelebrationScreen(
          isRestore: isRestore,
          purchasedPackage: purchasedPackage,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  State<MimoryPlusCelebrationScreen> createState() =>
      _MimoryPlusCelebrationScreenState();
}

class _MimoryPlusCelebrationScreenState
    extends State<MimoryPlusCelebrationScreen> {
  final RevenueCatService _revenueCat = RevenueCatService();
  bool _showFeatures = false;

  @override
  void initState() {
    super.initState();
    // Safety check: Never remain open if entitlement is not active
    if (!_revenueCat.isMimoryPlusActive()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }

    // Gracefully fade in features after the living world hero blooms
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => _showFeatures = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_revenueCat.isMimoryPlusActive()) {
      return const Scaffold(backgroundColor: AppTheme.backgroundColor);
    }

    final purchaseType = _revenueCat.currentPurchaseType;
    final isLifetime = purchaseType == MimoryPurchaseType.lifetime ||
        (widget.purchasedPackage?.packageType == PackageType.lifetime);
    final isYearly = purchaseType == MimoryPurchaseType.yearly ||
        (widget.purchasedPackage?.packageType == PackageType.annual);

    // Dynamic copy based on purchase awareness
    final String heroTitle = widget.isRestore
        ? 'Your story found its way back. ♡'
        : 'Your little world just grew. ♡';

    final String heroSubtitle = widget.isRestore
        ? 'MIMORY+ is restored.'
        : isLifetime
            ? 'MIMORY+ is yours forever.'
            : isYearly
                ? 'Your year of MIMORY+ has begun. ♡'
                : 'MIMORY+ is now yours.';

    final String supportingCopy = widget.isRestore
        ? 'More of your story is ready to grow.'
        : isLifetime
            ? 'Every memory you keep can become part of your world.'
            : 'More of your story is ready to grow.';

    final unlockedFeatures = MimoryPlusCapability.unlockedForPlus;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // Decorative Top Leaf
              const Center(child: StorybookLeaf(size: 20, angle: 0.1)),
              const SizedBox(height: 12),

              // 1. Living World Hero Illustration (Shows User & Companion characters)
              const MiniatureLivingWorldHero(),

              const SizedBox(height: 20),

              // 2. Emotional Storybook Typography
              Text(
                heroTitle,
                style: GoogleFonts.mali(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                heroSubtitle,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryPinkDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                supportingCopy,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              if (isLifetime) ...[
                const SizedBox(height: 4),
                Text(
                  'Keep growing your little worlds forever.',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.sageGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 24),

              // 3. Unlocked For You Section Header
              AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _showFeatures ? 1.0 : 0.0,
                child: Row(
                  children: [
                    const StorybookFlower(size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocked for you',
                      style: GoogleFonts.mali(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPink.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ACTIVE ♡',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryPink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Illustrated Storybook Capability Cards (Only Implemented Features)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _showFeatures ? 1.0 : 0.0,
                child: Column(
                  children: unlockedFeatures.map((cap) {
                    return StorybookCapabilityCard(capability: cap);
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // 5. Primary Tactile Pill Button
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showFeatures ? 1.0 : 0.0,
                child: SizedBox(
                  width: double.infinity,
                  child: TactilePillButton(
                    text: 'Continue exploring →',
                    backgroundColor: AppTheme.primaryPink,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context); // Dismiss celebration
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
