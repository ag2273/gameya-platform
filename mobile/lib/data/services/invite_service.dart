import '../../core/utils/whatsapp_helper.dart';

class InvitePayload {
  final String inviteCode;
  final String gameyaName;
  final String organizerName;
  final String deepLink;
  final String shareText;
  final Uri whatsAppUrl;
  final String qrCodeData;

  InvitePayload({
    required this.inviteCode,
    required this.gameyaName,
    required this.organizerName,
    required this.deepLink,
    required this.shareText,
    required this.whatsAppUrl,
    required this.qrCodeData,
  });
}

class InviteService {
  static const String appBaseUrl = 'https://smartgameya.app';

  /// Generates the standard deep link URL for joining a Gameya.
  static String buildDeepLink(String inviteCode) {
    return '$appBaseUrl/join/$inviteCode';
  }

  /// Builds a complete invite bundle including deep link, formatted share message, wa.me URL, and QR code payload.
  static InvitePayload generateInvitePayload({
    required String gameyaName,
    required String organizerName,
    required String inviteCode,
    String? recipientPhone,
  }) {
    final deepLink = buildDeepLink(inviteCode);
    final message = WhatsAppHelper.buildInviteMessage(
      gameyaName: gameyaName,
      organizerName: organizerName,
      inviteCode: inviteCode,
    );

    final fullShareText = '$message\n\n🔗 رابط الانضمام المباشر:\n$deepLink';

    final whatsAppUri = recipientPhone != null
        ? WhatsAppHelper.buildWhatsAppUri(phone: recipientPhone, message: fullShareText)
        : Uri.parse('https://wa.me/?text=${Uri.encodeComponent(fullShareText)}');

    return InvitePayload(
      inviteCode: inviteCode,
      gameyaName: gameyaName,
      organizerName: organizerName,
      deepLink: deepLink,
      shareText: fullShareText,
      whatsAppUrl: whatsAppUri,
      qrCodeData: deepLink,
    );
  }
}
