class Community {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<String> memberIds;
  final List<String> interests;
  final DateTime createdAt;

  Community({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.memberIds = const [],
    this.interests = const [],
    required this.createdAt,
  });

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['image_url'],
      memberIds: List<String>.from(map['member_ids'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
