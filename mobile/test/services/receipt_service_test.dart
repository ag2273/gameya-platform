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

void main() async {
  print('Starting ReceiptService test suite...');

  final storage = InMemoryReceiptStorageProvider();
  final service = ReceiptService(storageProvider: storage);

  // Test 1: Compress large 2.5MB raw receipt screenshot
  print('Test 1: Compress 2.5MB receipt image...');
  final largeRawBytes = List<int>.filled(2500000, 42); // 2.5 MB
  final compression = ReceiptService.compressReceipt(largeRawBytes);

  expectTrue(compression.isUnder150Kb, 'Compressed size must be <= 150KB');
  expectTrue(compression.compressedSizeBytes < ReceiptService.maxTargetBytes);
  expect(compression.originalSizeBytes, 2500000);

  // Test 2: Small receipt (<150KB) requires no compression
  print('Test 2: Small receipt image (<150KB)...');
  final smallRawBytes = List<int>.filled(80000, 10); // 80 KB
  final smallCompression = ReceiptService.compressReceipt(smallRawBytes);
  expect(smallCompression.compressedSizeBytes, 80000);
  expectTrue(smallCompression.isUnder150Kb);

  // Test 3: Submit receipt end-to-end
  print('Test 3: Submit receipt workflow (compress -> upload -> update to review)...');
  final installment = Installment(
    id: 'inst-tareq-m4',
    gameyaId: 'gameya-family-2026',
    memberShareId: 'share-tareq',
    monthNumber: 4,
    amount: 5000.0,
    status: InstallmentStatus.pending,
  );

  final updated = await service.submitReceipt(
    installment: installment,
    rawImageBytes: largeRawBytes,
    filename: 'vodafone_cash_receipt.jpg',
  );

  expect(updated.status, InstallmentStatus.review);
  expectTrue(updated.receiptUrl != null);
  expectTrue(updated.receiptUrl!.contains('receipts%2Fgameya-family-2026%2Finst-tareq-m4_vodafone_cash_receipt.jpg'));
  expectTrue(storage.hasFile('receipts/gameya-family-2026/inst-tareq-m4_vodafone_cash_receipt.jpg'));

  print('SUCCESS: All ReceiptService tests passed (3/3)!');
}
