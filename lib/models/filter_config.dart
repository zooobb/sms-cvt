import 'sender_keyword_rule.dart';

class FilterConfig {
  final List<SenderKeywordRule> rules;
  final bool isEnabled;

  FilterConfig({required this.rules, this.isEnabled = false});

  FilterConfig copyWith({List<SenderKeywordRule>? rules, bool? isEnabled}) {
    return FilterConfig(
      rules: rules ?? this.rules,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  bool shouldSaveMessage(String senderAddress, String messageBody) {
    if (rules.isEmpty) {
      return false;
    }

    for (final rule in rules) {
      final normalizedSender = rule.sender.toLowerCase().trim();
      final normalizedAddress = senderAddress.toLowerCase().trim();

      final senderMatch =
          normalizedAddress == normalizedSender ||
          normalizedAddress.contains(normalizedSender);

      if (senderMatch) {
        return rule.matchesContent(messageBody);
      }
    }

    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'rules': rules.map((r) => r.toJson()).toList(),
      'isEnabled': isEnabled,
    };
  }

  factory FilterConfig.fromJson(Map<String, dynamic> json) {
    final rulesList = json['rules'] as List?;
    final rules =
        rulesList
            ?.map((r) => SenderKeywordRule.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [];

    return FilterConfig(
      rules: rules,
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }

  factory FilterConfig.empty() {
    return FilterConfig(rules: [], isEnabled: false);
  }
}
