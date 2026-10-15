import '../../lib/domain/models/gameya.dart';
import '../../lib/domain/models/member_share.dart';
import '../../lib/core/utils/math_validator.dart';

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

class InMemoryGameyaService {
  final Map<String, Gameya> _gameyas = {};
  final Map<String, List<MemberShare>> _shares = {};

  Future<Gameya> createGameya({
    required String id,
    required String name,
    required String organizerId,
    required double totalPot,
    required int totalMonths,
    String currency = 'EGP',
    int gracePeriodDays = 7,
  }) async {
    final gameya = Gameya(
      id: id,
      name: name,
      organizerId: organizerId,
      totalPot: totalPot,
      monthlyShareInstallment: totalPot / totalMonths,
      totalMonths: totalMonths,
      startDate: DateTime.now(),
      status: GameyaStatus.draft,
      inviteCode: 'INV-$id',
      currency: currency,
      gracePeriodDays: gracePeriodDays,
      createdAt: DateTime.now(),
    );
    _gameyas[id] = gameya;
    _shares[id] = [];
    return gameya;
  }

  void addMemberShare(MemberShare share) {
    _shares.putIfAbsent(share.gameyaId, () => []).add(share);
  }

  Future<Gameya> activateGameya(String gameyaId) async {
    final gameya = _gameyas[gameyaId];
    if (gameya == null) throw Exception('Gameya not found');

    final shares = _shares[gameyaId] ?? [];
    final validation = MathValidator.validateGameyaFinancials(
      totalMonths: gameya.totalMonths,
      totalPot: gameya.totalPot,
      allMembers: shares,
    );

    if (!validation.isValid) {
      throw Exception('Activation blocked: ${validation.errors.join(", ")}');
    }

    final activeGameya = Gameya(
      id: gameya.id,
      name: gameya.name,
      organizerId: gameya.organizerId,
      totalPot: gameya.totalPot,
      monthlyShareInstallment: gameya.monthlyShareInstallment,
      totalMonths: gameya.totalMonths,
      startDate: gameya.startDate,
      status: GameyaStatus.active,
      inviteCode: gameya.inviteCode,
      currency: gameya.currency,
      gracePeriodDays: gameya.gracePeriodDays,
      createdAt: gameya.createdAt,
    );
    _gameyas[gameyaId] = activeGameya;
    return activeGameya;
  }
}

void main() async {
  print('Starting GameyaService unit test suite...');

  final service = InMemoryGameyaService();

  print('Test 1: Create Gameya with defaults...');
  final g = await service.createGameya(
    id: 'g100',
    name: 'جمعية النصر',
    organizerId: 'org_1',
    totalPot: 30000,
    totalMonths: 3,
  );
  expect(g.status, GameyaStatus.draft);
  expect(g.currency, 'EGP');
  expect(g.gracePeriodDays, 7);
  expect(g.monthlyShareInstallment, 10000.0);
  expectTrue(!g.isFinancialLocked, 'Draft Gameya financials are not locked');

  print('Test 2: Activation blocked when months are unbalanced...');
  service.addMemberShare(MemberShare(id: 's1', gameyaId: 'g100', shareGroupId: 1, memberName: 'A', phone: '010', shareRatio: 1.0, installmentAmount: 10000, payoutMonth: 1));
  // Month 2 and 3 missing!
  try {
    await service.activateGameya('g100');
    throw Exception('Should have thrown activation error');
  } catch (e) {
    expectTrue(e.toString().contains('Activation blocked'), 'Correctly blocked activation');
  }

  print('Test 3: Activation succeeds and locks financials when fully balanced...');
  service.addMemberShare(MemberShare(id: 's2', gameyaId: 'g100', shareGroupId: 2, memberName: 'B', phone: '011', shareRatio: 1.0, installmentAmount: 10000, payoutMonth: 2));
  service.addMemberShare(MemberShare(id: 's3', gameyaId: 'g100', shareGroupId: 3, memberName: 'C', phone: '012', shareRatio: 1.0, installmentAmount: 10000, payoutMonth: 3));

  final activated = await service.activateGameya('g100');
  expect(activated.status, GameyaStatus.active);
  expectTrue(activated.isFinancialLocked, 'Active Gameya is financially locked');

  print('SUCCESS: All GameyaService tests passed (3/3)!');
}
