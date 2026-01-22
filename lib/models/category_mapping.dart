class CategoryMapping {
  final String keyword;
  final String type;
  final String? category;
  final String? secondaryCategory;

  const CategoryMapping({
    required this.keyword,
    required this.type,
    this.category,
    this.secondaryCategory,
  });

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{'keyword': keyword, 'type': type};

    if (category != null) {
      result['category'] = category!;
    }
    if (secondaryCategory != null) {
      result['secondaryCategory'] = secondaryCategory!;
    }

    return result;
  }

  factory CategoryMapping.fromJson(Map<String, dynamic> json) {
    return CategoryMapping(
      keyword: json['keyword'] as String,
      type: json['type'] as String,
      category: json['category'] as String?,
      secondaryCategory: json['secondaryCategory'] as String?,
    );
  }
}
