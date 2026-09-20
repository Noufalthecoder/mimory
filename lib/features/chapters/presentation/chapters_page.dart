import 'package:flutter/material.dart';
import 'package:mimory/models/chapter.dart';

class ChaptersPage extends StatefulWidget {
  const ChaptersPage({super.key});

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  // Mock chapters since we didn't create a repository for this yet, 
  // but following the pattern, we'll assume they exist locally
  final List<Chapter> _chapters = [
    Chapter(
      id: '1',
      title: 'MY FIRST HACKATHON',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      relatedMomentIds: ['1', '2', '3', '4', '5', '6', '7', '8'],
    ),
    Chapter(
      id: '2',
      title: 'SEMESTER FIVE',
      startDate: DateTime.now().subtract(const Duration(days: 90)),
      endDate: DateTime.now(),
      relatedMomentIds: List.generate(23, (index) => index.toString()),
    ),
    Chapter(
      id: '3',
      title: 'BUILDING MIMORY',
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      endDate: DateTime.now(),
      relatedMomentIds: List.generate(14, (index) => index.toString()),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHAPTERS',
          style: theme.textTheme.displayMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'The parts of life that became stories.',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 32),
        if (_chapters.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Some stories haven\'t been written yet.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: _chapters.length,
              separatorBuilder: (context, index) => const SizedBox(height: 32),
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                return _ChapterCover(chapter: chapter);
              },
            ),
          ),
      ],
    );
  }
}

class _ChapterCover extends StatelessWidget {
  final Chapter chapter;

  const _ChapterCover({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {},
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Mock cover image placeholder
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Opacity(
                  opacity: 0.1,
                  child: Container(color: theme.colorScheme.primary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${chapter.relatedMomentIds.length} moments',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
