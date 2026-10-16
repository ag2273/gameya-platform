import 'member_share.dart';

/// Represents a single unit of share in a Gameya (which may be held by 1 member or split among up to 4 partners).
class ShareGroup {
  final int id; // 1-indexed group number
  final String gameyaId;
  final List<MemberShare> partners;

  static const int maxPartners = 4;
  static const double targetUnitRatio = 1.0;

  ShareGroup({
    required this.id,
    required this.gameyaId,
    List<MemberShare>? partners,
  }) : partners = partners ?? [];

  /// Total ratio of all partners currently in this share group.
  double get totalRatio => partners.fold(0.0, (sum, p) => sum + p.shareRatio);

  /// Number of partners currently in this group.
  int get partnerCount => partners.length;

  /// True if the group meets the 1.0 (100%) invariant exactly.
  bool get isComplete => (totalRatio - targetUnitRatio).abs() < 0.0001;

  /// Remaining ratio needed to reach 100% of this share unit.
  double get remainingRatio => (targetUnitRatio - totalRatio).clamp(0.0, 1.0);

  /// Whether another partner can be added without exceeding max partners or 100% ratio.
  bool get canAddPartner => partnerCount < maxPartners && remainingRatio > 0.0001;

  ShareGroup copyWith({
    int? id,
    String? gameyaId,
    List<MemberShare>? partners,
  }) {
    return ShareGroup(
      id: id ?? this.id,
      gameyaId: gameyaId ?? this.gameyaId,
      partners: partners ?? List.from(this.partners),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'gameyaId': gameyaId,
      'totalRatio': totalRatio,
      'partnerCount': partnerCount,
      'isComplete': isComplete,
      'partners': partners.map((p) => p.toMap()).toList(),
    };
  }
}
