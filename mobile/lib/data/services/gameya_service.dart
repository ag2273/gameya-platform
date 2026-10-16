import 'dart:async';
import '../../domain/models/gameya.dart';
import '../../domain/models/member_share.dart';
import '../../domain/models/installment.dart';
import '../../domain/models/disbursement.dart';
import '../../domain/models/turn_swap.dart';
import '../../core/utils/math_validator.dart';

abstract class GameyaService {
  Future<Gameya> createGameya({
    required String id,
    required String name,
    required String organizerId,
    required double totalPot,
    required int totalMonths,
    String currency = 'EGP',
    int gracePeriodDays = 7,
  });

  Future<void> addMemberShare(MemberShare share);
  Future<Gameya> activateGameya(String gameyaId, List<MemberShare> allMembers);
  Future<void> updateInstallmentStatus(String installmentId, InstallmentStatus status);
  Future<Disbursement> disbursePayout(Disbursement disbursement);
  Future<void> executeTurnSwap(TurnSwap swap, MemberShare requester, MemberShare target);
  Future<void> transferShare({
    required String shareId,
    required String newMemberName,
    required String newPhone,
  });
}

class InMemoryGameyaService implements GameyaService {
  final Map<String, Gameya> _gameyas = {};
  final Map<String, List<MemberShare>> _shares = {};
  final Map<String, List<Installment>> _installments = {};
  final Map<String, List<Disbursement>> _disbursements = {};

  @override
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
    _installments[id] = [];
    _disbursements[id] = [];
    return gameya;
  }

  @override
  Future<void> addMemberShare(MemberShare share) async {
    _shares.putIfAbsent(share.gameyaId, () => []).add(share);
  }

  @override
  Future<Gameya> activateGameya(String gameyaId, List<MemberShare> allMembers) async {
    final gameya = _gameyas[gameyaId];
    if (gameya == null) throw Exception('Gameya not found');

    final validation = MathValidator.validateGameyaFinancials(
      totalMonths: gameya.totalMonths,
      totalPot: gameya.totalPot,
      allMembers: allMembers,
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

  @override
  Future<void> updateInstallmentStatus(String installmentId, InstallmentStatus status) async {
    for (final list in _installments.values) {
      final index = list.indexWhere((i) => i.id == installmentId);
      if (index != -1) {
        list[index] = list[index].copyWith(status: status, paidAt: status == InstallmentStatus.paid ? DateTime.now() : null);
        return;
      }
    }
  }

  @override
  Future<Disbursement> disbursePayout(Disbursement disbursement) async {
    _disbursements.putIfAbsent(disbursement.gameyaId, () => []).add(disbursement);
    return disbursement;
  }

  @override
  Future<void> executeTurnSwap(TurnSwap swap, MemberShare requester, MemberShare target) async {
    if (!MathValidator.canSwapTurns(requester, target)) {
      throw Exception('Cannot swap turns: member share ratios must be identical');
    }
    final shares = _shares[swap.gameyaId] ?? [];
    final reqIdx = shares.indexWhere((s) => s.id == requester.id);
    final tgtIdx = shares.indexWhere((s) => s.id == target.id);

    if (reqIdx != -1 && tgtIdx != -1) {
      shares[reqIdx] = shares[reqIdx].copyWith(payoutMonth: swap.targetMonth);
      shares[tgtIdx] = shares[tgtIdx].copyWith(payoutMonth: swap.requesterMonth);
    }
  }

  @override
  Future<void> transferShare({
    required String shareId,
    required String newMemberName,
    required String newPhone,
  }) async {
    for (final shares in _shares.values) {
      final idx = shares.indexWhere((s) => s.id == shareId);
      if (idx != -1) {
        shares[idx] = shares[idx].copyWith(
          memberName: newMemberName,
          phone: newPhone,
          userId: null, // New member links when they sign in
        );
        return;
      }
    }
  }
}
