/// Represents a mock user session for MIMORY.
class UserSession {
  final String id;
  final String displayName;
  final String email;
  final bool isLoggedIn;

  const UserSession({
    required this.id,
    required this.displayName,
    required this.email,
    this.isLoggedIn = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'isLoggedIn': isLoggedIn,
      };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        id: json['id'] as String? ?? 'mock_user_001',
        displayName: json['displayName'] as String? ?? 'Noufal',
        email: json['email'] as String? ?? 'demo@mimory.app',
        isLoggedIn: json['isLoggedIn'] as bool? ?? true,
      );
}
