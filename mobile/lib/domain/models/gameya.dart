enum GameyaStatus {
  draft,
  recruiting,
  active,
  completed,
  cancelled,
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

class Gameya {
  final String id;
  final String name;
  final String organizerId;
  final double totalPot;
  final double monthlyShareInstallment;
  final int totalMonths;
  final DateTime startDate;
  final GameyaStatus status;
  final String inviteCode;
  final String currency;
  final int gracePeriodDays;
  final DateTime createdAt;
  final DateTime? completedAt;

  Gameya({
    required this.id,
    required this.name,
    required this.organizerId,
    required this.totalPot,
    required this.monthlyShareInstallment,
    required this.totalMonths,
    required this.startDate,
    required this.status,
    required this.inviteCode,
    this.currency = 'EGP',
    this.gracePeriodDays = 7,
    required this.createdAt,
    this.completedAt,
  });

  bool get isFinancialLocked => status == GameyaStatus.active || status == GameyaStatus.completed;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'organizerId': organizerId,
      'totalPot': totalPot,
      'monthlyShareInstallment': monthlyShareInstallment,
      'totalMonths': totalMonths,
      'startDate': startDate.toIso8601String(),
      'status': status.name,
      'inviteCode': inviteCode,
      'currency': currency,
      'gracePeriodDays': gracePeriodDays,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Gameya.fromMap(Map<String, dynamic> map, String docId) {
    return Gameya(
      id: docId,
      name: map['name'] ?? '',
      organizerId: map['organizerId'] ?? '',
      totalPot: (map['totalPot'] as num?)?.toDouble() ?? 0.0,
      monthlyShareInstallment: (map['monthlyShareInstallment'] as num?)?.toDouble() ?? 0.0,
      totalMonths: map['totalMonths'] ?? 0,
      startDate: _parseDate(map['startDate']),
      status: GameyaStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GameyaStatus.draft,
      ),
      inviteCode: map['inviteCode'] ?? '',
      currency: map['currency'] ?? 'EGP',
      gracePeriodDays: map['gracePeriodDays'] ?? 7,
      createdAt: _parseDate(map['createdAt']),
      completedAt: map['completedAt'] != null ? _parseDate(map['completedAt']) : null,
    );
  }

  Gameya copyWith({
    String? id,
    String? name,
    String? organizerId,
    double? totalPot,
    double? monthlyShareInstallment,
    int? totalMonths,
    DateTime? startDate,
    GameyaStatus? status,
    String? inviteCode,
    String? currency,
    int? gracePeriodDays,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Gameya(
      id: id ?? this.id,
      name: name ?? this.name,
      organizerId: organizerId ?? this.organizerId,
      totalPot: totalPot ?? this.totalPot,
      monthlyShareInstallment: monthlyShareInstallment ?? this.monthlyShareInstallment,
      totalMonths: totalMonths ?? this.totalMonths,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      inviteCode: inviteCode ?? this.inviteCode,
      currency: currency ?? this.currency,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
