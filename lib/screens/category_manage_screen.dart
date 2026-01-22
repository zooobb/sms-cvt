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
                  itemCount: mappings.length,
                  itemBuilder: (context, index) {
                    final mapping = mappings[index];
                    return _buildMappingCard(context, mapping, appState);
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

  Widget _buildMappingCard(
    BuildContext context,
    CategoryMapping mapping,
    AppState appState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEditDialog(context, mapping, appState),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mapping.keyword,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () =>
                            _showEditDialog(context, mapping, appState),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        onPressed: () =>
                            _showDeleteDialog(context, mapping, appState),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(context, '类型', mapping.type, colorScheme.primary),
                  if (mapping.category != null)
                    _buildChip(
                      context,
                      '一级分类',
                      mapping.category!,
                      colorScheme.secondary,
                    ),
                  if (mapping.secondaryCategory != null)
                    _buildChip(
                      context,
                      '二级分类',
                      mapping.secondaryCategory!,
                      colorScheme.tertiary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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
