import 'package:flutter/material.dart';
import 'package:mimory/models/achievement.dart';
import 'package:mimory/services/repositories/achievement_repository.dart';
import 'package:mimory/services/repositories/activity_repository.dart';
import 'package:mimory/services/repositories/memory_repository.dart';

class AchievementEngine extends ChangeNotifier {
  final AchievementRepository achievementRepository;
  final ActivityRepository activityRepository;
  final MemoryRepository memoryRepository;

  AchievementEngine({
    required this.achievementRepository,
    required this.activityRepository,
    required this.memoryRepository,
  });

  Future<Achievement?> checkAndUnlock(String achievementId) async {
    final achievements = await achievementRepository.getAchievements();
    final achievement = achievements.firstWhere((a) => a.id == achievementId, orElse: () => throw Exception('Achievement not found'));

    if (achievement.isUnlocked) return null;

    bool shouldUnlock = false;

    // Rules
    if (achievementId == '1') {
      // FIRST MOMENT
      final memories = await memoryRepository.getMemories();
      shouldUnlock = memories.isNotEmpty;
    } else if (achievementId == '4') {
      // COLLECTOR
      final memories = await memoryRepository.getMemories();
      shouldUnlock = memories.length >= 10;
    } else if (achievementId == '2') {
      // CONSISTENT (Simplified rule: just checking if there are 7 completed activities)
      // In reality, this would check a date streak
      final activities = await activityRepository.getActivitiesForDate(DateTime.now());
      shouldUnlock = activities.where((a) => a.completed).length >= 7;
    }

    if (shouldUnlock) {
      final unlocked = achievement.copyWith(unlockedAt: DateTime.now());
      await achievementRepository.saveAchievement(unlocked);
      notifyListeners();
      return unlocked;
    }

    return null;
  }
}
