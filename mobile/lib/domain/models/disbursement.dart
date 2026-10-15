import 'package:cloud_firestore/cloud_firestore.dart';

enum DisbursementStatus {
  disbursed,
  confirmed,
}

class Disbursement {
  final String id;
  final String gameyaId;
  final int monthNumber;
  final String recipientMemberId;
  final double amount;
  final DisbursementStatus status;
  final String paymentMethod;
  final DateTime disbursedAt;
  final DateTime autoConfirmDeadline;
  final DateTime? confirmedAt;

  Disbursement({
    required this.id,
    required this.gameyaId,
    required this.monthNumber,
    required this.recipientMemberId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.disbursedAt,
    required this.autoConfirmDeadline,
    this.confirmedAt,
  });

  bool get isEffectivelyConfirmed {
    if (status == DisbursementStatus.confirmed) return true;
    return DateTime.now().isAfter(autoConfirmDeadline);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameyaId': gameyaId,
      'monthNumber': monthNumber,
      'recipientMemberId': recipientMemberId,
      'amount': amount,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'disbursedAt': Timestamp.fromDate(disbursedAt),
      'autoConfirmDeadline': Timestamp.fromDate(autoConfirmDeadline),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
    };
  }

  factory Disbursement.fromMap(Map<String, dynamic> map, String docId) {
    final disbursed = (map['disbursedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final defaultDeadline = disbursed.add(const Duration(days: 2));
    final deadline = (map['autoConfirmDeadline'] as Timestamp?)?.toDate() ?? defaultDeadline;

    return Disbursement(
      id: docId,
      gameyaId: map['gameyaId'] ?? '',
      monthNumber: map['monthNumber'] ?? 1,
      recipientMemberId: map['recipientMemberId'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: DisbursementStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DisbursementStatus.disbursed,
      ),
      paymentMethod: map['paymentMethod'] ?? 'InstaPay',
      disbursedAt: disbursed,
      autoConfirmDeadline: deadline,
      confirmedAt: (map['confirmedAt'] as Timestamp?)?.toDate(),
    );
  }
}
