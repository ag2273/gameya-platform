import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/export_engine.dart';
import '../../../domain/models/gameya.dart';
import '../../../domain/models/installment.dart';
import '../../../domain/models/member_share.dart';

class ExportScreen extends StatefulWidget {
  final bool isOrganizer;

  const ExportScreen({super.key, this.isOrganizer = true});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String? _exportedPreview;
  String _exportFormat = 'CSV';

  void _generateExport() {
    final gameya = Gameya(
      id: 'gam_1',
      name: 'جمعية العائلة الكبرى',
      organizerId: 'org_1',
      totalPot: 50000,
      monthlyShareInstallment: 5000,
      totalMonths: 10,
      startDate: DateTime(2026, 1, 1),
      status: GameyaStatus.active,
      inviteCode: 'INV-123',
      createdAt: DateTime(2026, 1, 1),
    );

    final members = [
      MemberShare(
        id: 's1',
        gameyaId: 'gam_1',
        shareGroupId: 1,
        memberName: 'أحمد محمود',
        phone: '01011111111',
        shareRatio: 1.0,
        installmentAmount: 5000,
        payoutMonth: 3,
      ),
      MemberShare(
        id: 's2',
        gameyaId: 'gam_1',
        shareGroupId: 1,
        memberName: 'محمد عبد الله',
        phone: '01022222222',
        shareRatio: 0.5,
        installmentAmount: 2500,
        payoutMonth: 7,
      ),
    ];

    final installments = [
      Installment(
        id: 'inst_1',
        gameyaId: 'gam_1',
        memberShareId: 's1',
        monthNumber: 1,
        dueDate: DateTime(2026, 1, 5),
        amount: 5000,
        status: InstallmentStatus.paid,
      ),
      Installment(
        id: 'inst_2',
        gameyaId: 'gam_1',
        memberShareId: 's2',
        monthNumber: 1,
        dueDate: DateTime(2026, 1, 5),
        amount: 2500,
        status: InstallmentStatus.paid,
      ),
    ];

    setState(() {
      if (widget.isOrganizer) {
        if (_exportFormat == 'CSV') {
          _exportedPreview = ExportEngine.exportOrganizerCsv(
            gameya: gameya,
            members: members,
            installments: installments,
          );
        } else {
          _exportedPreview = ExportEngine.exportOrganizerJson(
            gameya: gameya,
            members: members,
            installments: installments,
          );
        }
      } else {
        if (_exportFormat == 'CSV') {
          _exportedPreview = ExportEngine.exportMemberStatementCsv(
            gameya: gameya,
            myShare: members[1],
            myInstallments: [installments[1]],
          );
        } else {
          _exportedPreview = ExportEngine.exportMemberStatementJson(
            gameya: gameya,
            myShare: members[1],
            myInstallments: [installments[1]],
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isOrganizer ? 'تصدير التقرير المالي (المنظم)' : 'كشف حساب شخصي (المشترك)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isOrganizer ? 'سجل التدقيق الشامل (Full Audit Trail)' : 'كشف حساب خاص ومحمي (Personal Statement)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.isOrganizer
                          ? 'يتضمن التقرير كافة الحركات المالية، أسماء المشتركين، أرقام الهواتف، وتواريخ السداد والاعتماد بصيغة رسمية.'
                          : 'يتضمن الكشف فقط دفعاتك وحصتك وموعد استحقاقك دون كشف أي بيانات شخصية لباقي الأعضاء.',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Text('صيغة التصدير:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('جدول إكسل (CSV)'),
                    selected: _exportFormat == 'CSV',
                    selectedColor: AppTheme.primaryLight.withOpacity(0.2),
                    onSelected: (_) => setState(() => _exportFormat = 'CSV'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('ملف بيانات (JSON)'),
                    selected: _exportFormat == 'JSON',
                    selectedColor: AppTheme.primaryLight.withOpacity(0.2),
                    onSelected: (_) => setState(() => _exportFormat = 'JSON'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _generateExport,
                icon: const Icon(Icons.download_outlined, color: Colors.white),
                label: Text('توليد كشف الحساب بصيغة $_exportFormat'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),

              if (_exportedPreview != null) ...[
                const SizedBox(height: 20),
                const Text('معاينة البيانات المصدرة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _exportedPreview!,
                      style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF38BDF8), fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
