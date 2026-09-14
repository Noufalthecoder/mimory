import 'package:flutter/material.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/widgets/memory_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock data for initial UI
  final List<Memory> _memories = [
    Memory(
      id: '1',
      worldId: 'temp_world_id',
      type: MemoryType.story,
      title: 'A peaceful morning',
      description: 'Woke up early and enjoyed a quiet cup of coffee while watching the sunrise. The colors were beautiful and the silence was very calming.',
      memoryDate: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now(),
    ),
    Memory(
      id: '2',
      worldId: 'temp_world_id',
      type: MemoryType.story,
      title: 'Overwhelmed at work',
      description: 'Had a lot of tight deadlines today. Feeling a bit stressed, but I managed to get the most important things done.',
      memoryDate: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now(),
    ),
    Memory(
      id: '3',
      worldId: 'temp_world_id',
      type: MemoryType.story,
      title: 'Great dinner with friends',
      description: 'Laughed so hard tonight. It was exactly what I needed after a long week. The food was amazing too!',
      memoryDate: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How are you feeling today?',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),
            ),
            
            // Timeline Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Memories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _memories.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return MemoryCard(memory: _memories[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Future: Open add memory modal
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
