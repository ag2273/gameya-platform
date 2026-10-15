enum DisbursementStatus {
  disbursed,
  confirmed,
}

DateTime _parseDate(dynamic val) {
  if (val == null) return DateTime.now();
  if (val is DateTime) return val;
  if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
  try {
    return (val as dynamic).toDate();
  } catch (_) {
    return DateTime.now();
  }
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
      'disbursedAt': disbursedAt.toIso8601String(),
      'autoConfirmDeadline': autoConfirmDeadline.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
    };
  }

  factory Disbursement.fromMap(Map<String, dynamic> map, String docId) {
    final disbursed = _parseDate(map['disbursedAt']);
    final defaultDeadline = disbursed.add(const Duration(days: 2));
    final deadline = map['autoConfirmDeadline'] != null
        ? _parseDate(map['autoConfirmDeadline'])
        : defaultDeadline;

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
      confirmedAt: _parseNullableDate(map['confirmedAt']),
    );
  }

  Disbursement copyWith({
    String? id,
    String? gameyaId,
    int? monthNumber,
    String? recipientMemberId,
    double? amount,
    DisbursementStatus? status,
    String? paymentMethod,
    DateTime? disbursedAt,
    DateTime? autoConfirmDeadline,
    DateTime? confirmedAt,
  }) {
    return Disbursement(
      id: id ?? this.id,
      gameyaId: gameyaId ?? this.gameyaId,
      monthNumber: monthNumber ?? this.monthNumber,
      recipientMemberId: recipientMemberId ?? this.recipientMemberId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      disbursedAt: disbursedAt ?? this.disbursedAt,
      autoConfirmDeadline: autoConfirmDeadline ?? this.autoConfirmDeadline,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }
}
