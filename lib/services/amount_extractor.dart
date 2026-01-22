class AmountExtractor {
  static String? extractAmount({
    required String content,
    required String? tag,
    String? explicitAmount,
  }) {
    // 1. 如果有明确设置的金额，优先使用
    if (explicitAmount != null) {
      return explicitAmount;
    }

    // 2. 尝试从tag中提取金额
    if (tag != null) {
      final amountMatch = RegExp(r'(\d+\.?\d*)').firstMatch(tag);
      if (amountMatch != null) {
        final extracted = amountMatch.group(0);
        if (extracted != null &&
            _isValidTransactionAmount(extracted, content)) {
          return extracted;
        }
      }
    }

    // 3. 尝试从content中提取金额（tag的备选方案）
    final amountMatch = RegExp(r'(\d+\.?\d*)').firstMatch(content);
    if (amountMatch != null) {
      final extracted = amountMatch.group(0);
      if (extracted != null && _isValidTransactionAmount(extracted, content)) {
        return extracted;
      }
    }

    return null;
  }

  static bool _isValidTransactionAmount(String amount, String content) {
    // 检查金额是否在合理的交易范围内
    final amountValue = double.tryParse(amount.replaceAll(',', ''));
    if (amountValue == null) return false;

    // 排除明显不合理的大额
    if (amountValue > 1000000) return false;

    // 检查金额后面是否有"元"字
    final amountIndex = content.indexOf(amount);
    if (amountIndex != -1) {
      final afterAmount = content.substring(amountIndex + amount.length);

      // 如果金额后面紧接着就是"元"，很可能是交易金额
      if (afterAmount.trimLeft().startsWith('元')) {
        return true;
      }

      // 如果金额后面跟着空格或标点，也可能是交易金额
      if (afterAmount.trimLeft().startsWith('，') ||
          afterAmount.trimLeft().startsWith('。') ||
          afterAmount.trimLeft().startsWith('；')) {
        return true;
      }

      // 如果金额在句子末尾
      if (amountIndex + amount.length >= content.length - 10) {
        return true;
      }
    }

    return false;
  }

  static String? extractTag(String content) {
    final tagMatch = RegExp(r'【(.+?)】').firstMatch(content);
    return tagMatch?.group(1)?.trim();
  }

  static TransactionType detectTransactionType(String content, String amount) {
    final lowerContent = content.toLowerCase();

    if (lowerContent.contains('汇入') ||
        lowerContent.contains('入账') ||
        lowerContent.contains('收入') ||
        lowerContent.contains('存入')) {
      return TransactionType.income;
    }

    if (lowerContent.contains('支付') ||
        lowerContent.contains('扣款') ||
        lowerContent.contains('消费') ||
        lowerContent.contains('转账')) {
      return TransactionType.expense;
    }

    return TransactionType.unknown;
  }
}

enum TransactionType { income, expense, unknown }
