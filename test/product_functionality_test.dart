import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/services/world_service.dart';
import 'package:mimory/services/storage_service.dart';
import 'package:mimory/features/auth/screens/welcome_screen.dart';
import 'package:mimory/features/world/screens/your_worlds_screen.dart';
import 'package:mimory/features/world/screens/world_screen.dart';
import 'package:mimory/widgets/couple_character_pair_widget.dart';
import 'package:mimory/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await WorldService().clearAllDataForTesting();
  });

  group('MIMORY Product Functionality Tests', () {
    // 1. Avatar selection is saved
    test('1. Avatar selection is saved with stable identifiers', () async {
      final world = await WorldService().createWorld(
        name: 'Our Little Chaos',
        relationshipType: 'best_friend',
        personName: 'Ayaan',
        userAvatarId: 'boy_02',
        companionAvatarId: 'girl_02',
        worldStyle: 'cozy_town',
      );

      expect(world.userAvatarId, equals('boy_02'));
      expect(world.companionAvatarId, equals('girl_02'));
      expect(world.worldStyle, equals('cozy_town'));

      final characters = WorldService().getCharactersForWorld(world.id);
      expect(characters.length, equals(2));

      final userChar = characters.firstWhere((c) => c.isCurrentUser);
      final compChar = characters.firstWhere((c) => !c.isCurrentUser);

      // boy_02 is Haru (side_part)
      expect(userChar.hairStyle, equals('side_part'));
      // girl_02 is Aoi (wavy_bob)
      expect(compChar.hairStyle, equals('wavy_bob'));
      expect(compChar.personName, equals('Ayaan'));
    });

    // 2. World persists
    test('2. World persists to local storage across restarts', () async {
      final createdWorld = await WorldService().createWorld(
        name: 'Cozy Haven',
        relationshipType: 'partner',
        personName: 'Maya',
        userAvatarId: 'boy_01',
        companionAvatarId: 'girl_01',
        worldStyle: 'blooming_meadow',
      );

      // Verify loaded from StorageService
      final persistedWorlds = await StorageService().loadWorlds();
      expect(persistedWorlds.length, equals(1));
      expect(persistedWorlds.first.id, equals(createdWorld.id));
      expect(persistedWorlds.first.name, equals('Cozy Haven'));
      expect(persistedWorlds.first.userAvatarId, equals('boy_01'));
      expect(persistedWorlds.first.companionAvatarId, equals('girl_01'));
      expect(persistedWorlds.first.worldStyle, equals('blooming_meadow'));
    });

    // 3. Memory persists
    test('3. Memory persists to local storage', () async {
      final world = await WorldService().createWorld(
        name: 'Memory World',
        relationshipType: 'best_friend',
        personName: 'Ayaan',
      );

      final memory = await WorldService().createMemory(
        worldId: world.id,
        type: MemoryType.story,
        title: 'First Stargazing Night',
        description: 'We sat on the hillside watching shooting stars.',
        memoryDate: DateTime(2026, 6, 15),
      );

      final persistedMemories = await StorageService().loadMemories();
      expect(persistedMemories.length, equals(1));
      expect(persistedMemories.first.id, equals(memory.id));
      expect(persistedMemories.first.title, equals('First Stargazing Night'));
      expect(persistedMemories.first.worldId, equals(world.id));
    });

    // 4. Memory belongs to correct world
    test('4. Memory strictly belongs to correct world and never leaks to another world', () async {
      final worldA = await WorldService().createWorld(
        name: 'World Alpha',
        relationshipType: 'best_friend',
        personName: 'Friend A',
      );

      final worldB = await WorldService().createWorld(
        name: 'World Beta',
        relationshipType: 'partner',
        personName: 'Partner B',
      );

      final memA = await WorldService().createMemory(
        worldId: worldA.id,
        type: MemoryType.story,
        title: 'Secret Treehouse',
        description: 'Only in World Alpha',
        memoryDate: DateTime.now(),
      );

      final memB = await WorldService().createMemory(
        worldId: worldB.id,
        type: MemoryType.photo,
        title: 'Sunset Beach Walk',
        description: 'Only in World Beta',
        memoryDate: DateTime.now(),
      );

      final worldAMemories = WorldService().getMemoriesForWorld(worldA.id);
      final worldBMemories = WorldService().getMemoriesForWorld(worldB.id);

      expect(worldAMemories.map((m) => m.id), contains(memA.id));
      expect(worldAMemories.map((m) => m.id), isNot(contains(memB.id)));

      expect(worldBMemories.map((m) => m.id), contains(memB.id));
      expect(worldBMemories.map((m) => m.id), isNot(contains(memA.id)));
    });

    // 5. Session persists
    test('5. Session persists across simulated app launches', () async {
      expect(WorldService().isLoggedIn, isFalse);

      final session = await WorldService().loginWithGoogle();
      expect(session.id, equals('mock_user_001'));
      expect(WorldService().isLoggedIn, isTrue);

      final loadedSession = await StorageService().loadSession();
      expect(loadedSession, isNotNull);
      expect(loadedSession!.isLoggedIn, isTrue);
      expect(loadedSession.displayName, equals('Noufal'));
      expect(loadedSession.email, equals('noufal@mimory.app'));
    });

    // 6. Logout clears session but NOT content
    test('6. Logout clears session but retains all worlds and memories', () async {
      await WorldService().loginWithGoogle();
      final world = await WorldService().createWorld(
        name: 'Keepsake World',
        relationshipType: 'family',
        personName: 'Sister',
      );
      await WorldService().createMemory(
        worldId: world.id,
        type: MemoryType.story,
        title: 'Baking cookies',
        description: 'Warm chocolate chips',
        memoryDate: DateTime.now(),
      );

      // User logs out
      await WorldService().logout();

      // Session must be cleared
      expect(WorldService().isLoggedIn, isFalse);
      expect(WorldService().session, isNull);
      final persistedSession = await StorageService().loadSession();
      expect(persistedSession, isNull);

      // Content MUST remain intact
      expect(WorldService().worlds.length, equals(1));
      expect(WorldService().memories.length, equals(1));

      final persistedWorlds = await StorageService().loadWorlds();
      final persistedMemories = await StorageService().loadMemories();
      expect(persistedWorlds.length, equals(1));
      expect(persistedMemories.length, equals(1));
      expect(persistedWorlds.first.id, equals(world.id));

      // Re-login restores access to existing worlds
      await WorldService().loginWithGoogle();
      expect(WorldService().isLoggedIn, isTrue);
      expect(WorldService().worlds.length, equals(1));
    });

    // 7. App startup routes correctly
    testWidgets('7. App startup routes correctly based on session state',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Case A: Not logged in -> WelcomeScreen
      await tester.pumpWidget(const MimoryApp());
      await tester.pump();
      expect(find.byType(WelcomeScreen), findsOneWidget);

      // Case B: Logged in -> YourWorldsScreen
      await WorldService().loginWithGoogle();
      await tester.pumpWidget(const MimoryApp());
      await tester.pump();
      expect(find.byType(YourWorldsScreen), findsOneWidget);
    });

    // 8. Selected avatars render from World data
    testWidgets('8. Selected avatars render from World data in Living World',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final world = await WorldService().createWorld(
        name: 'Our Little Chaos',
        relationshipType: 'best_friend',
        personName: 'Ayaan',
        userAvatarId: 'boy_02',
        companionAvatarId: 'girl_01',
        worldStyle: 'cozy_town',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WorldScreen(world: world),
        ),
      );
      await tester.pump();

      // CoupleCharacterPairWidget must mount with platonic setting for best_friend
      final pairFinder = find.byType(CoupleCharacterPairWidget);
      expect(pairFinder, findsOneWidget);

      final pairWidget = tester.widget<CoupleCharacterPairWidget>(pairFinder);
      expect(pairWidget.userCharacter.hairStyle, equals('side_part'));
      expect(pairWidget.companionCharacter.hairStyle, equals('twin_tails'));
      expect(pairWidget.isPlatonic, isTrue);
    });
  });
}
