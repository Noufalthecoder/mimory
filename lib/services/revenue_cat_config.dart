import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Configuration for RevenueCat integration in MIMORY.
///
/// ============================================================================
/// IMPORTANT SECURITY NOTICE:
/// NEVER place your RevenueCat Secret API key (starts with "sk_") in client code!
/// Only configure your PUBLIC SDK API keys here:
/// - Android / Google Play / Test Store: starts with "goog_"
/// - iOS / App Store / Test Store: starts with "appl_"
/// - RevenueCat Test Store: generated under Project Settings -> API Keys
/// ============================================================================
///
/// REVENUECAT SHIPATON / STUDENT / NEXT GEN SETUP INSTRUCTIONS:
/// 1. Create an account at https://app.revenuecat.com
/// 2. Create a new project called "MIMORY".
/// 3. Go to Project Settings -> API Keys.
/// 4. Copy your Public app-specific API key for your platform and paste below:
///    - For Android: replace [apiKeyAndroid] with your public key (e.g., 'goog_...')
///    - For iOS: replace [apiKeyIOS] with your public key (e.g., 'appl_...')
/// 5. Under Product Catalog -> Entitlements:
///    - Create an Entitlement with Identifier: "mimory_plus"
/// 6. Under Product Catalog -> Products:
///    - Create your subscription products (e.g. Monthly, Annual)
///    - Attach the product to the "mimory_plus" entitlement.
/// 7. Under Product Catalog -> Offerings:
///    - Create a default offering with identifier "default".
///    - Attach your packages ($rc_monthly, $rc_annual, or custom packages).
/// 8. RevenueCat Test Store:
///    - For the Student / Next Gen path, you DO NOT need live App Store / Google Play
///      merchant credentials. Test Store allows safe simulation of purchases
///      using test cards and sandbox environments.
class RevenueCatConfig {
  /// The official entitlement identifier required to unlock MIMORY+
  static const String entitlementMimoryPlus = 'mimory_plus';

  /// Default offering identifier
  static const String defaultOffering = 'default';

  /// RevenueCat Test Store public SDK key (for development & test environments)
  static const String apiKeyTestStore = 'test_aToLAmiQXjnnqPxxxISoWwxRVAK';

  /// Production Android Public SDK key (starts with "goog_")
  /// Can be set here or injected at build time via:
  /// `--dart-define=REVENUECAT_ANDROID_KEY=goog_...`
  static const String apiKeyAndroidProduction = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
    defaultValue: '',
  );

  /// Production iOS Public SDK key (starts with "appl_")
  /// Can be set here or injected at build time via:
  /// `--dart-define=REVENUECAT_IOS_KEY=appl_...`
  static const String apiKeyIOSProduction = String.fromEnvironment(
    'REVENUECAT_IOS_KEY',
    defaultValue: '',
  );

  /// Returns the appropriate public SDK key for the current platform and build mode.
  ///
  /// In RELEASE mode:
  /// - Android uses [apiKeyAndroidProduction]. Test Store keys are NEVER used in release
  ///   to prevent RevenueCat native security popups and process termination.
  /// - iOS uses [apiKeyIOSProduction].
  ///
  /// In DEBUG / DEVELOPMENT mode:
  /// - Falls back to [apiKeyTestStore] for sandbox testing and unit test suites.
  static String get apiKey {
    if (kReleaseMode) {
      if (Platform.isIOS || Platform.isMacOS) {
        return apiKeyIOSProduction;
      }
      return apiKeyAndroidProduction;
    }

    // Development / Test mode
    if (Platform.isIOS || Platform.isMacOS) {
      return apiKeyIOSProduction.isNotEmpty ? apiKeyIOSProduction : apiKeyTestStore;
    }
    return apiKeyAndroidProduction.isNotEmpty ? apiKeyAndroidProduction : apiKeyTestStore;
  }

  /// Checks if the configured API key is valid for the current runtime mode
  static bool get isConfigured {
    final key = apiKey;
    if (key.isEmpty) return false;

    if (kReleaseMode) {
      // Release builds must use official store public SDK keys (goog_ or appl_).
      // Test store keys (test_) are strictly disallowed in release mode.
      return key.startsWith('goog_') || key.startsWith('appl_');
    }

    // Development / Test builds allow test store keys as well
    return key.startsWith('goog_') ||
        key.startsWith('appl_') ||
        key.startsWith('rc_') ||
        key.startsWith('test_');
  }
}
