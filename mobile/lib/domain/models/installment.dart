enum InstallmentStatus {
  pending,
  review,
  paid,
  overdue,
}

DateTime? _parseNullableDate(dynamic val) {
  if (val == null) return null;
  if (val is DateTime) return val;
  if (val is String) return DateTime.tryParse(val);
  try {
    return (val as dynamic).toDate();
  } catch (_) {
    return null;
  }
}

class Installment {
  final String id;
  final String gameyaId;
  final String memberShareId;
  final int monthNumber;
  final double amount;
  final InstallmentStatus status;
  final String? receiptUrl;
  final DateTime? paidAt;
  final String? verifiedBy;
  final DateTime? dueDate;

  Installment({
    required this.id,
    required this.gameyaId,
    required this.memberShareId,
    required this.monthNumber,
    required this.amount,
    required this.status,
    this.receiptUrl,
    this.paidAt,
    this.verifiedBy,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameyaId': gameyaId,
      'memberShareId': memberShareId,
      'monthNumber': monthNumber,
      'amount': amount,
      'status': status.name,
      'receiptUrl': receiptUrl,
      'paidAt': paidAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Installment.fromMap(Map<String, dynamic> map, String docId) {
    return Installment(
      id: docId,
      gameyaId: map['gameyaId'] ?? '',
      memberShareId: map['memberShareId'] ?? '',
      monthNumber: map['monthNumber'] ?? 1,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: InstallmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => InstallmentStatus.pending,
      ),
      receiptUrl: map['receiptUrl'],
      paidAt: _parseNullableDate(map['paidAt']),
      verifiedBy: map['verifiedBy'],
      dueDate: _parseNullableDate(map['dueDate']),
    );
  }

  Installment copyWith({
    String? id,
    String? gameyaId,
    String? memberShareId,
    int? monthNumber,
    double? amount,
    InstallmentStatus? status,
    String? receiptUrl,
    DateTime? paidAt,
    String? verifiedBy,
    DateTime? dueDate,
  }) {
    return Installment(
      id: id ?? this.id,
      gameyaId: gameyaId ?? this.gameyaId,
      memberShareId: memberShareId ?? this.memberShareId,
      monthNumber: monthNumber ?? this.monthNumber,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      paidAt: paidAt ?? this.paidAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
