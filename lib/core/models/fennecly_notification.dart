/// In-app notification row from the shared Fennecly database.
/// Statuses: info | success | error | stock | order | return ...
class FenneclyNotification {
  const FenneclyNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;

  factory FenneclyNotification.fromMap(Map<String, dynamic> m) => FenneclyNotification(
        id: (m['id'] ?? '').toString(),
        title: (m['title'] ?? '').toString(),
        message: (m['message'] ?? '').toString(),
        type: (m['type'] ?? 'info').toString(),
        read: m['read'] == true,
        createdAt: DateTime.tryParse((m['created_at'] ?? '').toString()) ??
            DateTime.now(),
      );

  FenneclyNotification copyWith({bool? read}) => FenneclyNotification(
        id: id,
        title: title,
        message: message,
        type: type,
        read: read ?? this.read,
        createdAt: createdAt,
      );
}
