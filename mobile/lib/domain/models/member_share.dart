class MemberShare {
  final String id;
  final String gameyaId;
  final int shareGroupId;
  final String memberName;
  final String phone;
  final String? userId;
  final double shareRatio; // 0.25, 0.5, 0.75, 1.0
  final double installmentAmount;
  final int payoutMonth;

  MemberShare({
    required this.id,
    required this.gameyaId,
    required this.shareGroupId,
    required this.memberName,
    required this.phone,
    this.userId,
    required this.shareRatio,
    required this.installmentAmount,
    required this.payoutMonth,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameyaId': gameyaId,
      'shareGroupId': shareGroupId,
      'memberName': memberName,
      'phone': phone,
      'userId': userId,
      'shareRatio': shareRatio,
      'installmentAmount': installmentAmount,
      'payoutMonth': payoutMonth,
    };
  }

  factory MemberShare.fromMap(Map<String, dynamic> map, String docId) {
    return MemberShare(
      id: docId,
      gameyaId: map['gameyaId'] ?? '',
      shareGroupId: map['shareGroupId'] ?? 0,
      memberName: map['memberName'] ?? '',
      phone: map['phone'] ?? '',
      userId: map['userId'],
      shareRatio: (map['shareRatio'] as num?)?.toDouble() ?? 1.0,
      installmentAmount: (map['installmentAmount'] as num?)?.toDouble() ?? 0.0,
      payoutMonth: map['payoutMonth'] ?? 1,
    );
  }

  MemberShare copyWith({
    String? id,
    String? gameyaId,
    int? shareGroupId,
    String? memberName,
    String? phone,
    String? userId,
    double? shareRatio,
    double? installmentAmount,
    int? payoutMonth,
  }) {
    return MemberShare(
      id: id ?? this.id,
      gameyaId: gameyaId ?? this.gameyaId,
      shareGroupId: shareGroupId ?? this.shareGroupId,
      memberName: memberName ?? this.memberName,
      phone: phone ?? this.phone,
      userId: userId ?? this.userId,
      shareRatio: shareRatio ?? this.shareRatio,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      payoutMonth: payoutMonth ?? this.payoutMonth,
    );
  }
}
