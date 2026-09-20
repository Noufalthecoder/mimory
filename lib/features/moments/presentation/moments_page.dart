import 'package:flutter/material.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/services/repositories/memory_repository.dart';

class MomentsPage extends StatefulWidget {
  const MomentsPage({super.key});

  @override
  State<MomentsPage> createState() => _MomentsPageState();
}

class _MomentsPageState extends State<MomentsPage> {
  final MemoryRepository _memoryRepo = LocalMemoryRepository();
  List<Memory> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    final memories = await _memoryRepo.getMemories();
    setState(() {
      _memories = memories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'MOMENTS',
              style: theme.textTheme.displayMedium,
            ),
            Text(
              '2026',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary.withOpacity(0.5),
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_memories.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Your first moment is waiting.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: _memories.length,
              separatorBuilder: (context, index) => Column(
                children: [
                  const SizedBox(height: 24),
                  Divider(color: theme.colorScheme.primary.withOpacity(0.1)),
                  const SizedBox(height: 24),
                ],
              ),
              itemBuilder: (context, index) {
                final memory = _memories[index];
                return _EditorialMoment(memory: memory);
              },
            ),
          ),
      ],
    );
  }
}

class _EditorialMoment extends StatelessWidget {
  final Memory memory;

  const _EditorialMoment({required this.memory});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Month abbreviation
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final dateString = '${months[memory.memoryDate.month - 1]} ${memory.memoryDate.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder for photograph
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                memory.type == MemoryType.photo ? Icons.photo_outlined : Icons.edit_note_outlined,
                color: theme.colorScheme.primary.withOpacity(0.2),
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '"${memory.title}"',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                dateString,
                style: theme.textTheme.bodySmall?.copyWith(
                  letterSpacing: 2.0,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            memory.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
