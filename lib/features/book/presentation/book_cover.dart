import 'package:flutter/material.dart';
import 'package:mimory/features/book/presentation/book_screen.dart';

class BookCoverScreen extends StatelessWidget {
  const BookCoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MIMORY',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'A little world made of your moments.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            Text(
              '♡ ✦ 🌱',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookScreen()),
                );
              },
              child: const Text('OPEN MY WORLD →'),
            ),
            const SizedBox(height: 48),
            Text(
              'YOUR 2026',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
