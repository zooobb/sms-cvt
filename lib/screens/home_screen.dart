import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';
import 'rules_screen.dart';
import 'saved_messages_screen.dart';
import 'category_manage_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'SMS Filter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 状态卡片
                _buildStatusCard(context, appState),
                const SizedBox(height: 20),

                // 配置入口
                _buildConfigSection(context, appState),
                const SizedBox(height: 20),

                // 操作按钮
                _buildActionsSection(context, appState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, AppState appState) {
    final colorScheme = Theme.of(context).colorScheme;
    final isReady = appState.hasPermissions && appState.config.rules.isNotEmpty;

    return Card(
      color: isReady
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.errorContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isReady ? Icons.check_circle : Icons.info_outline,
              size: 48,
              color: isReady ? colorScheme.primary : colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              isReady ? '准备就绪' : '需要配置',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isReady ? colorScheme.primary : colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            if (!appState.hasPermissions)
              _buildStatusItem(
                context,
                '短信权限未授予',
                false,
                onTap: () => appState.requestPermissions(),
                onSettings: () => _openAppSettings(),
              ),
            if (appState.hasPermissions)
              _buildStatusItem(context, '短信权限已授予', true),
            _buildStatusItem(
              context,
              '已配置 ${appState.config.rules.length} 个发送规则',
              appState.config.rules.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String text,
    bool isOk, {
    VoidCallback? onTap,
    VoidCallback? onSettings,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 20,
            color: isOk ? colorScheme.primary : colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isOk ? colorScheme.onSurface : colorScheme.outline,
              ),
            ),
          ),
          if (onTap != null)
            TextButton(onPressed: onTap, child: const Text('授权')),
          if (onSettings != null)
            TextButton.icon(
              onPressed: onSettings,
              icon: const Icon(Icons.settings),
              label: const Text('设置'),
            ),
        ],
      ),
    );

    return content;
  }

  Future<void> _openAppSettings() async {
    if (Platform.isAndroid) {
      try {
        await Permission.sms.request();
      } catch (e) {
        print('Requesting SMS permission: $e');
      }

      try {
        await openAppSettings();
      } catch (e) {
        print('Opening app settings failed: $e');
      }
    } else if (Platform.isIOS) {
      try {
        await openAppSettings();
      } catch (e) {
        print('Opening app settings failed: $e');
      }
    }
  }

  Widget _buildConfigSection(BuildContext context, AppState appState) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '过滤规则',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              _buildConfigTile(
                context,
                icon: Icons.rule,
                title: '发送人与关键词',
                subtitle: appState.config.rules.isEmpty
                    ? '点击添加发送人及专属关键词'
                    : '已配置 ${appState.config.rules.length} 个规则',
                badgeCount: appState.config.rules.length,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RulesScreen()),
                ),
              ),
              Divider(height: 1, indent: 56, color: colorScheme.outlineVariant),
              _buildConfigTile(
                context,
                icon: Icons.inbox,
                title: '已保存短信',
                subtitle: '查看所有已保存的短信记录',
                badgeCount: appState.savedMessages.length,
                badgeColor: colorScheme.secondary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SavedMessagesScreen(),
                  ),
                ),
              ),
              _buildConfigTile(
                context,
                icon: Icons.category,
                title: '分类管理',
                subtitle: '管理短信分类映射',
                badgeCount: appState.categoryMappings.length,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoryManageScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int badgeCount = 0,
    Color? badgeColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colorScheme.outline, fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor ?? colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$badgeCount',
                style: TextStyle(
                  color: badgeColor != null
                      ? colorScheme.onTertiary
                      : colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: colorScheme.outline),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildActionsSection(BuildContext context, AppState appState) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '操作',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.search,
                label: '扫描短信',
                onPressed:
                    appState.hasPermissions && appState.config.rules.isNotEmpty
                    ? () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('正在扫描现有短信...'),
                              ],
                            ),
                            duration: const Duration(seconds: 10),
                          ),
                        );
                        final count = await appState.scanExistingMessages();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('扫描完成，保存了 $count 条新短信'),
                              backgroundColor: colorScheme.primary,
                            ),
                          );
                        }
                      }
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.download,
                label: '导出数据',
                onPressed: appState.savedMessages.isNotEmpty
                    ? () async {
                        if (context.mounted) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (ctx) => _ExportBottomSheet(),
                          );
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        // 增强按钮的可点击性
        minimumSize: const Size(120, 56),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ExportBottomSheet extends StatefulWidget {
  @override
  State<_ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<_ExportBottomSheet> {
  String? _exportedFilePath;
  bool _isExporting = false;
  late Future<String> _jsonFuture;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _jsonFuture = context.read<AppState>().exportMessages();
  }

  Future<void> _exportToFile() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final appState = context.read<AppState>();
      final file = await appState.exportDataToFile(
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _exportedFilePath = file?.path;
        _isExporting = false;
      });

      if (file != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('文件已导出到: ${file.path}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _refreshJson() {
    setState(() {
      _exportedFilePath = null;
      _jsonFuture = context.read<AppState>().exportMessages(
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? result;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          DateTime? tempStart = _startDate;
          DateTime? tempEnd = _endDate;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '选择时间范围',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: tempStart ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      locale: const Locale('zh', 'CN'),
                    );
                    if (date != null) {
                      setModalState(() {
                        tempStart = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          tempStart != null
                              ? _formatDate(tempStart!)
                              : '选择开始日期',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: tempEnd ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      locale: const Locale('zh', 'CN'),
                    );
                    if (date != null) {
                      setModalState(() {
                        tempEnd = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          tempEnd != null ? _formatDate(tempEnd!) : '选择结束日期',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempStart = null;
                            tempEnd = null;
                          });
                        },
                        child: const Text('清除'),
                      ),
                    ),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (tempStart != null && tempEnd != null) {
                            result = DateTimeRange(
                              start: DateTime(
                                tempStart!.year,
                                tempStart!.month,
                                tempStart!.day,
                              ),
                              end: DateTime(
                                tempEnd!.year,
                                tempEnd!.month,
                                tempEnd!.day,
                                23,
                                59,
                                59,
                              ),
                            );
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text('确认'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    if (result != null) {
      setState(() {
        _startDate = result!.start;
        _endDate = result!.end;
      });
      _refreshJson();
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _refreshJson();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'JSON 数据',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_exportedFilePath != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '已导出',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                FilledButton.icon(
                  onPressed: _isExporting ? null : _exportToFile,
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download, size: 18),
                  label: Text(_isExporting ? '导出中...' : '下载'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.date_range, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _selectDateRange,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _startDate != null && _endDate != null
                                  ? '${_formatDate(_startDate!)} 至 ${_formatDate(_endDate!)}'
                                  : '选择时间范围（可选）',
                              style: TextStyle(
                                fontSize: 14,
                                color: _startDate != null
                                    ? colorScheme.onSurface
                                    : colorScheme.outline,
                              ),
                            ),
                          ),
                          if (_startDate != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: InkWell(
                                onTap: _clearDateRange,
                                borderRadius: BorderRadius.circular(12),
                                child: Icon(
                                  Icons.clear,
                                  size: 20,
                                  color: colorScheme.outline,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_exportedFilePath != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '导出目录',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _exportedFilePath!,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<String>(
              future: _jsonFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '加载数据失败',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final json = snapshot.data ?? '';
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    json,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
