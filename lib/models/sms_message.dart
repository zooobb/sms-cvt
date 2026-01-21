class SavedSmsMessage {
  final String id;
  final String sender;
  final String content;
  final DateTime receivedAt;
  final DateTime savedAt;

  // 唯一标识：基于发送人和接收时间的组合
  String get uniqueKey => '${sender}_${receivedAt.millisecondsSinceEpoch}';

  SavedSmsMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.receivedAt,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'content': content,
      'receivedAt': receivedAt.toIso8601String(),
      'savedAt': savedAt.toIso8601String(),
      'uniqueKey': uniqueKey,
    };
  }

  factory SavedSmsMessage.fromJson(Map<String, dynamic> json) {
    return SavedSmsMessage(
      id: json['id'] as String,
      sender: json['sender'] as String,
      content: json['content'] as String,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'SavedSmsMessage(id: $id, sender: $sender, content: $content)';
  }
}
