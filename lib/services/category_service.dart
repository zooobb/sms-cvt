import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_mapping.dart';

class CategoryService {
  static const String _mappingsKey = 'category_mappings';

  static const List<CategoryMapping> _defaultMappings = [
    CategoryMapping(
      keyword: '入账',
      primaryCategory: '收入',
      secondaryCategory: '工资',
      emoji: '💰',
    ),
    CategoryMapping(
      keyword: '汇入',
      primaryCategory: '收入',
      secondaryCategory: '转账',
      emoji: '💰',
    ),
    CategoryMapping(
      keyword: '工资',
      primaryCategory: '收入',
      secondaryCategory: '工资',
      emoji: '💰',
    ),
    CategoryMapping(keyword: '支付', primaryCategory: '支出', emoji: '💸'),
    CategoryMapping(keyword: '扣款', primaryCategory: '支出', emoji: '💸'),
    CategoryMapping(keyword: '消费', primaryCategory: '支出', emoji: '💸'),
    CategoryMapping(keyword: '转账', primaryCategory: '支出', emoji: '💸'),
    CategoryMapping(keyword: '取款', primaryCategory: '支出', emoji: '💸'),
    CategoryMapping(keyword: '余额', primaryCategory: '余额', emoji: '💰'),
    CategoryMapping(keyword: '打车', primaryCategory: '交通', emoji: '🚗'),
    CategoryMapping(keyword: '外卖', primaryCategory: '餐饮', emoji: '🍔'),
    CategoryMapping(keyword: '超市', primaryCategory: '购物', emoji: '🛒'),
    CategoryMapping(keyword: '购物', primaryCategory: '购物', emoji: '🛒'),
    CategoryMapping(keyword: '话费', primaryCategory: '通讯', emoji: '📱'),
    CategoryMapping(keyword: '电费', primaryCategory: '生活缴费', emoji: '⚡'),
    CategoryMapping(keyword: '水费', primaryCategory: '生活缴费', emoji: '💧'),
    CategoryMapping(keyword: '租金', primaryCategory: '住房', emoji: '🏠'),
    CategoryMapping(keyword: '房租', primaryCategory: '住房', emoji: '🏠'),
    CategoryMapping(keyword: '医疗', primaryCategory: '医疗', emoji: '💊'),
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

  CategoryMapping? matchCategory(String content) {
    final lowerContent = content.toLowerCase();

    for (final mapping in _defaultMappings) {
      if (lowerContent.contains(mapping.keyword.toLowerCase())) {
        return mapping;
      }
    }

    return null;
  }
}
