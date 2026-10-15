import '../../lib/data/services/invite_service.dart';

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
  print('Starting InviteService test suite...');

  // Test 1: Deep link generation
  print('Test 1: Deep link generation...');
  final deepLink = InviteService.buildDeepLink('INV-XYZ123');
  expect(deepLink, 'https://smartgameya.app/join/INV-XYZ123');

  // Test 2: Full invite payload generation (with recipient phone)
  print('Test 2: Full invite payload generation with recipient phone...');
  final payload = InviteService.generateInvitePayload(
    gameyaName: 'جمعية العائلة الكبرى',
    organizerName: 'أحمد حسن',
    inviteCode: 'INV-FAMILY2026',
    recipientPhone: '01012345678',
  );

  expect(payload.inviteCode, 'INV-FAMILY2026');
  expect(payload.qrCodeData, 'https://smartgameya.app/join/INV-FAMILY2026');
  expectTrue(payload.shareText.contains('INV-FAMILY2026'), 'Share text must include code');
  expectTrue(payload.shareText.contains('جمعية العائلة الكبرى'), 'Share text must include Gameya name');
  expectTrue(payload.shareText.contains('أحمد حسن'), 'Share text must include Organizer name');
  expectTrue(payload.whatsAppUrl.toString().startsWith('https://wa.me/201012345678'), 'WhatsApp URL must use normalized phone');

  // Test 3: Invite payload without specific recipient (for group or OS share)
  print('Test 3: Invite payload for general sharing...');
  final generalPayload = InviteService.generateInvitePayload(
    gameyaName: 'جمعية الزملاء',
    organizerName: 'محمود علي',
    inviteCode: 'INV-WORK2026',
  );
  expectTrue(generalPayload.whatsAppUrl.toString().startsWith('https://wa.me/?text='), 'General WhatsApp link should open chat picker');

  print('SUCCESS: All InviteService tests passed (3/3)!');
}
