class CategoryMapping {
  final String keyword;
  final String primaryCategory;
  final String? secondaryCategory;
  final String? emoji;

  const CategoryMapping({
    required this.keyword,
    required this.primaryCategory,
    this.secondaryCategory,
    this.emoji,
  });

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'keyword': keyword,
      'primaryCategory': primaryCategory,
    };

    if (secondaryCategory != null) {
      result['secondaryCategory'] = secondaryCategory;
    }

    if (emoji != null) {
      result['emoji'] = emoji;
    }

    return result;
  }

  factory CategoryMapping.fromJson(Map<String, dynamic> json) {
    return CategoryMapping(
      keyword: json['keyword'] as String,
      primaryCategory: json['primaryCategory'] as String,
      secondaryCategory: json['secondaryCategory'] as String?,
      emoji: json['emoji'] as String?,
    );
  }
}
