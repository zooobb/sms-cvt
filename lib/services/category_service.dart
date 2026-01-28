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

    print('=== CategoryService.getMappings ===');
    print('从 SharedPreferences 读取的原始数据: $jsonStr');

    if (jsonStr == null) {
      print('shared_preferences 中没有数据，返回默认规则');
      return List.from(_defaultMappings);
    }

    try {
      final jsonData = jsonDecode(jsonStr) as List;
      final result = jsonData
          .map((e) => CategoryMapping.fromJson(e as Map<String, dynamic>))
          .toList();
      print('成功解析 ${result.length} 条规则');
      print('规则列表: $result');
      return result;
    } catch (e) {
      print('解析失败: $e，返回默认规则');
      return List.from(_defaultMappings);
    }
  }

  Future<void> saveMappings(List<CategoryMapping> mappings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = mappings.map((m) => m.toJson()).toList();
    await prefs.setString(_mappingsKey, jsonEncode(jsonData));
  }

  Future<void> addMapping(CategoryMapping mapping) async {
    print('=== CategoryService.addMapping ===');
    print('要添加的规则: $mapping');

    final mappings = await getMappings();
    print('当前规则数量: ${mappings.length}');

    if (mappings.any((m) => m.keyword == mapping.keyword)) {
      print('规则已存在，更新它');
      final updatedMappings = mappings.map((m) {
        if (m.keyword == mapping.keyword) {
          return mapping;
        }
        return m;
      }).toList();
      await saveMappings(updatedMappings);
    } else {
      print('新规则，添加到列表');
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
    print('=== CategoryService.matchCategory ===');
    print('短信内容: $content');

    final lowerContent = content.toLowerCase();
    final mappings = await getMappings();

    // 按关键字长度降序排序，优先匹配更具体的规则
    mappings.sort((a, b) => b.keyword.length.compareTo(a.keyword.length));

    print('共有 ${mappings.length} 条规则待匹配 (已排序)');


    for (final mapping in mappings) {
      final keywordLower = mapping.keyword.toLowerCase();
      print('检查规则: keyword="${mapping.keyword}", lowercase="$keywordLower", contains=${lowerContent.contains(keywordLower)}');
      if (lowerContent.contains(keywordLower)) {
        print('匹配成功! 返回: $mapping');
        return mapping;
      }
    }

    print('没有匹配的规则');
    return null;
  }
}
