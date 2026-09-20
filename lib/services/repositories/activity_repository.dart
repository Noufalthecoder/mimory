import 'package:mimory/models/daily_activity.dart';

abstract class ActivityRepository {
  Future<List<DailyActivity>> getActivitiesForDate(DateTime date);
  Future<void> saveActivity(DailyActivity activity);
  Future<void> deleteActivity(String id);
}

class LocalActivityRepository implements ActivityRepository {
  final Map<String, DailyActivity> _store = {};

  LocalActivityRepository() {
    // Seed some initial activities for testing
    final today = DateTime.now();
    _store['1'] = DailyActivity(id: '1', title: 'Complete DBMS assignment', createdAt: today);
    _store['2'] = DailyActivity(id: '2', title: 'Solve 3 DSA problems', createdAt: today);
    _store['3'] = DailyActivity(id: '3', title: 'Work on MIMORY', createdAt: today);
    _store['4'] = DailyActivity(id: '4', title: 'Read 20 pages', createdAt: today);
  }

  @override
  Future<List<DailyActivity>> getActivitiesForDate(DateTime date) async {
    return _store.values.where((a) => 
      a.createdAt.year == date.year && 
      a.createdAt.month == date.month && 
      a.createdAt.day == date.day
    ).toList();
  }

  @override
  Future<void> saveActivity(DailyActivity activity) async {
    _store[activity.id] = activity;
  }

  @override
  Future<void> deleteActivity(String id) async {
    _store.remove(id);
  }
}
