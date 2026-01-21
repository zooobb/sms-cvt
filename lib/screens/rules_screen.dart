import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/sender_keyword_rule.dart';

class RegexTemplate {
  final String name;
  final String pattern;
  final String description;

  const RegexTemplate({
    required this.name,
    required this.pattern,
    required this.description,
  });
}

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  final _senderController = TextEditingController();
  final _keywordController = TextEditingController();
  final _focusNode = FocusNode();
  final Map<String, bool> _expandedRules = {};
  String? _regexError;

  static final List<RegexTemplate> _commonTemplates = [
    RegexTemplate(
      name: '入账金额',
      pattern: r'入账.*?\d+\.?\d*元',
      description: '匹配包含"入账"后跟任意数字的金额',
    ),
    RegexTemplate(
      name: '支付金额',
      pattern: r'支付\d+\.?\d*元',
      description: '匹配"支付"后跟数字的金额',
    ),
    RegexTemplate(
      name: '账户四位数字',
      pattern: r'账户\d{4}',
      description: '匹配"账户"后跟4位数字',
    ),
    RegexTemplate(
      name: '完整支付确认',
      pattern: r'账户\d{4}向您支付\d+\.?\d*元',
      description: '匹配完整支付确认短信',
    ),
    RegexTemplate(
      name: '取款通知',
      pattern: r'取款\d+\.?\d*元',
      description: '匹配取款金额',
    ),
    RegexTemplate(
      name: '消费记录',
      pattern: r'消费\d+\.?\d*元',
      description: '匹配消费金额',
    ),
    RegexTemplate(name: '转账', pattern: r'转账\d+\.?\d*元', description: '匹配转账金额'),
  ];

  @override
  void dispose() {
    _senderController.dispose();
    _keywordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isValidRegex(String pattern) {
    try {
      RegExp(pattern);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _validateRegex() {
    final text = _keywordController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _regexError = null;
      });
      return;
    }

    if (_isValidRegex(text)) {
      setState(() {
        _regexError = null;
      });
    } else {
      setState(() {
        _regexError = '正则表达式格式错误';
      });
    }
  }

  void _toggleExpand(String sender) {
    setState(() {
      if (_expandedRules[sender] == true) {
        _expandedRules.remove(sender);
      } else {
        _expandedRules[sender] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('过滤规则'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final rules = appState.config.rules;

          if (rules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rule_outlined,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无规则',
                    style: TextStyle(fontSize: 18, color: colorScheme.outline),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '添加发送人和关键词开始过滤',
                    style: TextStyle(fontSize: 14, color: colorScheme.outline),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index];
              return _buildRuleCard(context, rule, appState);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRuleDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRuleCard(
    BuildContext context,
    SenderKeywordRule rule,
    AppState appState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExpanded = _expandedRules[rule.sender] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person, color: colorScheme.primary),
            ),
            title: Text(
              rule.sender,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${rule.keywords.length} 个关键词/正则表达式',
              style: TextStyle(color: colorScheme.outline, fontSize: 13),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: colorScheme.error),
                  onPressed: () =>
                      _showDeleteRuleDialog(context, rule.sender, appState),
                ),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () => _toggleExpand(rule.sender),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: isExpanded
                ? _buildExpandedContent(context, rule, appState)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    SenderKeywordRule rule,
    AppState appState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rule.keywords.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '暂无关键词',
                  style: TextStyle(color: colorScheme.outline),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rule.keywords.map((keyword) {
                  return Chip(
                    label: Text(keyword),
                    onDeleted: () {
                      appState.removeKeywordForSender(rule.sender, keyword);
                    },
                    deleteIcon: Icon(
                      Icons.close,
                      size: 18,
                      color: colorScheme.outline,
                    ),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: () => _showAddKeywordDialog(context, rule.sender),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text('添加关键词/正则'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRuleDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加发送人'),
        content: TextField(
          autofocus: true,
          controller: _senderController,
          decoration: InputDecoration(
            labelText: '发送人号码或名称',
            hintText: '例如: 95555、10086、招商银行',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
          ),
          onSubmitted: (_) {
            Navigator.pop(ctx);
            context.read<AppState>().addRule(_senderController.text.trim());
            _senderController.clear();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppState>().addRule(_senderController.text.trim());
              _senderController.clear();
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddKeywordDialog(BuildContext context, String sender) {
    final colorScheme = Theme.of(context).colorScheme;
    _regexError = null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('添加 $sender 的关键词'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                autofocus: true,
                controller: _keywordController,
                onChanged: (_) => _validateRegex(),
                decoration: InputDecoration(
                  labelText: '关键词或正则表达式',
                  hintText: '例如: 入账、账户\\d{4}向您支付',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLowest,
                  errorText: _regexError,
                  suffixIcon: _regexError != null
                      ? const Icon(Icons.error, color: Colors.red, size: 20)
                      : null,
                ),
                onSubmitted: (_) {
                  Navigator.pop(ctx);
                  context.read<AppState>().addKeywordForSender(
                    sender,
                    _keywordController.text.trim(),
                  );
                  _keywordController.clear();
                  setState(() {
                    _regexError = null;
                  });
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '正则表达式示例',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 入账 - 普通关键词\n'
                      '• 账户\\d{4} - 匹配"账户"后跟4位数字\n'
                      '• 支付\\d+\\.?\\d*元 - 匹配金额\n'
                      '• 入账.*?\\d+\\.?\\d*元 - 入账金额',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_commonTemplates.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '常用模板（点击使用）',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonTemplates.map((template) {
                        return ActionChip(
                          label: Text(template.name),
                          onPressed: () {
                            _keywordController.text = template.pattern;
                            _validateRegex();
                          },
                          backgroundColor: colorScheme.surfaceContainerHighest,
                        );
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: _regexError == null
                ? () {
                    Navigator.pop(ctx);
                    context.read<AppState>().addKeywordForSender(
                      sender,
                      _keywordController.text.trim(),
                    );
                    _keywordController.clear();
                    setState(() {
                      _regexError = null;
                    });
                  }
                : null,
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRuleDialog(
    BuildContext context,
    String sender,
    AppState appState,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除发送人 "$sender" 及其所有关键词吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              appState.removeRule(sender);
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
