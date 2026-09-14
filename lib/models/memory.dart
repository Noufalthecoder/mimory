enum MemoryType {
  photo,
  story,
}

class Memory {
  final String id;
  final String worldId;
  final MemoryType type;
  final String title;
  final String description;
  final String? imagePath;
  final DateTime memoryDate;
  final DateTime createdAt;

  Memory({
    required this.id,
    required this.worldId,
    required this.type,
    required this.title,
    required this.description,
    this.imagePath,
    required this.memoryDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'worldId': worldId,
        'type': type.name,
        'title': title,
        'description': description,
        'imagePath': imagePath,
        'memoryDate': memoryDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Memory.fromJson(Map<String, dynamic> json) => Memory(
        id: json['id'] as String,
        worldId: json['worldId'] as String,
        type: (json['type'] as String?) == 'story'
            ? MemoryType.story
            : MemoryType.photo,
        title: json['title'] as String,
        description: json['description'] as String,
        imagePath: json['imagePath'] as String?,
        memoryDate: DateTime.parse(json['memoryDate'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
