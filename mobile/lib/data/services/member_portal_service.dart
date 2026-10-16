import '../../domain/models/gameya.dart';
import '../../domain/models/member_share.dart';
import '../../domain/models/installment.dart';

class MemberGameyaSummary {
  final Gameya gameya;
  final MemberShare myShare;
  final double myInstallmentAmount;
  final double myPayoutAmount;
  final int myPayoutMonth;
  final int monthsUntilPayout;
  final bool isMyPayoutMonth;
  final InstallmentStatus? currentMonthStatus;

  MemberGameyaSummary({
    required this.gameya,
    required this.myShare,
    required this.myInstallmentAmount,
    required this.myPayoutAmount,
    required this.myPayoutMonth,
    required this.monthsUntilPayout,
    required this.isMyPayoutMonth,
    this.currentMonthStatus,
  });

  String get shareRatioDisplay {
    if (myShare.shareRatio == 1.0) return '1 سهم كامل (100%)';
    if (myShare.shareRatio == 0.5) return 'نصف سهم (50%)';
    if (myShare.shareRatio == 0.25) return 'ربع سهم (25%)';
    if (myShare.shareRatio == 0.75) return 'ثلاثة أرباع سهم (75%)';
    return '${(myShare.shareRatio * 100).toStringAsFixed(0)}% من السهم';
  }
}

class MemberPortalService {
  /// Aggregates member-specific dashboard data for a given Gameya and member share.
  static MemberGameyaSummary buildMemberSummary({
    required Gameya gameya,
    required MemberShare memberShare,
    required int currentMonthNumber,
    InstallmentStatus? currentMonthStatus,
  }) {
    final myInstallment = memberShare.installmentAmount;
    final myPayout = gameya.totalPot * memberShare.shareRatio;
    final monthsRemaining = memberShare.payoutMonth - currentMonthNumber;
    final isMyTurn = memberShare.payoutMonth == currentMonthNumber;

    return MemberGameyaSummary(
      gameya: gameya,
      myShare: memberShare,
      myInstallmentAmount: myInstallment,
      myPayoutAmount: myPayout,
      myPayoutMonth: memberShare.payoutMonth,
      monthsUntilPayout: monthsRemaining > 0 ? monthsRemaining : 0,
      isMyPayoutMonth: isMyTurn,
      currentMonthStatus: currentMonthStatus,
    );
  }
}
