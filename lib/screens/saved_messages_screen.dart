import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/sms_message.dart';

class SavedMessagesScreen extends StatelessWidget {
  const SavedMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('已保存短信'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          Consumer<AppState>(
            builder: (context, appState, child) {
              if (appState.savedMessages.isEmpty) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: '重新分类',
                    onPressed: () =>
                        _showRefreshConfirmDialog(context, appState),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    tooltip: '清空所有',
                    onPressed: () => _showClearConfirmDialog(context, appState),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.savedMessages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无保存的短信',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '扫描短信后会自动保存符合条件的短信到这里',
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  '符合条件的短信将自动保存到这里',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: appState.savedMessages.length,
                  itemBuilder: (context, index) {
                    final message = appState.savedMessages[index];
                    return _MessageCard(
                      message: message,
                      onTap: () => _showDetailDialog(context, message),
                      onDelete: () =>
                          _showDeleteConfirmDialog(context, message.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (messageDate == today) {
      dateStr = '今天';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateStr = '昨天';
    } else {
      dateStr = '${dateTime.month}月${dateTime.day}日';
    }

    return '$dateStr ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _showDetailDialog(BuildContext context, SavedSmsMessage message) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.sender,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatFullDateTime(message.receivedAt),
                                style: TextStyle(
                                  color: colorScheme.outline,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            message.content,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  context,
                                  '接收时间',
                                  _formatFullDateTime(message.receivedAt),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  '保存时间',
                                  _formatFullDateTime(message.savedAt),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  '类型',
                                  message.type,
                                  valueColor: colorScheme.primary,
                                ),
                                const SizedBox(height: 8),
                                if (message.category != null) ...[
                                  _buildInfoRow(
                                    context,
                                    '一级分类',
                                    message.category!,
                                  ),
                                ],
                                if (message.secondaryCategory != null) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    context,
                                    '二级分类',
                                    message.secondaryCategory!,
                                  ),
                                ],
                                if (message.type != '待分类') ...[
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: colorScheme.primary,
                                        width: 1,
                                      ),
                                    ),
                                    child: TextButton.icon(
                                      icon: Icon(
                                        Icons.edit,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      label: const Text('设置分类'),
                                      onPressed: () =>
                                          _showCategoryDialog(context, message),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          '$label：',
          style: TextStyle(color: colorScheme.outline, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条短信吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              context.read<AppState>().deleteMessage(id);
              Navigator.pop(ctx);
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

  void _showCategoryDialog(BuildContext context, SavedSmsMessage message) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeController = TextEditingController(
      text: message.type != '待分类' ? message.type : '',
    );
    final categoryController = TextEditingController(
      text: message.category ?? '',
    );
    final secondaryCategoryController = TextEditingController(
      text: message.secondaryCategory ?? '',
    );

    const typeOptions = ['支出', '收入', '转账'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('设置分类'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请选择类型和分类：'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
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
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
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
              final newType = typeController.text.trim().isEmpty
                  ? message.type
                  : typeController.text.trim();
              final newCategory = categoryController.text.trim().isEmpty
                  ? message.category
                  : categoryController.text.trim();
              final newSecondaryCategory =
                  secondaryCategoryController.text.trim().isEmpty
                  ? message.secondaryCategory
                  : secondaryCategoryController.text.trim();

              final updatedMessage = SavedSmsMessage(
                id: message.id,
                sender: message.sender,
                content: message.content,
                receivedAt: message.receivedAt,
                savedAt: message.savedAt,
                type: newType,
                category: newCategory,
                secondaryCategory: newSecondaryCategory,
                isManuallyClassified: true,
              );

              context.read<AppState>().updateMessage(updatedMessage);
              Navigator.pop(ctx);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有已保存的短信吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              appState.clearAllMessages();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  void _showRefreshConfirmDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认重新分类'),
        content: const Text('将对所有自动分类的短信重新应用最新的分类规则，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              appState.reclassifyMessages();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('重新分类完成'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final SavedSmsMessage message;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MessageCard({
    required this.message,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.message,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.sender,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatFullDateTime(message.receivedAt),
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoryText(message),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getContentPreview(message.content),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: colorScheme.outline),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('删除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (messageDate == today) {
      dateStr = '今天';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateStr = '昨天';
    } else {
      dateStr = '${dateTime.month}月${dateTime.day}日';
    }

    return '$dateStr ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _getCategoryText(SavedSmsMessage message) {
    if (message.type == '待分类') {
      return '待分类';
    }

    final parts = <String>[];
    parts.add(message.type);
    if (message.category != null) {
      parts.add(message.category!);
    }
    if (message.secondaryCategory != null) {
      parts.add(message.secondaryCategory!);
    }

    return parts.join(' / ');
  }

  String _getContentPreview(String content) {
    if (content.length <= 60) {
      return content;
    }
    return '${content.substring(0, 60)}...';
  }
}
