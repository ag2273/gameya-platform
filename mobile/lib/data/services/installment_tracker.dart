import '../../domain/models/installment.dart';

class MonthCollectionStatus {
  final double totalExpected;
  final double totalCollected;
  final double remainingAmount;
  final double completionPercentage;
  final bool isFullyPaid; // Exactly 100%
  final int paidCount;
  final int totalCount;
  final int overdueCount;
  final int pendingCount;
  final int reviewCount;

  MonthCollectionStatus({
    required this.totalExpected,
    required this.totalCollected,
    required this.remainingAmount,
    required this.completionPercentage,
    required this.isFullyPaid,
    required this.paidCount,
    required this.totalCount,
    required this.overdueCount,
    required this.pendingCount,
    required this.reviewCount,
  });
}

class InstallmentTracker {
  /// Evaluates an installment against the 7-day grace period.
  /// If unpaid and the current date is past `cycleStartDate + gracePeriodDays`,
  /// it automatically flags the status as `overdue`.
  static Installment evaluateGracePeriod({
    required Installment installment,
    required DateTime cycleStartDate,
    int gracePeriodDays = 7,
    DateTime? currentDate,
  }) {
    if (installment.status == InstallmentStatus.paid) {
      return installment;
    }

    final now = currentDate ?? DateTime.now();
    final graceDeadline = cycleStartDate.add(Duration(days: gracePeriodDays));

    if (now.isAfter(graceDeadline) && installment.status != InstallmentStatus.review) {
      return installment.copyWith(
        status: InstallmentStatus.overdue,
        dueDate: graceDeadline,
      );
    }

    return installment;
  }

  /// Toggles an installment between Paid and Pending with a single tap by the organizer.
  static Installment togglePaymentStatus({
    required Installment installment,
    required String organizerId,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    if (installment.status == InstallmentStatus.paid) {
      // Revert to pending
      return installment.copyWith(
        status: InstallmentStatus.pending,
        clearPaidAt: true,
        clearVerifiedBy: true,
      );
    } else {
      // Mark as paid
      return installment.copyWith(
        status: InstallmentStatus.paid,
        paidAt: now,
        verifiedBy: organizerId,
      );
    }
  }

  /// Computes monthly collection progress metrics to enforce the 100% delivery gate.
  static MonthCollectionStatus computeMonthCollection(List<Installment> installments) {
    if (installments.isEmpty) {
      return MonthCollectionStatus(
        totalExpected: 0.0,
        totalCollected: 0.0,
        remainingAmount: 0.0,
        completionPercentage: 0.0,
        isFullyPaid: false,
        paidCount: 0,
        totalCount: 0,
        overdueCount: 0,
        pendingCount: 0,
        reviewCount: 0,
      );
    }

    double expected = 0.0;
    double collected = 0.0;
    int paid = 0;
    int overdue = 0;
    int pending = 0;
    int review = 0;

    for (final inst in installments) {
      expected += inst.amount;
      if (inst.status == InstallmentStatus.paid) {
        collected += inst.amount;
        paid++;
      } else if (inst.status == InstallmentStatus.overdue) {
        overdue++;
      } else if (inst.status == InstallmentStatus.review) {
        review++;
      } else {
        pending++;
      }
    }

    final remaining = (expected - collected).clamp(0.0, expected);
    final pct = expected > 0 ? (collected / expected) * 100.0 : 0.0;
    final isFullyPaid = (collected - expected).abs() < 0.0001;

    return MonthCollectionStatus(
      totalExpected: expected,
      totalCollected: collected,
      remainingAmount: remaining,
      completionPercentage: pct,
      isFullyPaid: isFullyPaid,
      paidCount: paid,
      totalCount: installments.length,
      overdueCount: overdue,
      pendingCount: pending,
      reviewCount: review,
    );
  }
}
