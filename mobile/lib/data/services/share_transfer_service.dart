import '../../domain/models/member_share.dart';
import '../../domain/models/installment.dart';

class ShareTransferResult {
  final MemberShare originalShare;
  final MemberShare transferredShare;
  final List<Installment> updatedInstallments;
  final int transferredInstallmentsCount;
  final double transferredObligationAmount;

  ShareTransferResult({
    required this.originalShare,
    required this.transferredShare,
    required this.updatedInstallments,
    required this.transferredInstallmentsCount,
    required this.transferredObligationAmount,
  });
}

class ShareTransferService {
  /// Executes a Share Transfer when an active member drops out or defaults (ADR-0008).
  /// Reassigns remaining uncollected installments to the replacement member.
  /// Preserves all past paid historical records without altering locked Gameya parameters.
  static ShareTransferResult executeTransfer({
    required MemberShare originalShare,
    required String newMemberName,
    required String newPhone,
    required int transferFromMonth,
    required List<Installment> allInstallments,
  }) {
    if (newMemberName.trim().isEmpty) {
      throw ArgumentError('Replacement member name cannot be empty.');
    }
    if (newPhone.trim().isEmpty) {
      throw ArgumentError('Replacement member phone cannot be empty.');
    }

    final newShare = originalShare.copyWith(
      memberName: newMemberName.trim(),
      phone: newPhone.trim(),
      userId: null, // Reset until new member signs in and links
    );

    int transferredCount = 0;
    double transferredAmount = 0.0;

    final updatedInstallments = allInstallments.map((inst) {
      if (inst.memberShareId != originalShare.id) {
        return inst;
      }

      // Historical paid installments remain intact
      if (inst.monthNumber < transferFromMonth && inst.status == InstallmentStatus.paid) {
        return inst;
      }

      // Future/unpaid installments transfer to the replacement member
      if (inst.monthNumber >= transferFromMonth) {
        transferredCount++;
        transferredAmount += inst.amount;
        return inst.copyWith(
          status: InstallmentStatus.pending,
          clearPaidAt: true,
          clearVerifiedBy: true,
        );
      }

      return inst;
    }).toList();

    return ShareTransferResult(
      originalShare: originalShare,
      transferredShare: newShare,
      updatedInstallments: updatedInstallments,
      transferredInstallmentsCount: transferredCount,
      transferredObligationAmount: transferredAmount,
    );
  }
}
