import 'package:flutter/material.dart';
import 'package:mimory/models/goal.dart';
import 'package:mimory/services/repositories/goal_repository.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final GoalRepository _goalRepo = LocalGoalRepository();
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _goalRepo.getGoals();
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THINGS I\'M GROWING',
          style: theme.textTheme.displayMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Small steps become something bigger.',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 32),
        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_goals.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start growing something.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add a goal'),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: _goals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final goal = _goals[index];
                return _GoalCard(
                  title: goal.title,
                  progress: goal.progress,
                  icon: Icons.track_changes_outlined, // In reality, mapped to goal category
                  targetDate: goal.targetDate != null 
                      ? '${goal.targetDate!.month}/${goal.targetDate!.year}' 
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final double progress;
  final IconData icon;
  final String? targetDate;

  const _GoalCard({
    required this.title,
    required this.progress,
    required this.icon,
    this.targetDate,
  });

  void _showGoalDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            final theme = Theme.of(context);
            return Container(
              padding: const EdgeInsets.all(32.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 32, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title.toUpperCase(),
                          style: theme.textTheme.headlineLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      if (targetDate != null)
                        Text(
                          'Target: $targetDate',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'RECENT ACTIVITY',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _ActivityItem(title: 'Solved Binary Search', completed: true),
                  const _ActivityItem(title: 'Completed Trees', completed: true),
                  const _ActivityItem(title: 'Graphs practice', completed: false),
                  const SizedBox(height: 32),
                  Text(
                    'RELATED MOMENTS',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"Finally understood recursion."',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '"First time solving a medium problem."',
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('VIEW MOMENTS'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _showGoalDetails(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary.withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
              ),
            ),
            if (targetDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Target: $targetDate',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final bool completed;

  const _ActivityItem({required this.title, required this.completed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check : Icons.radio_button_unchecked, 
            size: 16, 
            color: completed ? theme.colorScheme.secondary : theme.colorScheme.primary.withOpacity(0.3)
          ),
          const SizedBox(width: 12),
          Text(
            title, 
            style: theme.textTheme.bodyMedium?.copyWith(
              color: completed ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.5),
            )
          ),
        ],
      ),
    );
  }
}
