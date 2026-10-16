import '../../lib/data/services/share_transfer_service.dart';
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

void expectThrows<T extends Object>(void Function() fn, [String? message]) {
  bool didThrow = false;
  try {
    fn();
  } catch (e) {
    if (e is T) {
      didThrow = true;
    } else {
      throw Exception('Expected error of type $T, but got ${e.runtimeType}: $e');
    }
  }
  if (!didThrow) {
    throw Exception('Expected error of type $T was not thrown. ${message ?? ""}');
  }
}

void main() {
  print('Starting ShareTransferService test suite...');

  final khaledShare = MemberShare(
    id: 's-khaled',
    gameyaId: 'g1',
    shareGroupId: 5,
    memberName: 'خالد إبراهيم',
    phone: '01011111111',
    shareRatio: 1.0,
    installmentAmount: 5000.0,
    payoutMonth: 9,
  );

  // Installments for 10 months: Months 1,2,3 paid, Month 4 overdue, 5-10 pending
  final installments = List.generate(10, (index) {
    final month = index + 1;
    final isPaid = month <= 3;
    return Installment(
      id: 'inst-$month',
      gameyaId: 'g1',
      memberShareId: 's-khaled',
      monthNumber: month,
      amount: 5000.0,
      status: isPaid ? InstallmentStatus.paid : InstallmentStatus.pending,
      paidAt: isPaid ? DateTime(2026, month, 5) : null,
      verifiedBy: isPaid ? 'org1' : null,
    );
  });

  // Test 1: Validation of empty inputs
  print('Test 1: Input validation...');
  expectThrows<ArgumentError>(() {
    ShareTransferService.executeTransfer(
      originalShare: khaledShare,
      newMemberName: '',
      newPhone: '01022222222',
      transferFromMonth: 4,
      allInstallments: installments,
    );
  });

  // Test 2: Execute transfer starting at Month 4
  print('Test 2: Execute transfer to replacement member (Mostafa Fahmy)...');
  final result = ShareTransferService.executeTransfer(
    originalShare: khaledShare,
    newMemberName: 'مصطفى فهمي',
    newPhone: '01099887766',
    transferFromMonth: 4,
    allInstallments: installments,
  );

  expect(result.transferredShare.memberName, 'مصطفى فهمي');
  expect(result.transferredShare.phone, '01099887766');
  expect(result.transferredShare.shareRatio, 1.0);
  expect(result.transferredShare.payoutMonth, 9); // Payout turn remains Month 9
  expect(result.transferredInstallmentsCount, 7); // Months 4 through 10
  expect(result.transferredObligationAmount, 35000.0); // 7 * 5,000

  // Verify historical installments (1,2,3) remain paid
  final m1 = result.updatedInstallments.firstWhere((i) => i.monthNumber == 1);
  final m2 = result.updatedInstallments.firstWhere((i) => i.monthNumber == 2);
  final m3 = result.updatedInstallments.firstWhere((i) => i.monthNumber == 3);
  expect(m1.status, InstallmentStatus.paid);
  expect(m2.status, InstallmentStatus.paid);
  expect(m3.status, InstallmentStatus.paid);

  // Verify future installments are pending
  final m4 = result.updatedInstallments.firstWhere((i) => i.monthNumber == 4);
  expect(m4.status, InstallmentStatus.pending);

  print('SUCCESS: All ShareTransferService tests passed (2/2)!');
}
