import '../../domain/models/turn_swap.dart';
import '../../domain/models/member_share.dart';
import '../../core/utils/math_validator.dart';

class SwapExecutionResult {
  final TurnSwap swap;
  final MemberShare updatedRequester;
  final MemberShare updatedTarget;

  SwapExecutionResult({
    required this.swap,
    required this.updatedRequester,
    required this.updatedTarget,
  });
}

class TurnSwapService {
  /// Returns all members who hold identical share ratios and can legally swap turns with the requester.
  static List<MemberShare> getEligibleSwapPartners({
    required MemberShare requester,
    required List<MemberShare> allMembers,
  }) {
    return allMembers.where((m) {
      if (m.id == requester.id) return false;
      if (m.payoutMonth == requester.payoutMonth) return false;
      return MathValidator.canSwapTurns(requester, m);
    }).toList();
  }

  /// Initiates a turn swap proposal between two members.
  /// Strictly rejects the proposal if share ratios are not identical.
  static TurnSwap proposeSwap({
    required String id,
    required MemberShare requester,
    required MemberShare target,
    DateTime? createdAt,
  }) {
    if (!MathValidator.canSwapTurns(requester, target)) {
      final reqPct = (requester.shareRatio * 100).toStringAsFixed(0);
      final tgtPct = (target.shareRatio * 100).toStringAsFixed(0);
      throw StateError('Validation error: Cannot swap turns between unequal share ratios ($reqPct% vs $tgtPct%). Only equal shares may swap (ADR-0005).');
    }

    if (requester.payoutMonth == target.payoutMonth) {
      throw StateError('Validation error: Both members are already scheduled for month ${requester.payoutMonth}.');
    }

    return TurnSwap(
      id: id,
      gameyaId: requester.gameyaId,
      requesterMemberId: requester.id,
      targetMemberId: target.id,
      requesterMonth: requester.payoutMonth,
      targetMonth: target.payoutMonth,
      shareRatio: requester.shareRatio,
      status: TurnSwapStatus.pendingTarget,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Target member responds to the swap proposal: Accept (moves to pending organizer) or Reject.
  static TurnSwap respondAsTarget({
    required TurnSwap swap,
    required bool accept,
  }) {
    if (swap.status != TurnSwapStatus.pendingTarget) {
      throw StateError('Cannot respond to swap in ${swap.status.name} status.');
    }

    return swap.copyWith(
      status: accept ? TurnSwapStatus.pendingOrganizer : TurnSwapStatus.rejected,
    );
  }

  /// Organizer gives final authorization to execute the swap.
  /// Updates `payoutMonth` of both members without unbalancing the monthly solvency invariant.
  static SwapExecutionResult authorizeAsOrganizer({
    required TurnSwap swap,
    required bool approve,
    required MemberShare requester,
    required MemberShare target,
  }) {
    if (swap.status != TurnSwapStatus.pendingOrganizer) {
      throw StateError('Cannot authorize swap in ${swap.status.name} status; target member must consent first.');
    }

    if (!approve) {
      return SwapExecutionResult(
        swap: swap.copyWith(status: TurnSwapStatus.rejected),
        updatedRequester: requester,
        updatedTarget: target,
      );
    }

    // Mathematical guarantee: swapping identical ratios preserves monthly sum exactly!
    final updatedReq = requester.copyWith(payoutMonth: swap.targetMonth);
    final updatedTgt = target.copyWith(payoutMonth: swap.requesterMonth);

    return SwapExecutionResult(
      swap: swap.copyWith(status: TurnSwapStatus.approved),
      updatedRequester: updatedReq,
      updatedTarget: updatedTgt,
    );
  }
}
