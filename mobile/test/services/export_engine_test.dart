import 'dart:convert';
import '../../lib/data/services/export_engine.dart';
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
  print('Starting ExportEngine test suite...');

  final gameya = Gameya(
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

  final sarah = MemberShare(
    id: 's-sarah',
    gameyaId: 'g1',
    shareGroupId: 1,
    memberName: 'سارة خليل',
    phone: '01011111111',
    shareRatio: 0.5,
    installmentAmount: 2500.0,
    payoutMonth: 8,
  );

  final khaled = MemberShare(
    id: 's-khaled',
    gameyaId: 'g1',
    shareGroupId: 2,
    memberName: 'خالد إبراهيم',
    phone: '01022222222',
    shareRatio: 1.0,
    installmentAmount: 5000.0,
    payoutMonth: 4,
  );

  final installments = [
    Installment(id: 'i1', gameyaId: 'g1', memberShareId: 's-sarah', monthNumber: 1, amount: 2500.0, status: InstallmentStatus.paid, paidAt: DateTime(2026, 1, 3)),
    Installment(id: 'i2', gameyaId: 'g1', memberShareId: 's-khaled', monthNumber: 1, amount: 5000.0, status: InstallmentStatus.paid, paidAt: DateTime(2026, 1, 4)),
  ];

  // Test 1: Organizer JSON export has full access
  print('Test 1: Organizer JSON export contains full audit data...');
  final orgJson = ExportEngine.exportOrganizerJson(
    gameya: gameya,
    members: [sarah, khaled],
    installments: installments,
  );
  expectTrue(orgJson.contains('01011111111'));
  expectTrue(orgJson.contains('01022222222'));
  expectTrue(orgJson.contains('FULL_ORGANIZER_AUDIT'));

  // Test 2: Organizer CSV export
  print('Test 2: Organizer CSV export...');
  final orgCsv = ExportEngine.exportOrganizerCsv(
    gameya: gameya,
    members: [sarah, khaled],
    installments: installments,
  );
  expectTrue(orgCsv.contains('سارة خليل'));
  expectTrue(orgCsv.contains('خالد إبراهيم'));
  expectTrue(orgCsv.contains('إجمالي الجمعية,50000.0'));

  // Test 3: Member JSON export enforces strict privacy (ADR-0010)
  print('Test 3: Member statement enforces strict privacy...');
  final memJson = ExportEngine.exportMemberStatementJson(
    gameya: gameya,
    myShare: sarah,
    myInstallments: installments,
  );
  expectTrue(memJson.contains('سارة خليل'));
  expectTrue(memJson.contains('PERSONAL_MEMBER_STATEMENT'));
  // Must NOT leak Khaled's name or phone!
  expectTrue(!memJson.contains('خالد إبراهيم'), 'Must not expose other members in private statement');
  expectTrue(!memJson.contains('01022222222'), 'Must not expose other members phone numbers');

  // Test 4: Member CSV export enforces privacy
  print('Test 4: Member CSV export...');
  final memCsv = ExportEngine.exportMemberStatementCsv(
    gameya: gameya,
    myShare: sarah,
    myInstallments: installments,
  );
  expectTrue(memCsv.contains('كشف حساب شخصي: سارة خليل'));
  expectTrue(memCsv.contains('مبلغ القبض المستحق,25000.0'));
  expectTrue(!memCsv.contains('خالد إبراهيم'));

  print('SUCCESS: All ExportEngine tests passed (4/4)!');
}
