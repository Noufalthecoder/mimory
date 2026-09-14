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

  /// RevenueCat Test Store public SDK key (Shipaton / Student / Next Gen)
  static const String apiKeyTestStore = 'test_aToLAmiQXjnnqPxxxISoWwxRVAK';

  /// Public SDK key for Android devices & emulators
  static const String apiKeyAndroid = apiKeyTestStore;

  /// Public SDK key for iOS devices & simulators
  static const String apiKeyIOS = apiKeyTestStore;

  /// Returns the appropriate public API key for the current runtime platform.
  static String get apiKey {
    if (kIsWeb) {
      return apiKeyAndroid;
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return apiKeyIOS;
    }
    return apiKeyAndroid;
  }

  /// Checks if the configured API key is valid and not a placeholder
  static bool get isConfigured {
    final key = apiKey;
    return !key.contains('REPLACE_WITH_YOUR_PUBLIC') &&
        key.isNotEmpty &&
        (key.startsWith('goog_') ||
            key.startsWith('appl_') ||
            key.startsWith('rc_') ||
            key.startsWith('test_'));
  }
}
