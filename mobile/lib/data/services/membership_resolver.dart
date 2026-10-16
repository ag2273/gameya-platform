import '../../core/utils/whatsapp_helper.dart';
import '../../domain/models/member_share.dart';

class MembershipResolver {
  /// Scans member shares and links the authenticated user's UID to matching phone records.
  static List<MemberShare> linkMemberSharesByPhone({
    required String rawPhone,
    required String authenticatedUserId,
    required List<MemberShare> allExistingShares,
  }) {
    final normalized = WhatsAppHelper.normalizePhone(rawPhone);
    final List<MemberShare> resolved = [];

    for (final share in allExistingShares) {
      if (WhatsAppHelper.normalizePhone(share.phone) == normalized) {
        resolved.add(share.copyWith(userId: authenticatedUserId));
      }
    }
    return resolved;
  }
}
