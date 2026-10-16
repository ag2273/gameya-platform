import 'dart:convert';
import '../../domain/models/gameya.dart';
import '../../domain/models/member_share.dart';
import '../../domain/models/installment.dart';

class ExportEngine {
  /// Generates a comprehensive JSON audit file for the Organizer (ADR-0010).
  static String exportOrganizerJson({
    required Gameya gameya,
    required List<MemberShare> members,
    required List<Installment> installments,
  }) {
    final data = {
      'gameya': gameya.toMap(),
      'members': members.map((m) => m.toMap()).toList(),
      'installments': installments.map((i) => i.toMap()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'exportType': 'FULL_ORGANIZER_AUDIT',
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Generates a comprehensive CSV audit ledger for the Organizer.
  static String exportOrganizerCsv({
    required Gameya gameya,
    required List<MemberShare> members,
    required List<Installment> installments,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('سجل جمعية: ${gameya.name}');
    buffer.writeln('إجمالي الجمعية,${gameya.totalPot},المدة بالأشهر,${gameya.totalMonths},القسط الشهري,${gameya.monthlyShareInstallment}');
    buffer.writeln('');
    buffer.writeln('رقم القسط,الشهر,اسم العضو,رقم الهاتف,نسبة السهم,المبلغ,الحالة,تاريخ السداد,المعتمد');

    final memberMap = {for (final m in members) m.id: m};

    for (final inst in installments) {
      final member = memberMap[inst.memberShareId];
      final memberName = member?.memberName ?? 'غير محدد';
      final phone = member?.phone ?? '';
      final ratio = member != null ? '${(member.shareRatio * 100).toStringAsFixed(0)}%' : '';
      final paidAt = inst.paidAt?.toIso8601String() ?? '';
      final verifier = inst.verifiedBy ?? '';

      buffer.writeln('${inst.id},${inst.monthNumber},$memberName,$phone,$ratio,${inst.amount},${inst.status.name},$paidAt,$verifier');
    }

    return buffer.toString();
  }

  /// Generates a strictly isolated personal statement in JSON for a Member (ADR-0010).
  /// Enforces privacy: zero group ledger data or other members' phone numbers.
  static String exportMemberStatementJson({
    required Gameya gameya,
    required MemberShare myShare,
    required List<Installment> myInstallments,
  }) {
    final data = {
      'gameyaName': gameya.name,
      'myMemberName': myShare.memberName,
      'myShareRatio': myShare.shareRatio,
      'myInstallmentAmount': myShare.installmentAmount,
      'myPayoutMonth': myShare.payoutMonth,
      'myNetPayout': gameya.totalPot * myShare.shareRatio,
      'myInstallments': myInstallments.where((i) => i.memberShareId == myShare.id).map((i) => {
        'monthNumber': i.monthNumber,
        'amount': i.amount,
        'status': i.status.name,
        'paidAt': i.paidAt?.toIso8601String(),
      }).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'exportType': 'PERSONAL_MEMBER_STATEMENT',
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Generates a strictly isolated personal statement in CSV for a Member.
  static String exportMemberStatementCsv({
    required Gameya gameya,
    required MemberShare myShare,
    required List<Installment> myInstallments,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('كشف حساب شخصي: ${myShare.memberName}');
    buffer.writeln('الجمعية,${gameya.name},الحصة,${(myShare.shareRatio * 100).toStringAsFixed(0)}%,القسط الشهري,${myShare.installmentAmount}');
    buffer.writeln('شهر الاستحقاق,${myShare.payoutMonth},مبلغ القبض المستحق,${gameya.totalPot * myShare.shareRatio}');
    buffer.writeln('');
    buffer.writeln('الشهر,المبلغ المطلوب,الحالة,تاريخ السداد');

    final relevant = myInstallments.where((i) => i.memberShareId == myShare.id);
    for (final inst in relevant) {
      final paidAt = inst.paidAt?.toIso8601String() ?? '-';
      buffer.writeln('شهر ${inst.monthNumber},${inst.amount},${inst.status.name},$paidAt');
    }

    return buffer.toString();
  }
}
