import '../../lib/data/services/receipt_service.dart';
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
  print('Starting ReceiptReview test suite...');

  final installmentInReview = Installment(
    id: 'inst-tareq-m4',
    gameyaId: 'g1',
    memberShareId: 's4',
    monthNumber: 4,
    amount: 5000.0,
    status: InstallmentStatus.review,
    receiptUrl: 'https://storage/receipts/g1/inst-tareq.jpg',
  );

  final otherInstallment = Installment(
    id: 'inst-ahmed-m4',
    gameyaId: 'g1',
    memberShareId: 's1',
    monthNumber: 4,
    amount: 5000.0,
    status: InstallmentStatus.paid,
  );

  // Test 1: Count pending reviews
  print('Test 1: Count pending reviews badge...');
  final count = ReceiptService.countPendingReviews([installmentInReview, otherInstallment]);
  expect(count, 1);

  // Test 2: 1-Tap Approve receipt
  print('Test 2: 1-Tap Approve receipt...');
  final approved = ReceiptService.approveReceipt(
    installment: installmentInReview,
    organizerId: 'org-ahmed',
    timestamp: DateTime(2026, 4, 15, 14, 30),
  );
  expect(approved.status, InstallmentStatus.paid);
  expect(approved.verifiedBy, 'org-ahmed');
  expect(approved.paidAt, DateTime(2026, 4, 15, 14, 30));
  expect(approved.receiptUrl, 'https://storage/receipts/g1/inst-tareq.jpg');

  // Test 3: Reject and request re-upload
  print('Test 3: Reject receipt and request re-upload...');
  final rejected = ReceiptService.rejectReceipt(
    installment: installmentInReview,
    reason: 'الصورة غير واضحة ورقم المعاملة غير مقروء',
  );
  expect(rejected.status, InstallmentStatus.pending);
  expect(rejected.verifiedBy, null);
  expect(rejected.paidAt, null);

  print('SUCCESS: All ReceiptReview tests passed (3/3)!');
}
