import '../../lib/data/services/turn_swap_service.dart';
import '../../lib/domain/models/member_share.dart';
import '../../lib/domain/models/turn_swap.dart';

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
  print('Starting TurnSwapService test suite...');

  final sarah05 = MemberShare(
    id: 's-sarah',
    gameyaId: 'g1',
    shareGroupId: 1,
    memberName: 'سارة خليل',
    phone: '0101',
    shareRatio: 0.5,
    installmentAmount: 2500.0,
    payoutMonth: 8,
  );

  final karim05 = MemberShare(
    id: 's-karim',
    gameyaId: 'g1',
    shareGroupId: 2,
    memberName: 'كريم حسن',
    phone: '0102',
    shareRatio: 0.5,
    installmentAmount: 2500.0,
    payoutMonth: 5,
  );

  final ahmed10 = MemberShare(
    id: 's-ahmed',
    gameyaId: 'g1',
    shareGroupId: 3,
    memberName: 'أحمد محمود',
    phone: '0103',
    shareRatio: 1.0,
    installmentAmount: 5000.0,
    payoutMonth: 2,
  );

  final members = [sarah05, karim05, ahmed10];

  // Test 1: Eligible swap partners
  print('Test 1: Filter eligible swap partners...');
  final eligible = TurnSwapService.getEligibleSwapPartners(
    requester: sarah05,
    allMembers: members,
  );
  expect(eligible.length, 1);
  expect(eligible.first.memberName, 'كريم حسن');

  // Test 2: Reject unequal ratio proposal
  print('Test 2: Reject swap proposal with unequal ratio (0.5 vs 1.0)...');
  expectThrows<StateError>(() {
    TurnSwapService.proposeSwap(
      id: 'swap-invalid',
      requester: sarah05,
      target: ahmed10,
    );
  }, 'Unequal ratio proposal must throw StateError');

  // Test 3: Successful proposal flow with mutual consent and organizer authorization
  print('Test 3: End-to-end Turn Swap workflow...');
  var swap = TurnSwapService.proposeSwap(
    id: 'swap-1',
    requester: sarah05,
    target: karim05,
  );
  expect(swap.status, TurnSwapStatus.pendingTarget);
  expect(swap.requesterMonth, 8);
  expect(swap.targetMonth, 5);

  // Target member accepts
  swap = TurnSwapService.respondAsTarget(swap: swap, accept: true);
  expect(swap.status, TurnSwapStatus.pendingOrganizer);

  // Organizer authorizes
  final result = TurnSwapService.authorizeAsOrganizer(
    swap: swap,
    approve: true,
    requester: sarah05,
    target: karim05,
  );
  expect(result.swap.status, TurnSwapStatus.approved);
  expect(result.updatedRequester.payoutMonth, 5); // Sarah moves to Month 5
  expect(result.updatedTarget.payoutMonth, 8);    // Karim moves to Month 8

  print('SUCCESS: All TurnSwapService tests passed (3/3)!');
}
