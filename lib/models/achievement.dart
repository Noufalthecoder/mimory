class Achievement {
  final String id;
  final String title;
  final String description;
  final String? icon;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.icon,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    DateTime? unlockedAt,
    bool clearUnlockedAt = false,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: clearUnlockedAt ? null : (unlockedAt ?? this.unlockedAt),
    );
  }
}
