class WhatsAppHelper {
  /// Normalizes an Egyptian or international phone number for WhatsApp wa.me links.
  static String normalizePhone(String rawPhone) {
    String cleaned = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    // Convert Egyptian local format (01xxxxxxxxx) to international format (201xxxxxxxxx)
    if (cleaned.startsWith('01') && cleaned.length == 11) {
      cleaned = '20${cleaned.substring(1)}';
    }
    return cleaned;
  }

  /// Builds a direct wa.me URI for WhatsApp.
  static Uri buildWhatsAppUri({
    required String phone,
    required String message,
  }) {
    final normalized = normalizePhone(phone);
    final encodedMessage = Uri.encodeComponent(message);
    return Uri.parse('https://wa.me/$normalized?text=$encodedMessage');
  }

  /// Builds a personalized Arabic installment reminder message.
  static String buildInstallmentReminderMessage({
    required String memberName,
    required String gameyaName,
    required int monthNumber,
    required double amount,
    required String currency,
  }) {
    return 'السلام عليكم أخي الكريم $memberName،\n\n'
        'نذكركم بموعد سداد قسط جمعية ($gameyaName) الخاص بشهر $monthNumber.\n'
        '💰 القيمة المستحقة: ${amount.toStringAsFixed(0)} $currency.\n\n'
        'شاكرين ومقدرين حسن تعاونكم وحرصكم الطيب! 🙏';
  }

  /// Builds a direct wa.me 1-tap URI for an overdue or pending member reminder.
  static Uri buildOverdueReminderUri({
    required String phone,
    required String memberName,
    required String gameyaName,
    required int monthNumber,
    required double amount,
    String currency = 'EGP',
  }) {
    final message = buildInstallmentReminderMessage(
      memberName: memberName,
      gameyaName: gameyaName,
      monthNumber: monthNumber,
      amount: amount,
      currency: currency,
    );
    return buildWhatsAppUri(phone: phone, message: message);
  }

  /// Builds an invite message to join a Gameya.
  static String buildInviteMessage({
    required String gameyaName,
    required String organizerName,
    required String inviteCode,
  }) {
    return 'مرحباً بكم! يسعدنا دعوتكم للانضمام إلى جمعية ($gameyaName) المنظمة بواسطة $organizerName.\n\n'
        '📲 كود الانضمام الخاص بك: *$inviteCode*\n\n'
        'يرجى فتح التطبيق لتأكيد حصتكم وشهر القبض المفضل لديكم.';
  }

  /// Builds a group broadcast status summary to copy/paste directly into WhatsApp groups.
  static String buildGroupBroadcastSummary({
    required String gameyaName,
    required int currentMonth,
    required String beneficiaryName,
    required double totalCollected,
    required double totalExpected,
    required int paidCount,
    required int totalMembers,
    required String currency,
  }) {
    return '📢 *تقرير متابعة جمعية: $gameyaName*\n'
        '📅 *الشهر الحالي:* شهر $currentMonth\n'
        '🌟 *المستفيد من القبض هذا الشهر:* $beneficiaryName\n'
        '------------------------------------\n'
        '✅ عدد المشتركين المسددين: $paidCount من $totalMembers\n'
        '💵 إجمالي المحصل: ${totalCollected.toStringAsFixed(0)} من ${totalExpected.toStringAsFixed(0)} $currency\n'
        '------------------------------------\n'
        'نشكر جميع الأعضاء الحريصين على الانتظام ونسأل الله البركة للجميع!';
  }
}
