import '../../lib/core/utils/whatsapp_helper.dart';

void expect(dynamic actual, dynamic expected, [String? message]) {
  if (actual != expected) {
    throw Exception('Assertion failed: expected [$expected] but got [$actual]. ${message ?? ""}');
  }
}

void expectTrue(bool condition, [String? message]) {
  if (!condition) {
    throw Exception('Assertion failed: expected true but got false. ${message ?? ""}');
  }
}

void main() {
  print('Starting WhatsAppHelper test suite...');

  // Test 1: Egyptian local phone normalization (010... -> 2010...)
  print('Test 1: Phone normalization...');
  expect(WhatsAppHelper.normalizePhone('01012345678'), '201012345678');
  expect(WhatsAppHelper.normalizePhone('+201123456789'), '201123456789');
  expect(WhatsAppHelper.normalizePhone('012-3456-7890'), '201234567890');

  // Test 2: Reminder message formatting
  print('Test 2: Reminder message content...');
  final reminder = WhatsAppHelper.buildInstallmentReminderMessage(
    memberName: 'محمود',
    gameyaName: 'جمعية الشباب',
    monthNumber: 2,
    amount: 1500,
    currency: 'ج.م',
  );
  expectTrue(reminder.contains('محمود'));
  expectTrue(reminder.contains('1500'));
  expectTrue(reminder.contains('شهر 2'));

  // Test 3: Broadcast summary formatting
  print('Test 3: Group broadcast summary content...');
  final broadcast = WhatsAppHelper.buildGroupBroadcastSummary(
    gameyaName: 'جمعية العائلة',
    currentMonth: 4,
    beneficiaryName: 'هاني سعيد',
    totalCollected: 40000,
    totalExpected: 50000,
    paidCount: 8,
    totalMembers: 10,
    currency: 'ج.م',
  );
  expectTrue(broadcast.contains('هاني سعيد'));
  expectTrue(broadcast.contains('8 من 10'));
  expectTrue(broadcast.contains('40000'));

  // Test 4: Overdue reminder wa.me URI generation
  print('Test 4: Overdue reminder URI generation...');
  final uri = WhatsAppHelper.buildOverdueReminderUri(
    phone: '01099887766',
    memberName: 'خالد إبراهيم',
    gameyaName: 'جمعية العائلة الكبرى',
    monthNumber: 4,
    amount: 5000.0,
    currency: 'ج.م',
  );
  expectTrue(uri.toString().startsWith('https://wa.me/201099887766?text='));
  expectTrue(uri.toString().contains(Uri.encodeComponent('خالد إبراهيم')));
  expectTrue(uri.toString().contains(Uri.encodeComponent('5000')));

  print('SUCCESS: All WhatsAppHelper tests passed (4/4)!');
}
