import 'package:cloud_firestore/cloud_firestore.dart';

enum TurnSwapStatus {
  pendingTarget,
  pendingOrganizer,
  approved,
  rejected,
}

class TurnSwap {
  final String id;
  final String gameyaId;
  final String requesterMemberId;
  final String targetMemberId;
  final int requesterMonth;
  final int targetMonth;
  final double shareRatio;
  final TurnSwapStatus status;
  final DateTime createdAt;

  TurnSwap({
    required this.id,
    required this.gameyaId,
    required this.requesterMemberId,
    required this.targetMemberId,
    required this.requesterMonth,
    required this.targetMonth,
    required this.shareRatio,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameyaId': gameyaId,
      'requesterMemberId': requesterMemberId,
      'targetMemberId': targetMemberId,
      'requesterMonth': requesterMonth,
      'targetMonth': targetMonth,
      'shareRatio': shareRatio,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TurnSwap.fromMap(Map<String, dynamic> map, String docId) {
    return TurnSwap(
      id: docId,
      gameyaId: map['gameyaId'] ?? '',
      requesterMemberId: map['requesterMemberId'] ?? '',
      targetMemberId: map['targetMemberId'] ?? '',
      requesterMonth: map['requesterMonth'] ?? 1,
      targetMonth: map['targetMonth'] ?? 1,
      shareRatio: (map['shareRatio'] as num?)?.toDouble() ?? 1.0,
      status: TurnSwapStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TurnSwapStatus.pendingTarget,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
