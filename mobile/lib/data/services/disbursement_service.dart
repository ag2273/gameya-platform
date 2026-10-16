import '../../domain/models/disbursement.dart';

class DisbursementService {
  static const Duration autoConfirmWindow = Duration(hours: 48); // 48-Hour Guarantee (ADR-0007)

  /// Records an outbound payout disbursement to the scheduled beneficiary.
  static Disbursement recordDisbursement({
    required String id,
    required String gameyaId,
    required int monthNumber,
    required String recipientMemberId,
    required double amount,
    required String paymentMethod,
    DateTime? timestamp,
  }) {
    final disbursed = timestamp ?? DateTime.now();
    final deadline = disbursed.add(autoConfirmWindow);

    return Disbursement(
      id: id,
      gameyaId: gameyaId,
      monthNumber: monthNumber,
      recipientMemberId: recipientMemberId,
      amount: amount,
      status: DisbursementStatus.disbursed,
      paymentMethod: paymentMethod,
      disbursedAt: disbursed,
      autoConfirmDeadline: deadline,
      confirmedAt: null,
    );
  }

  /// Beneficiary member confirms receipt of payout with 1 tap.
  static Disbursement confirmReceipt({
    required Disbursement disbursement,
    DateTime? timestamp,
  }) {
    if (disbursement.status == DisbursementStatus.confirmed) {
      return disbursement;
    }

    return disbursement.copyWith(
      status: DisbursementStatus.confirmed,
      confirmedAt: timestamp ?? DateTime.now(),
    );
  }

  /// Automatically advances disbursement to `confirmed` once the 48-hour deadline passes.
  static Disbursement evaluateAutoConfirmation({
    required Disbursement disbursement,
    DateTime? currentDate,
  }) {
    if (disbursement.status == DisbursementStatus.confirmed) {
      return disbursement;
    }

    final now = currentDate ?? DateTime.now();
    if (now.isAfter(disbursement.autoConfirmDeadline)) {
      return disbursement.copyWith(
        status: DisbursementStatus.confirmed,
        confirmedAt: disbursement.autoConfirmDeadline,
      );
    }

    return disbursement;
  }
}
