import '../../domain/models/member_share.dart';
import '../../domain/models/share_group.dart';

class SplitShareManager {
  static const int maxPartnersPerShare = 4;
  static const double targetShareUnit = 1.0;

  /// Calculates proportionate monthly installment amount for a given ratio.
  static double calculateInstallmentAmount(double monthlyFullShareAmount, double shareRatio) {
    if (shareRatio <= 0.0 || shareRatio > 1.0) {
      throw ArgumentError('Share ratio must be between 0.0 (exclusive) and 1.0 (inclusive)');
    }
    return monthlyFullShareAmount * shareRatio;
  }

  /// Calculates proportionate payout lump sum for a given ratio.
  static double calculatePayoutAmount(double totalPot, double shareRatio) {
    if (shareRatio <= 0.0 || shareRatio > 1.0) {
      throw ArgumentError('Share ratio must be between 0.0 (exclusive) and 1.0 (inclusive)');
    }
    return totalPot * shareRatio;
  }

  /// Creates a new empty ShareGroup.
  static ShareGroup createGroup({
    required String gameyaId,
    required int shareGroupId,
  }) {
    return ShareGroup(
      id: shareGroupId,
      gameyaId: gameyaId,
    );
  }

  /// Adds a partner to an existing ShareGroup with strict validation:
  /// 1. Maximum 4 partners per share unit.
  /// 2. Sum of ratios cannot exceed 1.0.
  /// 3. Automatically calculates proportionate installment amount.
  static ShareGroup addPartner({
    required ShareGroup group,
    required String memberId,
    required String memberName,
    required String phone,
    String? userId,
    required double shareRatio,
    required int payoutMonth,
    required double monthlyFullShareAmount,
  }) {
    if (group.partnerCount >= maxPartnersPerShare) {
      throw StateError('Validation error: Cannot exceed $maxPartnersPerShare partners within a single share unit (Share Group #${group.id}).');
    }

    if (shareRatio <= 0.0 || shareRatio > 1.0) {
      throw ArgumentError('Validation error: Share ratio must be greater than 0 and at most 1.0.');
    }

    final newTotalRatio = group.totalRatio + shareRatio;
    if (newTotalRatio > targetShareUnit + 0.0001) {
      final excess = ((newTotalRatio - targetShareUnit) * 100).toStringAsFixed(1);
      throw StateError('Validation error: Adding this partner exceeds 100% of the share unit by $excess% (Total: ${(newTotalRatio * 100).toStringAsFixed(1)}%).');
    }

    final installment = calculateInstallmentAmount(monthlyFullShareAmount, shareRatio);

    final partner = MemberShare(
      id: memberId,
      gameyaId: group.gameyaId,
      shareGroupId: group.id,
      memberName: memberName,
      phone: phone,
      userId: userId,
      shareRatio: shareRatio,
      installmentAmount: installment,
      payoutMonth: payoutMonth,
    );

    final updatedPartners = List<MemberShare>.from(group.partners)..add(partner);
    return group.copyWith(partners: updatedPartners);
  }

  /// Validates that a ShareGroup is fully formed and adheres to the invariant:
  /// - Has between 1 and 4 partners.
  /// - Sum of ratios equals exactly 1.0 (100%).
  static void validateShareGroup(ShareGroup group) {
    if (group.partners.isEmpty) {
      throw StateError('Validation error: Share Group #${group.id} must have at least 1 member.');
    }

    if (group.partnerCount > maxPartnersPerShare) {
      throw StateError('Validation error: Share Group #${group.id} exceeds maximum of $maxPartnersPerShare partners (${group.partnerCount}).');
    }

    if (!group.isComplete) {
      final totalPct = (group.totalRatio * 100).toStringAsFixed(1);
      final remainingPct = (group.remainingRatio * 100).toStringAsFixed(1);
      throw StateError('Validation error: Share Group #${group.id} is incomplete at $totalPct% (Remaining: $remainingPct%). Must equal exactly 100%.');
    }
  }
}
