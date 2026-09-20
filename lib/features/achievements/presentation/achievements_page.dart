import 'package:flutter/material.dart';
import 'package:mimory/models/achievement.dart';
import 'package:mimory/services/achievement_engine.dart';
import 'package:mimory/services/repositories/achievement_repository.dart';
import 'package:mimory/services/repositories/activity_repository.dart';
import 'package:mimory/services/repositories/memory_repository.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late AchievementEngine _engine;
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _engine = AchievementEngine(
      achievementRepository: LocalAchievementRepository(),
      activityRepository: LocalActivityRepository(),
      memoryRepository: LocalMemoryRepository(),
    );
    _engine.addListener(_loadAchievements);
    _loadAchievements();
  }

  @override
  void dispose() {
    _engine.removeListener(_loadAchievements);
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    final achievements = await _engine.achievementRepository.getAchievements();
    setState(() {
      _achievements = achievements;
      _isLoading = false;
    });
  }

  void _triggerCheck(String id) async {
    // In real usage, this check is triggered by business logic (e.g., saving a moment)
    // For demo purposes, we manually trigger the check here
    final unlocked = await _engine.checkAndUnlock(id);
    if (unlocked != null && mounted) {
      _showUnlockOverlay(unlocked);
    }
  }

  void _showUnlockOverlay(Achievement achievement) {
    showDialog(
      context: context,
      barrierColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '✦ LITTLE WIN',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  achievement.title,
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You saved something worth remembering.',
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('KEEP GOING'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LITTLE WINS',
          style: theme.textTheme.displayMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Things worth being proud of.',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 32),
        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_achievements.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Your first little win is waiting.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                return _AchievementItem(
                  achievement: achievement,
                  onTap: () => _triggerCheck(achievement.id),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onTap;

  const _AchievementItem({
    required this.achievement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isUnlocked = achievement.isUnlocked;

    return InkWell(
      onTap: isUnlocked ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: primaryColor.withOpacity(0.1)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUnlocked ? '✦' : '○',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isUnlocked ? theme.colorScheme.secondary : primaryColor.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: isUnlocked ? primaryColor : primaryColor.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isUnlocked ? primaryColor.withOpacity(0.7) : primaryColor.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isUnlocked 
                            ? 'Unlocked ${achievement.unlockedAt!.month}/${achievement.unlockedAt!.day}' 
                            : 'Locked',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isUnlocked ? theme.colorScheme.secondary : primaryColor.withOpacity(0.3),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
