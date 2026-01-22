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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                  const SizedBox(height: 4),
                  Text(
                    mapping.primaryCategory,
                    style: TextStyle(fontSize: 13, color: colorScheme.primary),
                  ),
                  if (mapping.secondaryCategory != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      mapping.secondaryCategory!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, mapping, appState),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMappingDialog(BuildContext context) {
    final keywordController = TextEditingController();
    final primaryController = TextEditingController();
    final secondaryController = TextEditingController();

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
            TextField(
              controller: primaryController,
              decoration: InputDecoration(
                labelText: '一级分类',
                hintText: '例如：收入、支出',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: secondaryController,
              decoration: InputDecoration(
                labelText: '二级分类（可选）',
                hintText: '例如：工资、餐饮',
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
              final primary = primaryController.text.trim();
              final secondary = secondaryController.text.trim().isEmpty
                  ? null
                  : secondaryController.text.trim();

              if (keyword.isNotEmpty && primary.isNotEmpty) {
                final mapping = CategoryMapping(
                  keyword: keyword,
                  primaryCategory: primary,
                  secondaryCategory: secondary,
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
}
