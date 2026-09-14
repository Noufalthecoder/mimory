import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:mimory/services/revenue_cat_config.dart';

import 'package:mimory/models/mimory_plus_capability.dart';

/// Result status for purchase attempts
enum MimoryPurchaseStatus {
  success,
  cancelled,
  error,
}

/// A wrapper for the purchase operation result
class MimoryPurchaseResult {
  final MimoryPurchaseStatus status;
  final CustomerInfo? customerInfo;
  final String? errorMessage;

  const MimoryPurchaseResult({
    required this.status,
    this.customerInfo,
    this.errorMessage,
  });
}

/// Dedicated service managing RevenueCat initialization, customer info,
/// offerings, and purchase lifecycle for MIMORY+.
///
/// Extends [ChangeNotifier] to provide reactive premium state across the app
/// without requiring direct RevenueCat calls in UI widgets.
class RevenueCatService extends ChangeNotifier {
  // Singleton pattern
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;
  bool _isLoading = false;
  CustomerInfo? _customerInfo;
  Offerings? _offerings;
  String? _errorMessage;
  Package? _latestPurchasedPackage;

  // --- Getters ---

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  CustomerInfo? get customerInfo => _customerInfo;
  Offerings? get offerings => _offerings;
  String? get errorMessage => _errorMessage;
  Package? get latestPurchasedPackage => _latestPurchasedPackage;

  /// Returns true if the user currently holds an active 'mimory_plus' entitlement.
  /// This strictly evaluates RevenueCat's verified customer info without fake flags.
  bool get isPremium => isMimoryPlusActive();

  /// Check whether 'mimory_plus' entitlement is active
  bool isMimoryPlusActive() {
    if (_customerInfo == null) return false;
    final entitlement =
        _customerInfo!.entitlements.all[RevenueCatConfig.entitlementMimoryPlus];
    return entitlement?.isActive ?? false;
  }

  /// Detects whether the active purchase is monthly, yearly, or lifetime
  MimoryPurchaseType get currentPurchaseType {
    if (!isMimoryPlusActive()) return MimoryPurchaseType.unknown;

    // First check latest purchased package if available
    if (_latestPurchasedPackage != null) {
      final type = _latestPurchasedPackage!.packageType;
      final id = _latestPurchasedPackage!.identifier.toLowerCase();
      final prodId = _latestPurchasedPackage!.storeProduct.identifier.toLowerCase();

      if (type == PackageType.lifetime ||
          id.contains('lifetime') ||
          prodId.contains('lifetime')) {
        return MimoryPurchaseType.lifetime;
      }
      if (type == PackageType.annual ||
          id.contains('year') ||
          id.contains('annual') ||
          prodId.contains('year') ||
          prodId.contains('annual')) {
        return MimoryPurchaseType.yearly;
      }
      if (type == PackageType.monthly ||
          id.contains('month') ||
          prodId.contains('month')) {
        return MimoryPurchaseType.monthly;
      }
    }

    // Inspect RevenueCat CustomerInfo entitlement details
    final entitlement =
        _customerInfo?.entitlements.all[RevenueCatConfig.entitlementMimoryPlus];
    final prodId = entitlement?.productIdentifier.toLowerCase() ?? '';

    if (prodId.contains('lifetime')) {
      return MimoryPurchaseType.lifetime;
    }
    if (prodId.contains('year') || prodId.contains('annual')) {
      return MimoryPurchaseType.yearly;
    }
    if (prodId.contains('month')) {
      return MimoryPurchaseType.monthly;
    }

    return MimoryPurchaseType.unknown;
  }

  /// Initializes RevenueCat exactly once on app startup.
  /// If [appUserId] is provided, associates the session with RevenueCat.
  Future<void> init({String? appUserId}) async {
    if (_isInitialized) return;

    // Safety check for mobile platform support
    if (!kIsWeb && !(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      debugPrint('[RevenueCat] Platform not supported by purchases_flutter.');
      _isInitialized = true;
      return;
    }

    // If API key is still placeholder, gracefully inform developer and avoid crash
    if (!RevenueCatConfig.isConfigured) {
      debugPrint(
        '[RevenueCat] Public SDK key not configured in lib/services/revenue_cat_config.dart.\n'
        'Please paste your public key (e.g. goog_..., appl_..., or test_...) from RevenueCat dashboard.\n'
        'App will run safely with unentitled free tier until key is set.',
      );
      _isInitialized = true;
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      final configuration = PurchasesConfiguration(RevenueCatConfig.apiKey);
      if (appUserId != null && appUserId.isNotEmpty) {
        configuration.appUserID = appUserId;
      }

      await Purchases.configure(configuration);

      _isInitialized = true;
      debugPrint('[RevenueCat] Initialized successfully with key: ${RevenueCatConfig.apiKey.substring(0, 8)}...');

      // Listen to real-time CustomerInfo updates
      Purchases.addCustomerInfoUpdateListener((info) {
        _customerInfo = info;
        notifyListeners();
      });

      // Initial fetch of CustomerInfo & Offerings
      await checkCustomerInfo();
      await getOfferings();
    } catch (e) {
      debugPrint('[RevenueCat] Initialization error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches latest CustomerInfo from RevenueCat server or cache.
  Future<CustomerInfo?> checkCustomerInfo() async {
    if (!RevenueCatConfig.isConfigured) return null;

    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _errorMessage = null;
      notifyListeners();
      return _customerInfo;
    } catch (e) {
      debugPrint('[RevenueCat] Error fetching customer info: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Fetches current Offerings from RevenueCat.
  /// Returns null if unconfigured or on network failure.
  Future<Offerings?> getOfferings() async {
    if (!RevenueCatConfig.isConfigured) return null;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _offerings = await Purchases.getOfferings();
      return _offerings;
    } catch (e) {
      debugPrint('[RevenueCat] Error fetching offerings: $e');
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchases a selected RevenueCat [Package].
  /// Handles purchase cancellation, errors, and success states safely.
  Future<MimoryPurchaseResult> purchasePackage(Package package) async {
    if (!RevenueCatConfig.isConfigured) {
      return const MimoryPurchaseResult(
        status: MimoryPurchaseStatus.error,
        errorMessage: 'RevenueCat public API key is not configured.',
      );
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _latestPurchasedPackage = package;
      final purchaseResult = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      _customerInfo = purchaseResult.customerInfo;
      notifyListeners();

      final hasPlus = isMimoryPlusActive();
      return MimoryPurchaseResult(
        status: hasPlus ? MimoryPurchaseStatus.success : MimoryPurchaseStatus.error,
        customerInfo: purchaseResult.customerInfo,
        errorMessage: hasPlus ? null : 'Entitlement not active after purchase.',
      );
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('[RevenueCat] User cancelled purchase.');
        return const MimoryPurchaseResult(status: MimoryPurchaseStatus.cancelled);
      }

      debugPrint('[RevenueCat] Purchase failed with code $errorCode: ${e.message}');
      final msg = e.message ?? 'An unexpected purchase error occurred.';
      _errorMessage = msg;
      return MimoryPurchaseResult(
        status: MimoryPurchaseStatus.error,
        errorMessage: msg,
      );
    } catch (e) {
      debugPrint('[RevenueCat] Unexpected purchase error: $e');
      final msg = e.toString();
      _errorMessage = msg;
      return MimoryPurchaseResult(
        status: MimoryPurchaseStatus.error,
        errorMessage: msg,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restores previous purchases for the current user.
  Future<MimoryPurchaseResult> restorePurchases() async {
    if (!RevenueCatConfig.isConfigured) {
      return const MimoryPurchaseResult(
        status: MimoryPurchaseStatus.error,
        errorMessage: 'RevenueCat public API key is not configured.',
      );
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final restoredInfo = await Purchases.restorePurchases();
      _customerInfo = restoredInfo;
      notifyListeners();

      return MimoryPurchaseResult(
        status: MimoryPurchaseStatus.success,
        customerInfo: restoredInfo,
      );
    } catch (e) {
      debugPrint('[RevenueCat] Error restoring purchases: $e');
      final msg = e.toString();
      _errorMessage = msg;
      return MimoryPurchaseResult(
        status: MimoryPurchaseStatus.error,
        errorMessage: msg,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Links user ID from application authentication with RevenueCat.
  Future<CustomerInfo?> logIn(String userId) async {
    if (!_isInitialized || !RevenueCatConfig.isConfigured) return null;

    try {
      final logInResult = await Purchases.logIn(userId);
      _customerInfo = logInResult.customerInfo;
      notifyListeners();
      return logInResult.customerInfo;
    } catch (e) {
      debugPrint('[RevenueCat] Error logging in user $userId: $e');
      return null;
    }
  }

  /// Unlinks current user on logout, reverting to anonymous RevenueCat ID.
  Future<CustomerInfo?> logOut() async {
    if (!_isInitialized || !RevenueCatConfig.isConfigured) return null;

    try {
      final logOutInfo = await Purchases.logOut();
      _customerInfo = logOutInfo;
      notifyListeners();
      return logOutInfo;
    } catch (e) {
      debugPrint('[RevenueCat] Error logging out: $e');
      return null;
    }
  }
}
