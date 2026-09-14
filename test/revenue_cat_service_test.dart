import 'package:flutter_test/flutter_test.dart';
import 'package:mimory/models/mimory_plus_capability.dart';
import 'package:mimory/services/revenue_cat_config.dart';
import 'package:mimory/services/revenue_cat_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RevenueCat Configuration Tests', () {
    test('Entitlement constant matches mimory_plus', () {
      expect(RevenueCatConfig.entitlementMimoryPlus, equals('mimory_plus'));
    });

    test('isConfigured accurately detects configured key', () {
      expect(RevenueCatConfig.isConfigured, isTrue);
      expect(RevenueCatConfig.apiKey, equals('test_aToLAmiQXjnnqPxxxISoWwxRVAK'));
    });
  });

  group('RevenueCat Service Tests', () {
    test('RevenueCatService singleton instance is consistent', () {
      final s1 = RevenueCatService();
      final s2 = RevenueCatService();
      expect(identical(s1, s2), isTrue);
    });

    test('isMimoryPlusActive returns false by default without active entitlement', () {
      final service = RevenueCatService();
      expect(service.isMimoryPlusActive(), isFalse);
      expect(service.isPremium, isFalse);
      expect(service.currentPurchaseType, equals(MimoryPurchaseType.unknown));
    });
  });

  group('MIMORY+ Truthful Capability Model Tests', () {
    test('Only implemented capabilities are present in unlockedForPlus', () {
      final unlocked = MimoryPlusCapability.unlockedForPlus;
      expect(unlocked.isNotEmpty, isTrue);

      // Verify all unlocked features have implemented == true
      for (final cap in unlocked) {
        expect(cap.implemented, isTrue);
        expect(cap.availableForPlus, isTrue);
      }

      // Verify roadmap feature (memory_echoes) is NOT in unlockedForPlus
      final hasEchoes = unlocked.any((c) => c.id == 'memory_echoes');
      expect(hasEchoes, isFalse);

      // Verify genuinely implemented features are included
      final hasWorlds = unlocked.any((c) => c.id == 'premium_worlds');
      final hasEnvironments = unlocked.any((c) => c.id == 'living_environments');
      expect(hasWorlds, isTrue);
      expect(hasEnvironments, isTrue);
    });
  });
}
