class SenderKeywordRule {
  final String sender;
  final List<String> keywords;

  SenderKeywordRule({required this.sender, required this.keywords});

  SenderKeywordRule copyWith({String? sender, List<String>? keywords}) {
    return SenderKeywordRule(
      sender: sender ?? this.sender,
      keywords: keywords ?? this.keywords,
    );
  }

  Map<String, dynamic> toJson() {
    return {'sender': sender, 'keywords': keywords};
  }

  factory SenderKeywordRule.fromJson(Map<String, dynamic> json) {
    return SenderKeywordRule(
      sender: json['sender'] as String,
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  bool matchesContent(String content) {
    if (keywords.isEmpty) return false;

    for (final keyword in keywords) {
      try {
        final pattern = RegExp(keyword, caseSensitive: false);
        if (pattern.hasMatch(content)) {
          return true;
        }
      } catch (e) {
        print('Invalid regex pattern: $keyword, error: $e');
        continue;
      }
    }

    return false;
  }

  @override
  String toString() {
    return 'SenderKeywordRule(sender: $sender, keywords: $keywords)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SenderKeywordRule &&
        other.sender == sender &&
        _listEquals(other.keywords, keywords);
  }

  @override
  int get hashCode => sender.hashCode ^ keywords.hashCode;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
