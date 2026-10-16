import '../../lib/data/services/storage_purge_service.dart';
import '../../lib/data/services/receipt_service.dart';
import '../../lib/domain/models/gameya.dart';
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

class MockStorageProvider implements ReceiptStorageProvider {
  final Set<String> deletedUrls = {};

  @override
  Future<String> upload({required String gameyaId, required String installmentId, required List<int> bytes, required String filename}) async {
    return 'https://storage/$filename';
  }

  @override
  Future<void> deleteReceipt(String storageUrl) async {
    deletedUrls.add(storageUrl);
  }
}

void main() async {
  print('Starting StoragePurgeService test suite...');

  final mockStorage = MockStorageProvider();
  final now = DateTime(2026, 10, 15);

  // 1. Gameya completed 6 months ago (April 15, 2026 -> 183 days ago > 150 days)
  final oldCompletedGameya = Gameya(
    id: 'g-old',
    name: 'جمعية قديمة',
    organizerId: 'org1',
    totalPot: 50000.0,
    monthlyShareInstallment: 5000.0,
    totalMonths: 10,
    startDate: DateTime(2025, 6, 1),
    status: GameyaStatus.completed,
    inviteCode: 'INV-OLD',
    currency: 'EGP',
    gracePeriodDays: 7,
    createdAt: DateTime(2025, 6, 1),
    completedAt: DateTime(2026, 4, 15),
  );

  // 2. Gameya completed 2 months ago (August 15, 2026 -> 61 days ago < 150 days)
  final recentCompletedGameya = Gameya(
    id: 'g-recent',
    name: 'جمعية حديثة الاكتمال',
    organizerId: 'org1',
    totalPot: 50000.0,
    monthlyShareInstallment: 5000.0,
    totalMonths: 10,
    startDate: DateTime(2025, 10, 1),
    status: GameyaStatus.completed,
    inviteCode: 'INV-RECENT',
    currency: 'EGP',
    gracePeriodDays: 7,
    createdAt: DateTime(2025, 10, 1),
    completedAt: DateTime(2026, 8, 15),
  );

  final installments = [
    Installment(id: 'i-old-1', gameyaId: 'g-old', memberShareId: 's1', monthNumber: 1, amount: 5000.0, status: InstallmentStatus.paid, receiptUrl: 'https://storage/old1.jpg', paidAt: DateTime(2025, 6, 5), verifiedBy: 'org1'),
    Installment(id: 'i-old-2', gameyaId: 'g-old', memberShareId: 's2', monthNumber: 2, amount: 5000.0, status: InstallmentStatus.paid, receiptUrl: 'https://storage/old2.jpg', paidAt: DateTime(2025, 7, 5), verifiedBy: 'org1'),
    Installment(id: 'i-rec-1', gameyaId: 'g-recent', memberShareId: 's3', monthNumber: 1, amount: 5000.0, status: InstallmentStatus.paid, receiptUrl: 'https://storage/recent1.jpg', paidAt: DateTime(2025, 10, 5), verifiedBy: 'org1'),
  ];

  // Test 1: Purge execution
  print('Test 1: Purge photos from Gameya completed > 5 months ago...');
  final result = await StoragePurgeService.purgeExpiredReceipts(
    gameyas: [oldCompletedGameya, recentCompletedGameya],
    allInstallments: installments,
    storageProvider: mockStorage,
    currentDate: now,
  );

  expect(result.purgedReceiptCount, 2);
  expect(result.affectedGameyaCount, 1);
  expectTrue(mockStorage.deletedUrls.contains('https://storage/old1.jpg'));
  expectTrue(mockStorage.deletedUrls.contains('https://storage/old2.jpg'));
  expectTrue(!mockStorage.deletedUrls.contains('https://storage/recent1.jpg'), 'Recent Gameya photos must NOT be deleted');

  // Verify audit records preserved
  final purgedInst1 = result.updatedInstallments.firstWhere((i) => i.id == 'i-old-1');
  expect(purgedInst1.receiptUrl, null);
  expect(purgedInst1.status, InstallmentStatus.paid);
  expect(purgedInst1.amount, 5000.0);
  expect(purgedInst1.verifiedBy, 'org1');

  // Recent installment remains untouched
  final recentInst = result.updatedInstallments.firstWhere((i) => i.id == 'i-rec-1');
  expect(recentInst.receiptUrl, 'https://storage/recent1.jpg');

  print('SUCCESS: All StoragePurgeService tests passed (2/2)!');
}
