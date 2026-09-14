import 'package:flutter/material.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/services/world_service.dart';
import 'package:mimory/features/auth/screens/welcome_screen.dart';
import 'package:mimory/features/world/screens/your_worlds_screen.dart';

import 'package:mimory/services/revenue_cat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize persistent storage and load session, worlds, memories
  await WorldService().init();

  // Initialize RevenueCat monetization exactly once with existing user ID
  await RevenueCatService().init(
    appUserId: WorldService().session?.id,
  );

  runApp(const MimoryApp());
}

class MimoryApp extends StatelessWidget {
  const MimoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final worldService = WorldService();
    final initialHome = worldService.isLoggedIn
        ? const YourWorldsScreen()
        : const WelcomeScreen();

    return MaterialApp(
      title: 'MIMORY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialHome,
    );
  }
}
