import 'package:flutter/material.dart';
import 'package:mimory/models/daily_activity.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/services/repositories/activity_repository.dart';
import 'package:mimory/services/repositories/memory_repository.dart';
import 'package:uuid/uuid.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  // Using direct instantiation for this phase
  final ActivityRepository _activityRepo = LocalActivityRepository();
  final MemoryRepository _memoryRepo = LocalMemoryRepository();
  
  List<DailyActivity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final activities = await _activityRepo.getActivitiesForDate(DateTime.now());
    setState(() {
      _activities = activities;
      _isLoading = false;
    });
  }

  void _toggleTask(int index) async {
    final activity = _activities[index];
    final updatedActivity = activity.copyWith(
      completed: !activity.completed,
      completedAt: !activity.completed ? DateTime.now() : null,
    );

    setState(() {
      _activities[index] = updatedActivity;
    });
    
    await _activityRepo.saveActivity(updatedActivity);

    if (updatedActivity.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('COMPLETE'),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'SAVE AS MOMENT',
            onPressed: () {
              _showSaveMomentDialog(context, updatedActivity);
            },
          ),
        ),
      );
    }
  }

  void _showSaveMomentDialog(BuildContext context, DailyActivity activity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KEEP THIS MOMENT?',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                activity.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Add photo'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Add note'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.mic_none),
                title: const Text('Add voice'),
                onTap: () {},
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _saveMoment(activity);
                  },
                  child: const Text('SAVE MOMENT'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveMoment(DailyActivity activity) async {
    final newMemory = Memory(
      id: const Uuid().v4(),
      worldId: 'default_world',
      type: MemoryType.story,
      title: activity.title,
      description: 'Completed a little thing today.',
      memoryDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
    
    await _memoryRepo.saveMemory(newMemory);
    
    // In a real app we would link it
    final updatedActivity = activity.copyWith(linkedMomentId: newMemory.id);
    await _activityRepo.saveActivity(updatedActivity);
    
    // Mock tiny visual transition
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Text('🌱'),
              SizedBox(width: 12),
              Text('Moment saved ♡', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // Ideally here we call the AchievementEngine, but we will mock that for now
      // by just knowing it exists in the system.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TODAY',
          style: theme.textTheme.displayMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'a few little things worth remembering',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'TODAY\n${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}',
          style: theme.textTheme.bodyMedium?.copyWith(
            letterSpacing: 1.5,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 32),
        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_activities.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nothing planned yet.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add a little thing'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          Text(
            "TODAY'S LITTLE THINGS",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _activities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final activity = _activities[index];
                
                return InkWell(
                  onTap: () => _toggleTask(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Icon(
                            activity.completed ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                            key: ValueKey<bool>(activity.completed),
                            color: activity.completed ? theme.colorScheme.secondary : theme.colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            activity.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              decoration: activity.completed ? TextDecoration.lineThrough : null,
                              color: activity.completed ? theme.colorScheme.primary.withOpacity(0.5) : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_activities.where((a) => a.completed).length} little wins today ♡',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                '${_activities.where((a) => a.completed).length} / ${_activities.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
