class AppEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? imageUrl;
  final List<String> participantIds;
  final bool isSeasonal;

  AppEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    this.participantIds = const [],
    this.isSeasonal = false,
  });

  factory AppEvent.fromMap(Map<String, dynamic> map) {
    return AppEvent(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      imageUrl: map['image_url'],
      participantIds: List<String>.from(map['participant_ids'] ?? []),
      isSeasonal: map['is_seasonal'] ?? false,
    );
  }
}
