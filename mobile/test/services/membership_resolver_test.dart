import '../../lib/core/utils/whatsapp_helper.dart';
import '../../lib/domain/models/member_share.dart';

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

class MembershipResolver {
  /// Resolves which pre-registered shares match the user's phone and links their authenticated UID.
  static List<MemberShare> linkMemberSharesByPhone({
    required String rawPhone,
    required String authenticatedUserId,
    required List<MemberShare> allExistingShares,
  }) {
    final normalized = WhatsAppHelper.normalizePhone(rawPhone);
    final List<MemberShare> resolved = [];

    for (final share in allExistingShares) {
      if (WhatsAppHelper.normalizePhone(share.phone) == normalized) {
        resolved.add(share.copyWith(userId: authenticatedUserId));
      }
    }
    return resolved;
  }
}

void main() {
  print('Starting MembershipResolver unit test suite...');

  final sampleShares = [
    MemberShare(id: 's1', gameyaId: 'g1', shareGroupId: 1, memberName: 'أحمد محمود', phone: '01012345678', shareRatio: 1.0, installmentAmount: 5000, payoutMonth: 1),
    MemberShare(id: 's2', gameyaId: 'g2', shareGroupId: 1, memberName: 'أحمد محمود', phone: '+201012345678', shareRatio: 0.5, installmentAmount: 2500, payoutMonth: 3),
    MemberShare(id: 's3', gameyaId: 'g1', shareGroupId: 2, memberName: 'كريم خالد', phone: '01199998888', shareRatio: 1.0, installmentAmount: 5000, payoutMonth: 2),
  ];

  print('Test 1: Auto-matching shares by local Egyptian format...');
  final matched = MembershipResolver.linkMemberSharesByPhone(
    rawPhone: '01012345678',
    authenticatedUserId: 'user_ahmed_123',
    allExistingShares: sampleShares,
  );

  expect(matched.length, 2, 'Should match 2 shares across g1 and g2');
  expect(matched[0].userId, 'user_ahmed_123');
  expect(matched[1].userId, 'user_ahmed_123');

  print('Test 2: Non-matching phone number...');
  final noMatch = MembershipResolver.linkMemberSharesByPhone(
    rawPhone: '01500000000',
    authenticatedUserId: 'user_other',
    allExistingShares: sampleShares,
  );
  expect(noMatch.length, 0, 'No shares should match unknown number');

  print('SUCCESS: All MembershipResolver tests passed (2/2)!');
}
