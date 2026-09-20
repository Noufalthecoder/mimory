import 'package:flutter/material.dart';
// Note: Assuming there is a YourWorldsScreen from the existing app
import 'package:mimory/features/world/screens/your_worlds_screen.dart';

class WorldPage extends StatelessWidget {
  const WorldPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'YOUR WORLD',
          style: theme.textTheme.displayMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Every little moment leaves a mark.',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.secondary,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 48),
        
        // Visual representation of the world connection
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.05),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.public, // Or a tree/sprout icon to represent the living world
              size: 64,
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
        
        const SizedBox(height: 64),
        
        ElevatedButton(
          onPressed: () {
            // Hero-like transition to the existing world
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const YourWorldsScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var begin = 0.0;
                  var end = 1.0;
                  var curve = Curves.easeInOut;
                  
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  
                  return FadeTransition(
                    opacity: animation.drive(tween),
                    child: ScaleTransition(
                      scale: Tween(begin: 0.95, end: 1.0).animate(CurvedAnimation(
                        parent: animation,
                        curve: curve,
                      )),
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 600),
              ),
            );
          },
          child: const Text('ENTER MY WORLD →'),
        ),
      ],
    );
  }
}
