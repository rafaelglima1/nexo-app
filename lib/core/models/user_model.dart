class AppUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final List<String> interests;
  final String? personality;
  final String? experienceType;
  final bool isVerified;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.interests = const [],
    this.personality,
    this.experienceType,
    this.isVerified = false,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatar_url'],
      interests: List<String>.from(map['interests'] ?? []),
      personality: map['personality'],
      experienceType: map['experience_type'],
      isVerified: map['is_verified'] ?? false,
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'interests': interests,
      'personality': personality,
      'experience_type': experienceType,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
