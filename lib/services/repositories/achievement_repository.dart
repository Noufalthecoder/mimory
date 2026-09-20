import 'package:mimory/models/achievement.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getAchievements();
  Future<void> saveAchievement(Achievement achievement);
}

class LocalAchievementRepository implements AchievementRepository {
  final Map<String, Achievement> _store = {};

  LocalAchievementRepository() {
    _store['1'] = Achievement(id: '1', title: 'FIRST MOMENT', description: 'Saved your first memory.');
    _store['2'] = Achievement(id: '2', title: 'CONSISTENT', description: 'Completed 7 daily activities.');
    _store['3'] = Achievement(id: '3', title: 'BUILDER', description: 'Finished your first major project.');
    _store['4'] = Achievement(id: '4', title: 'COLLECTOR', description: 'Saved 10 moments.');
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    return _store.values.toList();
  }

  @override
  Future<void> saveAchievement(Achievement achievement) async {
    _store[achievement.id] = achievement;
  }
}
