import '../../domain/models/member_share.dart';

class MonthAllocationStatus {
  final int monthNumber;
  final double allocatedRatio;
  final double allocatedAmount;
  final bool isBalanced;
  final bool isUnderAllocated;
  final bool isOverAllocated;

  MonthAllocationStatus({
    required this.monthNumber,
    required this.allocatedRatio,
    required this.allocatedAmount,
  })  : isBalanced = (allocatedRatio - 1.0).abs() < 0.0001,
        isUnderAllocated = allocatedRatio < 0.9999,
        isOverAllocated = allocatedRatio > 1.0001;
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final Map<int, MonthAllocationStatus> monthlyBreakdown;

  ValidationResult({
    required this.isValid,
    required this.errors,
    required this.monthlyBreakdown,
  });
}

class MathValidator {
  static const int maxPartnersPerShare = 4;

  /// Validates a single split-share group (must have 1 to 4 partners and sum to 1.0).
  static bool validateSplitShareGroup(List<MemberShare> partnersInGroup) {
    if (partnersInGroup.isEmpty || partnersInGroup.length > maxPartnersPerShare) {
      return false;
    }
    final totalRatio = partnersInGroup.fold<double>(0.0, (sum, m) => sum + m.shareRatio);
    return (totalRatio - 1.0).abs() < 0.0001;
  }

  /// Verifies the 100% payout invariant for every month of the Gameya cycle.
  static ValidationResult validateGameyaFinancials({
    required int totalMonths,
    required double totalPot,
    required List<MemberShare> allMembers,
  }) {
    final List<String> errors = [];
    final Map<int, double> monthRatios = {
      for (int i = 1; i <= totalMonths; i++) i: 0.0,
    };

    // Group by shareGroupId to ensure each share unit sums to 1.0
    final Map<int, List<MemberShare>> shareGroups = {};
    for (final member in allMembers) {
      shareGroups.putIfAbsent(member.shareGroupId, () => []).add(member);
      
      if (member.payoutMonth < 1 || member.payoutMonth > totalMonths) {
        errors.add('المشترك "${member.memberName}" مسجل لشهر غير صالح (${member.payoutMonth})');
      } else {
        monthRatios[member.payoutMonth] = (monthRatios[member.payoutMonth] ?? 0.0) + member.shareRatio;
      }
    }

    // Verify share group partner counts & ratios
    for (final entry in shareGroups.entries) {
      final partners = entry.value;
      if (partners.length > maxPartnersPerShare) {
        errors.add('السهم رقم ${entry.key} يضم أكثر من 4 شركاء (${partners.length})');
      }
      final groupRatio = partners.fold<double>(0.0, (sum, p) => sum + p.shareRatio);
      if ((groupRatio - 1.0).abs() >= 0.0001) {
        errors.add('السهم رقم ${entry.key} غير مكتمل: الإجمالي ${(groupRatio * 100).toStringAsFixed(1)}% بدلاً من 100%');
      }
    }

    // Verify monthly payout allocations
    final Map<int, MonthAllocationStatus> breakdown = {};
    for (int month = 1; month <= totalMonths; month++) {
      final ratio = monthRatios[month] ?? 0.0;
      final status = MonthAllocationStatus(
        monthNumber: month,
        allocatedRatio: ratio,
        allocatedAmount: ratio * totalPot,
      );
      breakdown[month] = status;

      if (!status.isBalanced) {
        if (status.isUnderAllocated) {
          final diff = ((1.0 - ratio) * 100).toStringAsFixed(1);
          errors.add('الشهر رقم $month به عجز: مكتمل بنسبة ${(ratio * 100).toStringAsFixed(1)}% (متبقي $diff%)');
        } else {
          final diff = ((ratio - 1.0) * 100).toStringAsFixed(1);
          errors.add('الشهر رقم $month به فائض: مخصص بنسبة ${(ratio * 100).toStringAsFixed(1)}% (زيادة $diff%)');
        }
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      monthlyBreakdown: breakdown,
    );
  }

  /// Verifies that two members can swap turns (must hold identical share ratios).
  static bool canSwapTurns(MemberShare requester, MemberShare target) {
    return (requester.shareRatio - target.shareRatio).abs() < 0.0001;
  }
}
