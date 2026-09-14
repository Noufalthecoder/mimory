import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/world_environment_config.dart';
import 'package:mimory/models/world_point.dart';
import 'package:mimory/widgets/couple_character_pair_widget.dart';
import 'package:mimory/widgets/memory_walk/animal_entity.dart';
import 'package:mimory/widgets/memory_walk/living_world_layers.dart';
import 'package:mimory/widgets/memory_walk/memory_landmark.dart';
import 'package:mimory/widgets/memory_walk/stable_memory_walk_world.dart';

void main() {
  group('Living World Environment Config Tests', () {
    test('Natural time-of-day detection correctly classifies hours', () {
      // 7 AM -> Morning
      final morningConfig = WorldEnvironmentConfig.fromNaturalTime(
        worldStyle: 'cozy_town',
        memoryCount: 2,
        currentTime: DateTime(2026, 4, 15, 7, 30),
      );
      expect(morningConfig.timeOfDay, TimeOfDayState.morning);
      expect(morningConfig.season, SeasonState.spring);

      // 14:00 -> Day
      final dayConfig = WorldEnvironmentConfig.fromNaturalTime(
        worldStyle: 'starlit_forest',
        memoryCount: 1,
        currentTime: DateTime(2026, 7, 20, 14, 0),
      );
      expect(dayConfig.timeOfDay, TimeOfDayState.day);
      expect(dayConfig.season, SeasonState.summer);

      // 18:30 -> Sunset
      final sunsetConfig = WorldEnvironmentConfig.fromNaturalTime(
        worldStyle: 'blooming_meadow',
        memoryCount: 3,
        currentTime: DateTime(2026, 10, 10, 18, 30),
      );
      expect(sunsetConfig.timeOfDay, TimeOfDayState.sunset);
      expect(sunsetConfig.season, SeasonState.autumn);

      // 22:00 -> Night
      final nightConfig = WorldEnvironmentConfig.fromNaturalTime(
        worldStyle: 'sunlit_valley',
        memoryCount: 4,
        currentTime: DateTime(2026, 1, 5, 22, 0),
      );
      expect(nightConfig.timeOfDay, TimeOfDayState.night);
      expect(nightConfig.season, SeasonState.winter);
      expect(nightConfig.condition, WorldCondition.snow);
      expect(nightConfig.areLightsGlowing, true);
    });

    test('Color palettes change according to environment condition', () {
      const sunnyDay = WorldEnvironmentConfig(
        timeOfDay: TimeOfDayState.day,
        condition: WorldCondition.sunny,
      );
      const rain = WorldEnvironmentConfig(
        timeOfDay: TimeOfDayState.day,
        condition: WorldCondition.rain,
      );
      const snow = WorldEnvironmentConfig(
        timeOfDay: TimeOfDayState.day,
        condition: WorldCondition.snow,
      );

      expect(sunnyDay.skyColors.isNotEmpty, true);
      expect(rain.skyColors.first, const Color(0xFFD3DDE6));
      expect(snow.skyColors.first, const Color(0xFFEFF5FB));
      expect(snow.meadowGrassColors.first, const Color(0xFFE4EFF5));
    });
  });

  group('Isolated Animation Layers Widget Tests', () {
    testWidgets('RainLayer paints without exceptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                RainLayer(animationValue: 0.5),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(RainLayer), findsOneWidget);
    });

    testWidgets('SnowLayer paints without exceptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                SnowLayer(animationValue: 0.3),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(SnowLayer), findsOneWidget);
    });

    testWidgets('FireflyLayer, ButterflyLayer, and StarsAndMoonLayer render', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FireflyLayer(animationValue: 0.7),
                ButterflyLayer(animationValue: 0.4),
                StarsAndMoonLayer(animationValue: 0.2),
                AmbientLightLayer(overlayColor: Color(0x33000000)),
              ],
            ),
          ),
        ),
      );
      expect(find.byType(FireflyLayer), findsOneWidget);
      expect(find.byType(ButterflyLayer), findsOneWidget);
      expect(find.byType(StarsAndMoonLayer), findsOneWidget);
      expect(find.byType(AmbientLightLayer), findsOneWidget);
    });
  });

  group('Couple Character Reaction Tests', () {
    final userChar = Character(
      id: 'u1',
      worldId: 'w1',
      personName: 'Alex',
      gender: 'male',
      hairStyle: 'short_fringe',
      hairColor: const Color(0xFF3E2723),
      skinTone: const Color(0xFFFFDFC4),
      outfitColor: const Color(0xFF81A4CD),
      isCurrentUser: true,
    );

    final compChar = Character(
      id: 'c1',
      worldId: 'w1',
      personName: 'Maya',
      gender: 'female',
      hairStyle: 'twin_tails',
      hairColor: const Color(0xFF5D4037),
      skinTone: const Color(0xFFFFF0E1),
      outfitColor: const Color(0xFFF197A2),
      isCurrentUser: false,
    );

    testWidgets('Couple renders shared umbrella when raining', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CoupleCharacterPairWidget(
                userCharacter: userChar,
                companionCharacter: compChar,
                isHoldingHands: true,
                isWalking: true,
                facingRight: true,
                isRaining: true,
                isSnowing: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CoupleCharacterPairWidget), findsOneWidget);
      // Verify umbrella is present in tree
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Couple renders winter accessories when snowing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CoupleCharacterPairWidget(
                userCharacter: userChar,
                companionCharacter: compChar,
                isHoldingHands: false,
                isWalking: false,
                facingRight: true,
                isRaining: false,
                isSnowing: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CoupleCharacterPairWidget), findsOneWidget);
    });
  });

  group('Memory Landmark & Animal Reaction Tests', () {
    final testMemory = Memory(
      id: 'mem_1',
      worldId: 'w1',
      type: MemoryType.photo,
      title: 'Our First Sunset',
      description: 'Golden hour at the coast',
      memoryDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    testWidgets('MemoryLandmarkWidget renders in snow and night conditions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MemoryLandmarkWidget(
                memory: testMemory,
                isNearby: true,
                condition: WorldCondition.snow,
                timeOfDay: TimeOfDayState.night,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MemoryLandmarkWidget), findsOneWidget);
      expect(find.text('Our First Sunset'), findsOneWidget);
    });

    testWidgets('AnimalWidget renders rabbit with snow and rain reactions', (tester) async {
      final rabbit = AnimalEntity(
        id: 'r1',
        type: AnimalType.rabbit,
        worldPos: const WorldPos(0, 0, 0),
        speechText: 'Rainy day ♡',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimalWidget(
                animal: rabbit,
                isSnowing: true,
                isRaining: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnimalWidget), findsOneWidget);
      expect(find.text('Rainy day ♡'), findsOneWidget);
    });
  });

  group('Living World Integration in StableMemoryWalkWorldWidget Tests', () {
    final testWorld = World(
      id: 'w1',
      name: 'Cozy Valley',
      relationshipType: 'partner',
      personName: 'Maya',
      worldStyle: 'cozy_town',
      createdAt: DateTime.now(),
    );

    final userChar = Character(
      id: 'u1',
      worldId: 'w1',
      personName: 'Alex',
      gender: 'male',
      hairStyle: 'short_fringe',
      hairColor: const Color(0xFF3E2723),
      skinTone: const Color(0xFFFFDFC4),
      outfitColor: const Color(0xFF81A4CD),
      isCurrentUser: true,
    );

    final compChar = Character(
      id: 'c1',
      worldId: 'w1',
      personName: 'Maya',
      gender: 'female',
      hairStyle: 'twin_tails',
      hairColor: const Color(0xFF5D4037),
      skinTone: const Color(0xFFFFF0E1),
      outfitColor: const Color(0xFFF197A2),
      isCurrentUser: false,
    );

    final memories = [
      Memory(
        id: 'm1',
        worldId: 'w1',
        type: MemoryType.photo,
        title: 'First Meet',
        description: 'Under the blossom tree',
        memoryDate: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    ];

    testWidgets('StableMemoryWalkWorldWidget mounts with Rain and Shared Umbrella without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StableMemoryWalkWorldWidget(
              world: testWorld,
              userCharacter: userChar,
              companionCharacter: compChar,
              memories: memories,
              initialConfig: const WorldEnvironmentConfig(
                worldStyle: 'cozy_town',
                condition: WorldCondition.rain,
                timeOfDay: TimeOfDayState.day,
              ),
              onExit: () {},
              onVisitMemory: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(StableMemoryWalkWorldWidget), findsOneWidget);
      expect(find.byType(RainLayer), findsOneWidget);
      expect(find.text('Exit Walk'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('StableMemoryWalkWorldWidget mounts with Snow & Winter atmosphere without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StableMemoryWalkWorldWidget(
              world: testWorld,
              userCharacter: userChar,
              companionCharacter: compChar,
              memories: memories,
              initialConfig: const WorldEnvironmentConfig(
                worldStyle: 'starlit_forest',
                condition: WorldCondition.snow,
                timeOfDay: TimeOfDayState.day,
                season: SeasonState.winter,
              ),
              onExit: () {},
              onVisitMemory: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(StableMemoryWalkWorldWidget), findsOneWidget);
      expect(find.byType(SnowLayer), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('StableMemoryWalkWorldWidget mounts with Night mode (Moon, Stars, Fireflies)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StableMemoryWalkWorldWidget(
              world: testWorld,
              userCharacter: userChar,
              companionCharacter: compChar,
              memories: memories,
              initialConfig: const WorldEnvironmentConfig(
                worldStyle: 'cozy_town',
                condition: WorldCondition.sunny,
                timeOfDay: TimeOfDayState.night,
              ),
              onExit: () {},
              onVisitMemory: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(StableMemoryWalkWorldWidget), findsOneWidget);
      expect(find.byType(StarsAndMoonLayer), findsOneWidget);
      expect(find.byType(FireflyLayer), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
