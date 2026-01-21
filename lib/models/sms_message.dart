class SavedSmsMessage {
  final String id;
  final String sender;
  final String content;
  final DateTime receivedAt;
  final DateTime savedAt;
  final String primaryCategory;
  final String? secondaryCategory;
  final String? categoryEmoji;

  String get uniqueKey => '${sender}_${receivedAt.millisecondsSinceEpoch}';

  SavedSmsMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.receivedAt,
    required this.savedAt,
    this.primaryCategory = '待分类',
    this.secondaryCategory,
    this.categoryEmoji,
  });

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'id': id,
      'sender': sender,
      'content': content,
      'receivedAt': receivedAt.toIso8601String(),
      'savedAt': savedAt.toIso8601String(),
      'uniqueKey': uniqueKey,
      'primaryCategory': primaryCategory,
    };

    if (secondaryCategory != null) {
      result['secondaryCategory'] = secondaryCategory;
    }

    if (categoryEmoji != null) {
      result['categoryEmoji'] = categoryEmoji;
    }

    return result;
  }

  factory SavedSmsMessage.fromJson(Map<String, dynamic> json) {
    return SavedSmsMessage(
      id: json['id'] as String,
      sender: json['sender'] as String,
      content: json['content'] as String,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      savedAt: DateTime.parse(json['savedAt'] as String),
      primaryCategory: json['primaryCategory'] as String? ?? '待分类',
      secondaryCategory: json['secondaryCategory'] as String?,
      categoryEmoji: json['categoryEmoji'] as String?,
    );
  }

  @override
  String toString() {
    return 'SavedSmsMessage(id: $id, sender: $sender, content: $content)';
  }
}
