import '../../lib/core/utils/math_validator.dart';
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

void main() {
  print('Starting MathValidator test suite...');

  // Test 1: Split share group validation (max 4 partners, sum = 1.0)
  print('Test 1: Split share partner limits and sums...');
  final validTwoPartners = [
    MemberShare(id: '1', gameyaId: 'g1', shareGroupId: 1, memberName: 'أحمد', phone: '0101', shareRatio: 0.5, installmentAmount: 2500, payoutMonth: 1),
    MemberShare(id: '2', gameyaId: 'g1', shareGroupId: 1, memberName: 'محمد', phone: '0102', shareRatio: 0.5, installmentAmount: 2500, payoutMonth: 2),
  ];
  expectTrue(MathValidator.validateSplitShareGroup(validTwoPartners), 'Two 50% partners is valid');

  final invalidFivePartners = [
    MemberShare(id: '1', gameyaId: 'g1', shareGroupId: 1, memberName: 'A', phone: '01', shareRatio: 0.2, installmentAmount: 1000, payoutMonth: 1),
    MemberShare(id: '2', gameyaId: 'g1', shareGroupId: 1, memberName: 'B', phone: '02', shareRatio: 0.2, installmentAmount: 1000, payoutMonth: 1),
    MemberShare(id: '3', gameyaId: 'g1', shareGroupId: 1, memberName: 'C', phone: '03', shareRatio: 0.2, installmentAmount: 1000, payoutMonth: 1),
    MemberShare(id: '4', gameyaId: 'g1', shareGroupId: 1, memberName: 'D', phone: '04', shareRatio: 0.2, installmentAmount: 1000, payoutMonth: 1),
    MemberShare(id: '5', gameyaId: 'g1', shareGroupId: 1, memberName: 'E', phone: '05', shareRatio: 0.2, installmentAmount: 1000, payoutMonth: 1),
  ];
  expectTrue(!MathValidator.validateSplitShareGroup(invalidFivePartners), '5 partners exceeds max limit of 4');

  // Test 2: Full Gameya Monthly 100% Invariant
  print('Test 2: Full Gameya 100% monthly payout invariant...');
  // A 3-month Gameya
  final members = [
    // Month 1: 1 full share (100%)
    MemberShare(id: '1', gameyaId: 'g1', shareGroupId: 1, memberName: 'سارة', phone: '0101', shareRatio: 1.0, installmentAmount: 5000, payoutMonth: 1),
    // Month 2 & 3: Two 50% split partners in different months!
    MemberShare(id: '2', gameyaId: 'g1', shareGroupId: 2, memberName: 'كريم', phone: '0102', shareRatio: 0.5, installmentAmount: 2500, payoutMonth: 2),
    MemberShare(id: '3', gameyaId: 'g1', shareGroupId: 2, memberName: 'طارق', phone: '0103', shareRatio: 0.5, installmentAmount: 2500, payoutMonth: 3),
    // Another split pair to balance Month 2 & 3!
    MemberShare(id: '4', gameyaId: 'g1', shareGroupId: 3, memberName: 'منى', phone: '0104', shareRatio: 0.5, installmentAmount: 2500, payoutMonth: 2),
    MemberShare(id: '5', gameyaId: 'g1', shareGroupId: 3, memberName: 'هدى', phone: '0105', shareRatio: 0.5, installmentAmount: 2500, payoutMonth: 3),
  ];

  final result = MathValidator.validateGameyaFinancials(
    totalMonths: 3,
    totalPot: 50000,
    allMembers: members,
  );

  expectTrue(result.isValid, 'All 3 months should sum to exactly 100%');
  expect(result.errors.length, 0);

  // Test 3: Turn swap ratio equivalence
  print('Test 3: Turn swap ratio equivalence...');
  final memberHalf1 = members[1]; // 0.5
  final memberHalf2 = members[3]; // 0.5
  final memberFull = members[0];  // 1.0

  expectTrue(MathValidator.canSwapTurns(memberHalf1, memberHalf2), 'Can swap matching 50% ratios');
  expectTrue(!MathValidator.canSwapTurns(memberHalf1, memberFull), 'Cannot swap mismatched 50% with 100%');

  print('SUCCESS: All MathValidator tests passed (3/3)!');
}
