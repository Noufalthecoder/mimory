import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:mimory/models/mimory_plus_capability.dart';
import 'package:mimory/services/revenue_cat_service.dart';
import 'package:mimory/services/revenue_cat_config.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/features/monetization/widgets/miniature_living_world_hero.dart';
import 'package:mimory/features/monetization/widgets/storybook_capability_card.dart';
import 'package:mimory/features/monetization/widgets/storybook_decorations.dart';
import 'package:mimory/core/widgets/tactile_pill_button.dart';
import 'package:mimory/features/monetization/screens/mimory_plus_celebration_screen.dart';

/// Storybook-themed MIMORY+ Premium Paywall.
///
/// Presents live packages from RevenueCat and unlocks the 'mimory_plus' entitlement.
/// If the user is already MIMORY+, displays active capabilities and management options
/// instead of the purchase interface.
class MimoryPlusPaywall extends StatefulWidget {
  final String? featureSource;

  const MimoryPlusPaywall({
    super.key,
    this.featureSource,
  });

  /// Static helper to present the paywall as a smooth route
  static Future<bool> show(BuildContext context, {String? featureSource}) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MimoryPlusPaywall(featureSource: featureSource),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
    return result ?? false;
  }

  @override
  State<MimoryPlusPaywall> createState() => _MimoryPlusPaywallState();
}

class _MimoryPlusPaywallState extends State<MimoryPlusPaywall> {
  final RevenueCatService _revenueCat = RevenueCatService();
  Package? _selectedPackage;
  bool _isProcessing = false;
  String? _statusNotice;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    if (_revenueCat.offerings == null) {
      await _revenueCat.getOfferings();
    }
    _autoSelectDefaultPackage();
    if (mounted) setState(() {});
  }

  void _autoSelectDefaultPackage() {
    final availablePackages = _getAvailablePackages();
    if (availablePackages.isNotEmpty && _selectedPackage == null) {
      // Prioritize annual if available, otherwise first package
      _selectedPackage = availablePackages.firstWhere(
        (pkg) => pkg.packageType == PackageType.annual,
        orElse: () => availablePackages.first,
      );
    }
  }

  List<Package> _getAvailablePackages() {
    final currentOffering = _revenueCat.offerings?.current ??
        _revenueCat.offerings?.getOffering(RevenueCatConfig.defaultOffering);
    return currentOffering?.availablePackages ?? [];
  }

  Future<void> _handlePurchase() async {
    if (_selectedPackage == null) return;

    setState(() {
      _isProcessing = true;
      _statusNotice = null;
    });

    final result = await _revenueCat.purchasePackage(_selectedPackage!);

    if (!mounted) return;

    setState(() => _isProcessing = false);

    switch (result.status) {
      case MimoryPurchaseStatus.success:
        if (_revenueCat.isMimoryPlusActive()) {
          // Open emotional storybook celebration
          await MimoryPlusCelebrationScreen.show(
            context,
            purchasedPackage: _selectedPackage,
          );
          if (mounted) {
            Navigator.pop(context, true); // Dismiss paywall
          }
        }
        break;
      case MimoryPurchaseStatus.cancelled:
        // Quietly return to paywall without false error dialogs
        break;
      case MimoryPurchaseStatus.error:
        setState(() {
          _statusNotice = result.errorMessage ?? 'Purchase could not be completed.';
        });
        break;
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isProcessing = true;
      _statusNotice = null;
    });

    final result = await _revenueCat.restorePurchases();

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (result.status == MimoryPurchaseStatus.success && _revenueCat.isPremium) {
      await MimoryPlusCelebrationScreen.show(
        context,
        isRestore: true,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      setState(() {
        _statusNotice = 'No active MIMORY+ subscription found on this account.';
      });
    }
  }

  void _showSubscriptionManagementModal() {
    final purchaseType = _revenueCat.currentPurchaseType;
    final typeLabel = purchaseType == MimoryPurchaseType.lifetime
        ? 'Lifetime Access'
        : purchaseType == MimoryPurchaseType.yearly
            ? 'Yearly Subscription'
            : purchaseType == MimoryPurchaseType.monthly
                ? 'Monthly Subscription'
                : 'MIMORY+ Entitlement';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: AppTheme.creamLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
            boxShadow: AppTheme.paperShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StorybookLeaf(size: 20),
              const SizedBox(height: 12),
              Text(
                'Manage Subscription',
                style: GoogleFonts.mali(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your current plan: $typeLabel',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPinkDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Subscriptions are managed directly through your Google Play Store or App Store account settings. You can renew, cancel, or change your billing at any time.',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TactilePillButton(
                text: 'Done',
                backgroundColor: AppTheme.primaryPink,
                foregroundColor: Colors.white,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAlreadyPremium = _revenueCat.isPremium;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: isAlreadyPremium
                  ? _buildAlreadyPremiumContent()
                  : _buildPaywallPurchaseContent(),
            ),

            // Top Close Button
            Positioned(
              top: 10,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.creamLight.withValues(alpha: 0.90),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 12: Content displayed when the user is already subscribed to MIMORY+
  Widget _buildAlreadyPremiumContent() {
    final unlockedCapabilities = MimoryPlusCapability.unlockedForPlus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),

        // Storybook Heart Emblem
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.creamLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryPink.withValues(alpha: 0.35),
                width: 1.6,
              ),
              boxShadow: AppTheme.paperShadow,
            ),
            child: const Center(
              child: StorybookSparkle(size: 28),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MIMORY+',
              style: GoogleFonts.mali(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '♡',
              style: GoogleFonts.mali(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Your little worlds are growing beautifully.',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // Miniature Living World Hero
        const MiniatureLivingWorldHero(),

        const SizedBox(height: 24),

        // Section Title: Your MIMORY+ features
        Row(
          children: [
            const StorybookLeaf(size: 16, angle: 0.2),
            const SizedBox(width: 8),
            Text(
              'Your MIMORY+ features',
              style: GoogleFonts.mali(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryPink.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'UNLOCKED ♡',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryPink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // List of Truly Unlocked Capabilities
        ...unlockedCapabilities.map((cap) {
          return StorybookCapabilityCard(capability: cap);
        }),

        const SizedBox(height: 20),

        // Continue Button
        SizedBox(
          width: double.infinity,
          child: TactilePillButton(
            text: 'Back to my world →',
            backgroundColor: AppTheme.primaryPink,
            foregroundColor: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ),

        const SizedBox(height: 12),

        // Manage Subscription Button
        SizedBox(
          width: double.infinity,
          child: TactilePillButton(
            text: 'Manage subscription',
            backgroundColor: AppTheme.creamLight,
            foregroundColor: AppTheme.textPrimary,
            onPressed: _showSubscriptionManagementModal,
          ),
        ),

        const SizedBox(height: 12),

        // Restore Purchases link
        TextButton(
          onPressed: _isProcessing ? null : _handleRestore,
          child: Text(
            'Restore Purchases',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// The standard purchase paywall content
  Widget _buildPaywallPurchaseContent() {
    final availablePackages = _getAvailablePackages();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),

        // Decorative Storybook Emblem
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppTheme.creamLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryPink.withValues(alpha: 0.35),
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPink.withValues(alpha: 0.18),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                ...AppTheme.paperShadow,
              ],
            ),
            child: const Center(
              child: Text(
                '✨',
                style: TextStyle(fontSize: 34),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Header Copy
        Text(
          'Preserve every moment.',
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // Title Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MIMORY+',
              style: GoogleFonts.mali(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '♡',
              style: GoogleFonts.mali(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Feature List Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
              _buildFeatureItem(
                icon: Icons.all_inclusive_rounded,
                title: 'Unlimited memories',
                subtitle: 'Capture every little date, photo, and voice note.',
              ),
              _buildDivider(),
              _buildFeatureItem(
                icon: Icons.auto_awesome_rounded,
                title: 'AI-powered memory organization',
                subtitle: 'Smart storybook indexing and timeline weaving.',
              ),
              _buildDivider(),
              _buildFeatureItem(
                icon: Icons.cottage_rounded,
                title: 'Premium memory worlds',
                subtitle: 'Create multiple unique worlds for everyone you love.',
              ),
              _buildDivider(),
              _buildFeatureItem(
                icon: Icons.cloudy_snowing,
                title: 'Advanced living environments',
                subtitle: 'Rain with shared umbrellas, snow, sunsets & starlit forests.',
              ),
              _buildDivider(),
              _buildFeatureItem(
                icon: Icons.record_voice_over_rounded,
                title: 'Memory Echoes',
                subtitle: 'Revisit auditory memories through ambient wind chimes.',
              ),
              _buildDivider(),
              _buildFeatureItem(
                icon: Icons.favorite_rounded,
                title: 'More ways to rediscover the people and moments that matter',
                subtitle: 'Hand-holding walks, animal companions, and keepsakes.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Status Notice (if any error or restore status)
        if (_statusNotice != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF197A2)),
            ),
            child: Text(
              _statusNotice!,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFB33939),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Live Packages from RevenueCat
        if (_revenueCat.isLoading && availablePackages.isEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: AppTheme.primaryPink),
          ),
        ] else if (availablePackages.isNotEmpty) ...[
          // Render live dynamic packages (Monthly, Annual, Lifetime)
          ...availablePackages.map((pkg) {
            final isSelected = _selectedPackage == pkg;
            return _buildPackageCard(pkg, isSelected);
          }),
          const SizedBox(height: 18),

          // Main Purchase Button with Live Package Title
          SizedBox(
            width: double.infinity,
            child: TactilePillButton(
              text: _isProcessing
                  ? 'Connecting to RevenueCat...'
                  : 'Continue with ${_selectedPackage?.storeProduct.title ?? 'MIMORY+'} ♡',
              onPressed: _isProcessing ? null : _handlePurchase,
            ),
          ),
        ] else ...[
          // No live packages returned
          _buildTestStoreSetupCard(),
        ],

        const SizedBox(height: 16),

        // Restore Purchases Button
        TextButton(
          onPressed: _isProcessing ? null : _handleRestore,
          child: Text(
            'Restore Purchases',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Storybook Terms & Note
        Text(
          'Cancel anytime in your store settings. Purchases directly support\nhandmade, loving storybook world development ♡',
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: AppTheme.textTertiary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryPink, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Divider(
        color: AppTheme.borderSubtle.withValues(alpha: 0.6),
        height: 1,
      ),
    );
  }

  Widget _buildPackageCard(Package package, bool isSelected) {
    final product = package.storeProduct;
    final isLifetime = package.packageType == PackageType.lifetime ||
        package.identifier.toLowerCase().contains('lifetime') ||
        product.identifier.toLowerCase().contains('lifetime');
    final isAnnual = !isLifetime &&
        (package.packageType == PackageType.annual ||
            package.identifier.toLowerCase().contains('year') ||
            package.identifier.toLowerCase().contains('annual'));

    // Section 7 & 8: Lifetime must say 'Full access forever', NEVER 'monthly'
    final String fallbackDesc = isLifetime
        ? 'Full access forever'
        : (isAnnual ? 'Full access for 1 year' : 'Full access monthly');

    String subtitle = product.description.isNotEmpty
        ? product.description
        : fallbackDesc;
    if (isLifetime && subtitle.toLowerCase().contains('month')) {
      subtitle = 'Full access forever';
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = package;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppTheme.creamLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPink : AppTheme.borderSubtle,
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryPink.withValues(alpha: 0.20),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : AppTheme.paperShadow,
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryPink : AppTheme.textTertiary,
                  width: 2.0,
                ),
                color: isSelected ? AppTheme.primaryPink : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),

            // Package Name & Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          product.title.isNotEmpty ? product.title : 'MIMORY+ Plan',
                          style: GoogleFonts.mali(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAnnual || isLifetime) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isLifetime ? AppTheme.sageGreen : AppTheme.primaryPink,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isLifetime ? 'FOREVER ♡' : 'BEST VALUE ♡',
                            style: GoogleFonts.nunito(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Actual Product Price from RevenueCat
            Text(
              product.priceString,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Informative card when RevenueCat Test Store / offerings are waiting to be configured
  Widget _buildTestStoreSetupCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2CDBA), width: 1.2),
      ),
      child: Column(
        children: [
          const Icon(Icons.storefront_rounded,
              color: AppTheme.primaryPink, size: 28),
          const SizedBox(height: 8),
          Text(
            'RevenueCat Offerings Loading',
            style: GoogleFonts.mali(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ensure the "default" offering with monthly, yearly, or lifetime packages is attached in your RevenueCat Product Catalog.',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
