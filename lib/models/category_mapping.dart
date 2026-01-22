class CategoryMapping {
  final String keyword;
  final String primaryCategory;
  final String? secondaryCategory;

  const CategoryMapping({
    required this.keyword,
    required this.primaryCategory,
    this.secondaryCategory,
  });

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'keyword': keyword,
      'primaryCategory': primaryCategory,
    };

    if (secondaryCategory != null) {
      result['secondaryCategory'] = secondaryCategory!;
    }

    return result;
  }

  factory CategoryMapping.fromJson(Map<String, dynamic> json) {
    return CategoryMapping(
      keyword: json['keyword'] as String,
      primaryCategory: json['primaryCategory'] as String,
      secondaryCategory: json['secondaryCategory'] as String?,
    );
  }
}
