class World {
  final String id;
  final String name;
  final String relationshipType;
  final String personName;
  final String? nickname;
  final String? personPhotoPath;
  final String? personGender;
  final String userAvatarId;
  final String companionAvatarId;
  final String worldStyle;
  final DateTime createdAt;

  World({
    required this.id,
    required this.name,
    required this.relationshipType,
    required this.personName,
    this.nickname,
    this.personPhotoPath,
    this.personGender,
    this.userAvatarId = 'boy_01',
    this.companionAvatarId = 'girl_01',
    this.worldStyle = 'cozy_town',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relationshipType': relationshipType,
        'personName': personName,
        'nickname': nickname,
        'personPhotoPath': personPhotoPath,
        'personGender': personGender,
        'userAvatarId': userAvatarId,
        'companionAvatarId': companionAvatarId,
        'worldStyle': worldStyle,
        'createdAt': createdAt.toIso8601String(),
      };

  factory World.fromJson(Map<String, dynamic> json) => World(
        id: json['id'] as String,
        name: json['name'] as String,
        relationshipType: json['relationshipType'] as String,
        personName: json['personName'] as String,
        nickname: json['nickname'] as String?,
        personPhotoPath: json['personPhotoPath'] as String?,
        personGender: json['personGender'] as String?,
        userAvatarId: json['userAvatarId'] as String? ?? 'boy_01',
        companionAvatarId: json['companionAvatarId'] as String? ?? 'girl_01',
        worldStyle: json['worldStyle'] as String? ?? 'cozy_town',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
