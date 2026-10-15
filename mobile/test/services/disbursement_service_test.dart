import '../../lib/data/services/disbursement_service.dart';
import '../../lib/domain/models/disbursement.dart';

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
  print('Starting DisbursementService test suite...');

  final disbursedTime = DateTime(2026, 4, 15, 12, 0); // April 15, 12:00 PM

  // Test 1: Record payout disbursement
  print('Test 1: Record payout disbursement with 48h auto-confirm window...');
  final disbursement = DisbursementService.recordDisbursement(
    id: 'disb-m4',
    gameyaId: 'g1',
    monthNumber: 4,
    recipientMemberId: 'm-ali',
    amount: 50000.0,
    paymentMethod: 'InstaPay (Ref: 99482)',
    timestamp: disbursedTime,
  );

  expect(disbursement.amount, 50000.0);
  expect(disbursement.status, DisbursementStatus.disbursed);
  expect(disbursement.autoConfirmDeadline, disbursedTime.add(const Duration(hours: 48)));
  expect(disbursement.confirmedAt, null);

  // Test 2: Beneficiary explicit 1-tap confirmation
  print('Test 2: Beneficiary explicit confirmation...');
  final confirmed = DisbursementService.confirmReceipt(
    disbursement: disbursement,
    timestamp: DateTime(2026, 4, 15, 18, 0), // 6 hours later
  );
  expect(confirmed.status, DisbursementStatus.confirmed);
  expect(confirmed.confirmedAt, DateTime(2026, 4, 15, 18, 0));

  // Test 3: Auto-confirmation timeline evaluation
  print('Test 3: 48-Hour auto-confirmation evaluation...');
  // 36 hours later (still within window)
  final at36Hours = disbursedTime.add(const Duration(hours: 36));
  final stillPending = DisbursementService.evaluateAutoConfirmation(
    disbursement: disbursement,
    currentDate: at36Hours,
  );
  expect(stillPending.status, DisbursementStatus.disbursed);

  // 49 hours later (passed deadline)
  final at49Hours = disbursedTime.add(const Duration(hours: 49));
  final autoConfirmed = DisbursementService.evaluateAutoConfirmation(
    disbursement: disbursement,
    currentDate: at49Hours,
  );
  expect(autoConfirmed.status, DisbursementStatus.confirmed);
  expect(autoConfirmed.confirmedAt, disbursement.autoConfirmDeadline);

  print('SUCCESS: All DisbursementService tests passed (3/3)!');
}
