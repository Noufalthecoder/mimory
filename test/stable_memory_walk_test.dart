import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/widgets/couple_character_pair_widget.dart';
import 'package:mimory/widgets/memory_walk/direction_signboard.dart';
import 'package:mimory/widgets/memory_walk/stable_memory_walk_world.dart';
import 'package:mimory/widgets/memory_walk_joystick.dart';

void main() {
  group('Stable Long-Range Memory Walk Tests', () {
    final testWorld = World(
      id: 'w1',
      name: 'Our Cozy World',
      relationshipType: 'Best Friends',
      personName: 'Maya',
      createdAt: DateTime.now(),
    );

    final userChar = Character(
      id: 'user',
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
      id: 'comp',
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
        title: 'Sunset Beach',
        description: 'Warm evening waves',
        memoryDate: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    ];

    testWidgets('StableMemoryWalkWorldWidget renders with stable view and both characters visible', (tester) async {
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
              onExit: () {},
              onVisitMemory: (_) {},
            ),
          ),
        ),
      );

      // Verify essential UI elements
      expect(find.byType(StableMemoryWalkWorldWidget), findsOneWidget);
      expect(find.text('Exit Walk'), findsOneWidget);
      expect(find.text('Memory Walk ♡'), findsOneWidget);
      expect(find.text('Hold Hands'), findsOneWidget);

      // Verify Movement Joystick exists
      expect(find.byType(MemoryWalkJoystick), findsOneWidget);

      // Verify Both Characters are rendered together
      expect(find.byType(CoupleCharacterPairWidget), findsOneWidget);

      // Verify Direction Signboard exists
      expect(find.byType(DirectionSignboardWidget), findsWidgets);

      // Pump a few frames
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('Hold Hands button toggles to Holding Hands with heart icon', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
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
              onExit: () {},
              onVisitMemory: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Hold Hands'), findsOneWidget);

      // Tap Hold Hands
      await tester.tap(find.text('Hold Hands'));
      await tester.pump(const Duration(milliseconds: 300));

      // Should now display Holding Hands with red heart
      expect(find.text('Holding Hands'), findsOneWidget);
      expect(find.text('❤️'), findsOneWidget);
    });

    testWidgets('DirectionSignboardWidget renders safely with bounded constraints', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionSignboardWidget(
                label: '📷 SUNSET BEACH',
                arrow: '→',
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('📷 SUNSET BEACH →'), findsOneWidget);
    });
  });
}
