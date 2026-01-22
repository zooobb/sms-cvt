import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_mapping.dart';

class CategoryService {
  static const String _mappingsKey = 'category_mappings';

  static const List<CategoryMapping> _defaultMappings = [
    CategoryMapping(keyword: '入账', type: '收入', category: '工资'),
    CategoryMapping(keyword: '汇入', type: '收入', category: '转账'),
    CategoryMapping(keyword: '工资', type: '收入', category: '工资'),
    CategoryMapping(keyword: '支付', type: '支出'),
    CategoryMapping(keyword: '扣款', type: '支出'),
    CategoryMapping(keyword: '消费', type: '支出'),
    CategoryMapping(keyword: '转账', type: '转账'),
    CategoryMapping(keyword: '取款', type: '转账'),
    CategoryMapping(keyword: '打车', type: '支出', category: '交通'),
    CategoryMapping(keyword: '外卖', type: '支出', category: '餐饮'),
    CategoryMapping(keyword: '超市', type: '支出', category: '购物'),
    CategoryMapping(keyword: '购物', type: '支出', category: '购物'),
    CategoryMapping(keyword: '话费', type: '支出', category: '通讯'),
    CategoryMapping(keyword: '电费', type: '支出', category: '生活缴费'),
    CategoryMapping(keyword: '水费', type: '支出', category: '生活缴费'),
    CategoryMapping(keyword: '租金', type: '支出', category: '住房'),
    CategoryMapping(keyword: '房租', type: '支出', category: '住房'),
    CategoryMapping(keyword: '医疗', type: '支出', category: '医疗'),
  ];

  Future<List<CategoryMapping>> getMappings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_mappingsKey);

    if (jsonStr == null) {
      return List.from(_defaultMappings);
    }

    try {
      final jsonData = jsonDecode(jsonStr) as List;
      return jsonData
          .map((e) => CategoryMapping.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading category mappings: $e');
      return List.from(_defaultMappings);
    }
  }

  Future<void> saveMappings(List<CategoryMapping> mappings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = mappings.map((m) => m.toJson()).toList();
    await prefs.setString(_mappingsKey, jsonEncode(jsonData));
  }

  Future<void> addMapping(CategoryMapping mapping) async {
    final mappings = await getMappings();

    if (mappings.any((m) => m.keyword == mapping.keyword)) {
      final updatedMappings = mappings.map((m) {
        if (m.keyword == mapping.keyword) {
          return mapping;
        }
        return m;
      }).toList();
      await saveMappings(updatedMappings);
    } else {
      final updatedMappings = [...mappings, mapping];
      await saveMappings(updatedMappings);
    }
  }

  Future<void> removeMapping(String keyword) async {
    final mappings = await getMappings();
    final updatedMappings = mappings
        .where((m) => m.keyword != keyword)
        .toList();
    await saveMappings(updatedMappings);
  }

  Future<CategoryMapping?> matchCategory(String content) async {
    final lowerContent = content.toLowerCase();
    final mappings = await getMappings();

    for (final mapping in mappings) {
      if (lowerContent.contains(mapping.keyword.toLowerCase())) {
        return mapping;
      }
    }

    return null;
  }
}
