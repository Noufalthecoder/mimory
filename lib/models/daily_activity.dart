class DailyActivity {
  final String id;
  final String title;
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? category;
  final String? goalId;
  final String? linkedMomentId;
  final String? linkedAchievementId;

  DailyActivity({
    required this.id,
    required this.title,
    this.completed = false,
    required this.createdAt,
    this.completedAt,
    this.category,
    this.goalId,
    this.linkedMomentId,
    this.linkedAchievementId,
  });

  DailyActivity copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? createdAt,
    DateTime? completedAt,
    String? category,
    String? goalId,
    String? linkedMomentId,
    String? linkedAchievementId,
  }) {
    return DailyActivity(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      goalId: goalId ?? this.goalId,
      linkedMomentId: linkedMomentId ?? this.linkedMomentId,
      linkedAchievementId: linkedAchievementId ?? this.linkedAchievementId,
    );
  }
}
