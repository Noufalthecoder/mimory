import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/world_point.dart';
import 'package:mimory/widgets/memory_walk/third_person_couple.dart';
import 'package:mimory/widgets/memory_walk/direction_signboard.dart';
import 'package:mimory/widgets/memory_walk/third_person_world.dart';

void main() {
  group('3D Perspective World Math Tests', () {
    test('WorldPos vector operations and distances', () {
      const p1 = WorldPos(10.0, 20.0, 0.0);
      const p2 = WorldPos(40.0, 60.0, 0.0);

      final diff = p2 - p1;
      expect(diff.x, 30.0);
      expect(diff.y, 40.0);

      final dist = p1.horizontalDistanceTo(p2);
      expect(dist, 50.0); // 3-4-5 triangle
    });

    test('Camera3D perspective scaling obeys world depth', () {
      final camera = Camera3D(
        position: const WorldPos(0.0, 0.0, 50.0),
        yaw: 0.0,
        pitch: 0.35,
        focalLength: 500.0,
      );

      const screenSize = Size(400, 800);

      // Point A is near (y = 50)
      final projNear = camera.project(const WorldPos(0.0, 50.0, 0.0), screenSize);
      // Point B is far (y = 200)
      final projFar = camera.project(const WorldPos(0.0, 200.0, 0.0), screenSize);

      expect(projNear.isVisible, true);
      expect(projFar.isVisible, true);

      // Far point must have smaller scale than near point (perspective scaling!)
      expect(projFar.scale < projNear.scale, true);
      // Far point must have larger depth for Painter's algorithm
      expect(projFar.depth > projNear.depth, true);
    });

    test('Camera3D clips points behind the lens', () {
      final camera = Camera3D(
        position: const WorldPos(0.0, 50.0, 50.0),
        yaw: 0.0,
        pitch: 0.35,
      );

      // Point behind camera (y = -10 while camera is at y = 50 facing forward)
      final projBehind = camera.project(const WorldPos(0.0, -10.0, 0.0), const Size(400, 800));
      expect(projBehind.isVisible, false);
    });

    test('Camera3D smooth player follow updates position', () {
      final camera = Camera3D(
        position: const WorldPos(0.0, -100.0, 60.0),
        distanceBehind: 100.0,
        heightAbove: 60.0,
      );

      final initialCamX = camera.position.x;
      final initialCamY = camera.position.y;

      // Move player forward to y = 50
      camera.followPlayer(
        playerPos: const WorldPos(0.0, 50.0, 0.0),
        targetYaw: 0.0,
        lagT: 0.5,
      );

      // Camera position should have moved forward
      expect(camera.position.y > initialCamY, true);
      expect(camera.position.x, initialCamX);
    });

    test('Camera3D soft dead-zone preserves camera anchor for minor micro-movements', () {
      final camera = Camera3D(
        position: const WorldPos(0.0, -100.0, 60.0),
        deadZoneX: 20.0,
        deadZoneY: 25.0,
        focusAnchor: const WorldPos(0.0, 0.0, 0.0),
      );

      // Micro movement inside deadzone (x: 5, y: 10)
      camera.followPlayer(
        playerPos: const WorldPos(5.0, 10.0, 0.0),
        targetYaw: 0.0,
        isMoving: true,
      );

      // Anchor should remain at (0, 0)
      expect(camera.focusAnchor!.x, 0.0);
      expect(camera.focusAnchor!.y, 0.0);

      // Large movement outside deadzone (y: 60 > 25)
      camera.followPlayer(
        playerPos: const WorldPos(5.0, 60.0, 0.0),
        targetYaw: 0.0,
        isMoving: true,
      );

      // Anchor should now pull forward: 60 - 25 = 35
      expect(camera.focusAnchor!.y, 35.0);
    });
  });

  group('Third-Person Widgets Rendering Tests', () {
    testWidgets('ThirdPersonCoupleWidget renders with connected hand holding', (tester) async {
      final userChar = Character(
        id: 'user',
        worldId: 'world_1',
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
        worldId: 'world_1',
        personName: 'Maya',
        gender: 'female',
        hairStyle: 'twin_tails',
        hairColor: const Color(0xFF5D4037),
        skinTone: const Color(0xFFFFF0E1),
        outfitColor: const Color(0xFFF197A2),
        isCurrentUser: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ThirdPersonCoupleWidget(
                userCharacter: userChar,
                companionCharacter: compChar,
                isHoldingHands: true,
                isWalking: true,
                facingAngle: 0.2,
                scale: 1.2,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ThirdPersonCoupleWidget), findsOneWidget);
    });

    testWidgets('DirectionSignboardWidget renders destinations correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DirectionSignboardWidget(
                label: '📷 MEETUP',
                arrow: '→',
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('📷 MEETUP →'), findsOneWidget);
    });

    testWidgets('ThirdPersonWorldWidget mounts cleanly on narrow screens without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final world = World(
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
          title: 'First Sunset',
          description: 'A magical evening at the coast',
          memoryDate: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThirdPersonWorldWidget(
              world: world,
              userCharacter: userChar,
              companionCharacter: compChar,
              memories: memories,
              onExit: () {},
              onVisitMemory: (_) {},
            ),
          ),
        ),
      );

      // Verify essential components render
      expect(find.byType(ThirdPersonWorldWidget), findsOneWidget);
      expect(find.text('Exit Walk'), findsOneWidget);
      expect(find.text('Memory Walk ♡'), findsOneWidget);
      expect(find.text('Hold Hands'), findsOneWidget);

      // Pump a few frames for the game loop animation
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
