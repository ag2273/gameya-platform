import '../../lib/data/services/installment_tracker.dart';
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
  print('Starting InstallmentTracker test suite...');

  final baseInstallment = Installment(
    id: 'inst1',
    gameyaId: 'g1',
    memberShareId: 's1',
    monthNumber: 4,
    amount: 5000.0,
    status: InstallmentStatus.pending,
  );

  // Test 1: 1-Tap Toggle between Pending and Paid
  print('Test 1: 1-Tap Toggle between Pending and Paid...');
  final paid = InstallmentTracker.togglePaymentStatus(
    installment: baseInstallment,
    organizerId: 'org1',
    timestamp: DateTime(2026, 4, 3),
  );
  expect(paid.status, InstallmentStatus.paid);
  expect(paid.verifiedBy, 'org1');
  expect(paid.paidAt, DateTime(2026, 4, 3));

  final reverted = InstallmentTracker.togglePaymentStatus(
    installment: paid,
    organizerId: 'org1',
  );
  expect(reverted.status, InstallmentStatus.pending);
  expect(reverted.verifiedBy, null);
  expect(reverted.paidAt, null);

  // Test 2: 7-Day Grace Period evaluation
  print('Test 2: 7-Day Grace Period evaluation...');
  final cycleStart = DateTime(2026, 4, 1); // Month 4 starts on April 1

  // Day 5 (within grace period): still pending
  final day5 = DateTime(2026, 4, 6);
  final instDay5 = InstallmentTracker.evaluateGracePeriod(
    installment: baseInstallment,
    cycleStartDate: cycleStart,
    gracePeriodDays: 7,
    currentDate: day5,
  );
  expect(instDay5.status, InstallmentStatus.pending);

  // Day 9 (past 7-day grace period): automatically Overdue!
  final day9 = DateTime(2026, 4, 10);
  final instDay9 = InstallmentTracker.evaluateGracePeriod(
    installment: baseInstallment,
    cycleStartDate: cycleStart,
    gracePeriodDays: 7,
    currentDate: day9,
  );
  expect(instDay9.status, InstallmentStatus.overdue);
  expect(instDay9.dueDate, cycleStart.add(const Duration(days: 7)));

  // Paid installment remains paid after grace period
  final paidInst = baseInstallment.copyWith(status: InstallmentStatus.paid);
  final evaluatedPaid = InstallmentTracker.evaluateGracePeriod(
    installment: paidInst,
    cycleStartDate: cycleStart,
    gracePeriodDays: 7,
    currentDate: day9,
  );
  expect(evaluatedPaid.status, InstallmentStatus.paid);

  // Test 3: Monthly collection metrics computation
  print('Test 3: Monthly collection metrics computation...');
  final monthList = [
    Installment(id: '1', gameyaId: 'g1', memberShareId: 's1', monthNumber: 4, amount: 5000.0, status: InstallmentStatus.paid),
    Installment(id: '2', gameyaId: 'g1', memberShareId: 's2', monthNumber: 4, amount: 5000.0, status: InstallmentStatus.paid),
    Installment(id: '3', gameyaId: 'g1', memberShareId: 's3', monthNumber: 4, amount: 5000.0, status: InstallmentStatus.paid),
    Installment(id: '4', gameyaId: 'g1', memberShareId: 's4', monthNumber: 4, amount: 5000.0, status: InstallmentStatus.paid),
    Installment(id: '5', gameyaId: 'g1', memberShareId: 's5', monthNumber: 4, amount: 5000.0, status: InstallmentStatus.paid),
    Installment(id: '6', gameyaId: 'g1', memberShareId: 's6', monthNumber: 4, amount: 5000.0, status: InstallmentStatus.paid),
    Installment(id: '7', gameyaId: 'g1', memberShareId: 's7', monthNumber: 4, amount: 5000.0, status: InstallmentStatus.paid), // 35,000 paid
    Installment(id: '8', gameyaId: 'g1', memberShareId: 's8', monthNumber: 4, amount: 5000.0, status: InstallmentStatus.review),
    Installment(id: '9', gameyaId: 'g1', memberShareId: 's9', monthNumber: 4, amount: 5000.0, status: InstallmentStatus.overdue),
    Installment(id: '10', gameyaId: 'g1', memberShareId: 's10', monthNumber: 4, amount: 5000.0, status: InstallmentStatus.pending),
  ];

  final partialStatus = InstallmentTracker.computeMonthCollection(monthList);
  expect(partialStatus.totalExpected, 50000.0);
  expect(partialStatus.totalCollected, 35000.0);
  expect(partialStatus.remainingAmount, 15000.0);
  expect(partialStatus.completionPercentage, 70.0);
  expectTrue(!partialStatus.isFullyPaid, '70% is NOT fully paid');
  expect(partialStatus.paidCount, 7);
  expect(partialStatus.overdueCount, 1);
  expect(partialStatus.reviewCount, 1);
  expect(partialStatus.pendingCount, 1);

  // Complete 100% scenario
  final completeList = monthList.map((i) => i.copyWith(status: InstallmentStatus.paid)).toList();
  final completeStatus = InstallmentTracker.computeMonthCollection(completeList);
  expect(completeStatus.totalCollected, 50000.0);
  expect(completeStatus.remainingAmount, 0.0);
  expect(completeStatus.completionPercentage, 100.0);
  expectTrue(completeStatus.isFullyPaid, '100% IS fully paid');

  print('SUCCESS: All InstallmentTracker tests passed (3/3)!');
}
