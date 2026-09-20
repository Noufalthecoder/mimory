class Goal {
  final String id;
  final String title;
  final String description;
  final double progress; // 0.0 to 1.0
  final DateTime? targetDate;
  final String? category;
  final List<String> relatedActivityIds;
  final List<String> relatedMomentIds;
  final bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    this.description = '',
    this.progress = 0.0,
    this.targetDate,
    this.category,
    this.relatedActivityIds = const [],
    this.relatedMomentIds = const [],
    this.isCompleted = false,
  });
}
