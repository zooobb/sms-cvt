import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/category_mapping.dart';

class CategoryManageScreen extends StatelessWidget {
  const CategoryManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('分类管理'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final mappings = appState.categoryMappings;

          if (mappings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无分类映射',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '添加关键字和对应分类',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          // 按类型+一级分类+二级分类分组
          final groupedData = _groupMappings(mappings);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '分类规则',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: groupedData.length,
                  itemBuilder: (context, typeIndex) {
                    final typeEntry = groupedData.entries.elementAt(typeIndex);
                    return _buildTypeSection(context, typeEntry.key, typeEntry.value, appState);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMappingDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 按类型、一级分类、二级分类分组数据
  Map<String, Map<String, Map<String, List<CategoryMapping>>>> _groupMappings(List<CategoryMapping> mappings) {
    final result = <String, Map<String, Map<String, List<CategoryMapping>>>>{};

    for (final mapping in mappings) {
      final type = mapping.type;
      final category = mapping.category ?? '未分类';
      final secondary = mapping.secondaryCategory ?? '';

      result.putIfAbsent(type, () => {});
      result[type]!.putIfAbsent(category, () => {});
      result[type]![category]!.putIfAbsent(secondary, () => []).add(mapping);
    }

    return result;
  }

  /// 构建类型分组（一级）
  Widget _buildTypeSection(
    BuildContext context,
    String type,
    Map<String, Map<String, List<CategoryMapping>>> categories,
    AppState appState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = _getTypeColor(type, colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: typeColor.withOpacity(0.3)),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: typeColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${categories.values.fold(0, (sum, c) => sum + c.values.fold(0, (s, list) => s + list.length))}条)',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        children: [
          // 一级分类列表
          ...categories.entries.map((catEntry) {
            return _buildCategorySection(context, catEntry.key, catEntry.value, appState);
          }).toList(),
        ],
      ),
    );
  }

  /// 构建一级分类分组（二级）
  Widget _buildCategorySection(
    BuildContext context,
    String category,
    Map<String, List<CategoryMapping>> secondaries,
    AppState appState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ExpansionTile(
        title: Text(
          category,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${secondaries.values.fold(0, (sum, list) => sum + list.length)}条规则',
          style: TextStyle(fontSize: 12, color: colorScheme.outline),
        ),
        children: [
          // 二级分类列表
          ...secondaries.entries.map((secEntry) {
            final secondary = secEntry.key;
            final mappings = secEntry.value;
            return _buildSecondarySection(context, secondary, mappings, appState);
          }).toList(),
        ],
      ),
    );
  }

  /// 构建二级分类分组（三级），显示关键字列表
  Widget _buildSecondarySection(
    BuildContext context,
    String secondary,
    List<CategoryMapping> mappings,
    AppState appState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUncategorized = secondary.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUncategorized)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                secondary,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          // 关键字列表
          ...mappings.map((mapping) => _buildKeywordCard(context, mapping, appState)).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 构建关键字卡片（末级）
  Widget _buildKeywordCard(
    BuildContext context,
    CategoryMapping mapping,
    AppState appState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(right: 16, top: 4, bottom: 4),
      child: InkWell(
        onTap: () => _showEditDialog(context, mapping, appState),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  mapping.keyword,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showEditDialog(context, mapping, appState),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                color: Colors.red,
                onPressed: () => _showDeleteDialog(context, mapping, appState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type, ColorScheme colorScheme) {
    switch (type) {
      case '支出':
        return colorScheme.error;
      case '收入':
        return colorScheme.primary;
      case '转账':
        return colorScheme.tertiary;
      default:
        return colorScheme.outline;
    }
  }

  void _showAddMappingDialog(BuildContext context) {
    final keywordController = TextEditingController();
    final typeController = TextEditingController();
    final categoryController = TextEditingController();
    final secondaryCategoryController = TextEditingController();

    const typeOptions = ['支出', '收入', '转账'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加分类映射'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keywordController,
              decoration: InputDecoration(
                labelText: '关键字',
                hintText: '例如：入账、支付、工资',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: typeController.text.isEmpty
                  ? null
                  : typeController.text,
              decoration: InputDecoration(
                labelText: '类型',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: typeOptions.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) {
                typeController.text = newValue ?? '';
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: '一级分类（可选）',
                hintText: '例如：工资、餐饮',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: secondaryCategoryController,
              decoration: InputDecoration(
                labelText: '二级分类（可选）',
                hintText: '例如：早餐、午餐',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final keyword = keywordController.text.trim();
              final type = typeController.text.trim();
              final category = categoryController.text.trim().isEmpty
                  ? null
                  : categoryController.text.trim();
              final secondaryCategory =
                  secondaryCategoryController.text.trim().isEmpty
                  ? null
                  : secondaryCategoryController.text.trim();

              if (keyword.isNotEmpty && type.isNotEmpty) {
                final mapping = CategoryMapping(
                  keyword: keyword,
                  type: type,
                  category: category,
                  secondaryCategory: secondaryCategory,
                );

                Navigator.pop(ctx);
                context.read<AppState>().addCategoryMapping(mapping);
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    CategoryMapping mapping,
    AppState appState,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除分类规则"${mapping.keyword}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              appState.removeCategoryMapping(mapping.keyword);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    CategoryMapping mapping,
    AppState appState,
  ) {
    final keywordController = TextEditingController(text: mapping.keyword);
    final typeController = TextEditingController(text: mapping.type);
    final categoryController = TextEditingController(
      text: mapping.category ?? '',
    );
    final secondaryCategoryController = TextEditingController(
      text: mapping.secondaryCategory ?? '',
    );

    const typeOptions = ['支出', '收入', '转账'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑分类映射'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keywordController,
              decoration: InputDecoration(
                labelText: '关键字',
                hintText: '例如：入账、支付、工资',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: typeController.text.isEmpty ? null : typeController.text,
              decoration: InputDecoration(
                labelText: '类型',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: typeOptions.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) {
                typeController.text = newValue ?? '';
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: '一级分类（可选）',
                hintText: '例如：工资、餐饮',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: secondaryCategoryController,
              decoration: InputDecoration(
                labelText: '二级分类（可选）',
                hintText: '例如：早餐、午餐',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final keyword = keywordController.text.trim();
              final type = typeController.text.trim();
              final category = categoryController.text.trim().isEmpty
                  ? null
                  : categoryController.text.trim();
              final secondaryCategory =
                  secondaryCategoryController.text.trim().isEmpty
                  ? null
                  : secondaryCategoryController.text.trim();

              if (keyword.isNotEmpty && type.isNotEmpty) {
                final newMapping = CategoryMapping(
                  keyword: keyword,
                  type: type,
                  category: category,
                  secondaryCategory: secondaryCategory,
                );

                Navigator.pop(ctx);
                appState.removeCategoryMapping(mapping.keyword);
                appState.addCategoryMapping(newMapping);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
