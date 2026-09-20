import 'package:mimory/models/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> getGoals();
  Future<void> saveGoal(Goal goal);
  Future<void> deleteGoal(String id);
}

class LocalGoalRepository implements GoalRepository {
  final Map<String, Goal> _store = {};

  LocalGoalRepository() {
    _store['1'] = Goal(id: '1', title: 'Master DSA', progress: 0.78, targetDate: DateTime.now().add(const Duration(days: 90)));
    _store['2'] = Goal(id: '2', title: 'Ship MIMORY', progress: 0.64, targetDate: DateTime.now().add(const Duration(days: 30)));
    _store['3'] = Goal(id: '3', title: 'Win a Hackathon', progress: 0.48);
  }

  @override
  Future<List<Goal>> getGoals() async {
    return _store.values.toList();
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    _store[goal.id] = goal;
  }

  @override
  Future<void> deleteGoal(String id) async {
    _store.remove(id);
  }
}
