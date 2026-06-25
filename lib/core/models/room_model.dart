enum RoomCategory { cafe, filmes, musica, conversas, cultura, jogos }

class Room {
  final String id;
  final String title;
  final String description;
  final RoomCategory category;
  final String hostId;
  final List<String> participantIds;
  final int maxParticipants;
  final bool isLive;
  final List<String> guidedQuestions;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.hostId,
    this.participantIds = const [],
    this.maxParticipants = 8,
    this.isLive = false,
    this.guidedQuestions = const [],
    required this.createdAt,
  });

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: RoomCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => RoomCategory.cafe,
      ),
      hostId: map['host_id'] ?? '',
      participantIds: List<String>.from(map['participant_ids'] ?? []),
      maxParticipants: map['max_participants'] ?? 8,
      isLive: map['is_live'] ?? false,
      guidedQuestions: List<String>.from(map['guided_questions'] ?? []),
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  String get categoryLabel {
    switch (category) {
      case RoomCategory.cafe:
        return 'Café';
      case RoomCategory.filmes:
        return 'Filmes';
      case RoomCategory.musica:
        return 'Música';
      case RoomCategory.conversas:
        return 'Conversas';
      case RoomCategory.cultura:
        return 'Cultura';
      case RoomCategory.jogos:
        return 'Jogos';
    }
  }
}
