class SavedSmsMessage {
  final String id;
  final String sender;
  final String content;
  final DateTime receivedAt;
  final DateTime savedAt;
  final String type;
  final String? category;
  final String? secondaryCategory;
  final bool isManuallyClassified;

  String get uniqueKey => '${sender}_${receivedAt.millisecondsSinceEpoch}';

  SavedSmsMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.receivedAt,
    required this.savedAt,
    required this.type,
    this.category,
    this.secondaryCategory,
    this.isManuallyClassified = false,
  });

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'id': id,
      'sender': sender,
      'content': content,
      'receivedAt': receivedAt.toIso8601String(),
      'savedAt': savedAt.toIso8601String(),
      'uniqueKey': uniqueKey,
      'type': type,
      'isManuallyClassified': isManuallyClassified,
    };

    result['category'] = category ?? '';
    result['secondaryCategory'] = secondaryCategory ?? '';

    return result;
  }

  factory SavedSmsMessage.fromJson(Map<String, dynamic> json) {
    return SavedSmsMessage(
      id: json['id'] as String,
      sender: json['sender'] as String,
      content: json['content'] as String,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      savedAt: DateTime.parse(json['savedAt'] as String),
      type: json['type'] as String? ?? '待分类',
      category: json['category'] as String?,
      secondaryCategory: json['secondaryCategory'] as String?,
      isManuallyClassified: json['isManuallyClassified'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'SavedSmsMessage(id: $id, sender: $sender, content: $content)';
  }
}
