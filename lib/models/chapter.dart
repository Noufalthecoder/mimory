class Chapter {
  final String id;
  final String title;
  final String description;
  final String? coverImagePath;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> relatedMomentIds;
  final List<String> relatedGoalIds;
  final List<String> relatedAchievementIds;

  Chapter({
    required this.id,
    required this.title,
    this.description = '',
    this.coverImagePath,
    required this.startDate,
    required this.endDate,
    this.relatedMomentIds = const [],
    this.relatedGoalIds = const [],
    this.relatedAchievementIds = const [],
  });
}
