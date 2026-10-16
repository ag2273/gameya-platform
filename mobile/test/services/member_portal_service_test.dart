import '../../lib/data/services/member_portal_service.dart';
import '../../lib/domain/models/gameya.dart';
import '../../lib/domain/models/member_share.dart';
import '../../lib/domain/models/installment.dart';

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
  print('Starting MemberPortalService test suite...');

  final sampleGameya = Gameya(
    id: 'g1',
    name: 'جمعية العائلة الكبرى',
    organizerId: 'org1',
    totalPot: 50000.0,
    monthlyShareInstallment: 5000.0,
    totalMonths: 10,
    startDate: DateTime(2026, 1, 1),
    status: GameyaStatus.active,
    inviteCode: 'INV-123',
    currency: 'EGP',
    gracePeriodDays: 7,
    createdAt: DateTime(2026, 1, 1),
  );

  // Test 1: Half-share member summary (Month 4 current, Payout Month 8)
  print('Test 1: Half-share member summary...');
  final sarahShare = MemberShare(
    id: 's1',
    gameyaId: 'g1',
    shareGroupId: 2,
    memberName: 'سارة خليل',
    phone: '01022222222',
    shareRatio: 0.5,
    installmentAmount: 2500.0,
    payoutMonth: 8,
  );

  final summary = MemberPortalService.buildMemberSummary(
    gameya: sampleGameya,
    memberShare: sarahShare,
    currentMonthNumber: 4,
    currentMonthStatus: InstallmentStatus.pending,
  );

  expect(summary.shareRatioDisplay, 'نصف سهم (50%)');
  expect(summary.myInstallmentAmount, 2500.0);
  expect(summary.myPayoutAmount, 25000.0); // 50% of 50,000
  expect(summary.myPayoutMonth, 8);
  expect(summary.monthsUntilPayout, 4); // Month 8 - Month 4 = 4 months
  expectTrue(!summary.isMyPayoutMonth);
  expect(summary.currentMonthStatus, InstallmentStatus.pending);

  // Test 2: Current month is payout month
  print('Test 2: When current month is member payout month...');
  final summaryAtPayout = MemberPortalService.buildMemberSummary(
    gameya: sampleGameya,
    memberShare: sarahShare,
    currentMonthNumber: 8,
  );
  expectTrue(summaryAtPayout.isMyPayoutMonth);
  expect(summaryAtPayout.monthsUntilPayout, 0);

  // Test 3: Full-share member ratio display
  print('Test 3: Full-share member ratio display...');
  final fullShare = sarahShare.copyWith(shareRatio: 1.0, installmentAmount: 5000.0);
  final fullSummary = MemberPortalService.buildMemberSummary(
    gameya: sampleGameya,
    memberShare: fullShare,
    currentMonthNumber: 1,
  );
  expect(fullSummary.shareRatioDisplay, '1 سهم كامل (100%)');
  expect(fullSummary.myPayoutAmount, 50000.0);

  print('SUCCESS: All MemberPortalService tests passed (3/3)!');
}
