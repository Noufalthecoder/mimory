import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/services/world_service.dart';
import 'package:mimory/core/theme/app_theme.dart';
import 'package:mimory/widgets/memory_card.dart';

class WorldHomeScreen extends StatelessWidget {
  final World world;

  const WorldHomeScreen({super.key, required this.world});

  @override
  Widget build(BuildContext context) {
    final memories = WorldService().getMemoriesForWorld(world.id);
    final memoryCount = memories.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryPink.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'with ${world.personName}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.settings, color: AppTheme.textSecondary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    world.name,
                    style: GoogleFonts.mali(
                      color: AppTheme.textPrimary,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    memoryCount == 1 ? '1 little moment' : '$memoryCount little moments',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Timeline
            Expanded(
              child: memories.isEmpty
                  ? Center(
                      child: Text(
                        'Your world is just beginning. ♡',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemCount: memories.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return MemoryCard(memory: memories[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryPink,
        foregroundColor: Colors.white,
        onPressed: () {
          // Future: Navigate back to Add Memory
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
