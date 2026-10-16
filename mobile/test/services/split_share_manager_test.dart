import '../../lib/data/services/split_share_manager.dart';
import '../../lib/domain/models/share_group.dart';

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
  print('Starting SplitShareManager test suite...');

  const monthlyShare = 5000.0;
  const totalPot = 50000.0;

  // Test 1: Full single share (1.0)
  print('Test 1: Full single share (1.0)...');
  var group = SplitShareManager.createGroup(gameyaId: 'g1', shareGroupId: 1);
  expect(group.partnerCount, 0);
  expectTrue(!group.isComplete);

  group = SplitShareManager.addPartner(
    group: group,
    memberId: 'm1',
    memberName: 'أحمد محمود',
    phone: '01011111111',
    shareRatio: 1.0,
    payoutMonth: 1,
    monthlyFullShareAmount: monthlyShare,
  );

  expect(group.partnerCount, 1);
  expectTrue(group.isComplete);
  expect(group.partners.first.installmentAmount, 5000.0);
  expect(SplitShareManager.calculatePayoutAmount(totalPot, 1.0), 50000.0);
  SplitShareManager.validateShareGroup(group);

  // Test 2: Split share with 2 partners (0.5 + 0.5)
  print('Test 2: Split share with 2 partners (0.5 + 0.5)...');
  var splitGroup2 = SplitShareManager.createGroup(gameyaId: 'g1', shareGroupId: 2);
  splitGroup2 = SplitShareManager.addPartner(
    group: splitGroup2,
    memberId: 'm2',
    memberName: 'سارة خليل',
    phone: '01022222222',
    shareRatio: 0.5,
    payoutMonth: 8,
    monthlyFullShareAmount: monthlyShare,
  );
  expect(splitGroup2.partnerCount, 1);
  expectTrue(!splitGroup2.isComplete);
  expect(splitGroup2.remainingRatio, 0.5);
  expect(splitGroup2.partners.first.installmentAmount, 2500.0); // 50% of 5000

  splitGroup2 = SplitShareManager.addPartner(
    group: splitGroup2,
    memberId: 'm3',
    memberName: 'كريم حسن',
    phone: '01033333333',
    shareRatio: 0.5,
    payoutMonth: 5,
    monthlyFullShareAmount: monthlyShare,
  );
  expect(splitGroup2.partnerCount, 2);
  expectTrue(splitGroup2.isComplete);
  expect(splitGroup2.remainingRatio, 0.0);
  expect(splitGroup2.partners[1].installmentAmount, 2500.0);
  SplitShareManager.validateShareGroup(splitGroup2);

  // Test 3: Split share with 4 partners (0.25 x 4)
  print('Test 3: Split share with 4 partners (0.25 x 4)...');
  var splitGroup4 = SplitShareManager.createGroup(gameyaId: 'g1', shareGroupId: 3);
  for (int i = 1; i <= 4; i++) {
    splitGroup4 = SplitShareManager.addPartner(
      group: splitGroup4,
      memberId: 'p$i',
      memberName: 'شريك $i',
      phone: '0104444440$i',
      shareRatio: 0.25,
      payoutMonth: i,
      monthlyFullShareAmount: monthlyShare,
    );
    expect(splitGroup4.partners.last.installmentAmount, 1250.0); // 25% of 5000
  }
  expect(splitGroup4.partnerCount, 4);
  expectTrue(splitGroup4.isComplete);
  SplitShareManager.validateShareGroup(splitGroup4);

  // Test 4: Enforce max 4 partners invariant
  print('Test 4: Enforce max 4 partners invariant...');
  expectThrows<StateError>(() {
    SplitShareManager.addPartner(
      group: splitGroup4,
      memberId: 'p5',
      memberName: 'شريك خامس',
      phone: '01055555555',
      shareRatio: 0.1,
      payoutMonth: 5,
      monthlyFullShareAmount: monthlyShare,
    );
  }, 'Adding 5th partner must throw StateError');

  // Test 5: Enforce max 1.0 (100%) ratio invariant
  print('Test 5: Enforce max 1.0 ratio invariant...');
  var overflowGroup = SplitShareManager.createGroup(gameyaId: 'g1', shareGroupId: 4);
  overflowGroup = SplitShareManager.addPartner(
    group: overflowGroup,
    memberId: 'o1',
    memberName: 'عضو أ',
    phone: '01066666661',
    shareRatio: 0.6,
    payoutMonth: 1,
    monthlyFullShareAmount: monthlyShare,
  );
  expectThrows<StateError>(() {
    SplitShareManager.addPartner(
      group: overflowGroup,
      memberId: 'o2',
      memberName: 'عضو ب',
      phone: '01066666662',
      shareRatio: 0.5, // 0.6 + 0.5 = 1.1 > 1.0
      payoutMonth: 2,
      monthlyFullShareAmount: monthlyShare,
    );
  }, 'Sum of ratios exceeding 1.0 must throw StateError');

  // Test 6: Incomplete group validation check
  print('Test 6: Incomplete group validation...');
  expectThrows<StateError>(() {
    SplitShareManager.validateShareGroup(overflowGroup); // ratio is 0.6, incomplete!
  }, 'Validating an incomplete group must throw StateError');

  print('SUCCESS: All SplitShareManager tests passed (6/6)!');
}
