class Notification {
  final String id;
  final String title;
  final String timestamp;
  final String imageUrl;
  final String body;
  bool isRead; // Property to indicate if the notification is read

  Notification({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.imageUrl,
    required this.body,
    this.isRead = false, // Default value for isRead is false (unread)
  });

  factory Notification.fromJson(String id, Map<String, dynamic> json) {
    return Notification(
      id: id,
      title: json['title'] as String,
      timestamp: json['timestamp'] as String,
      imageUrl: json['imageUrl'] as String,
      body: json['body'] as String,
      isRead: json['isRead'] as bool? ?? false, // Default to false if isRead is not in the json
    );
  }
}
