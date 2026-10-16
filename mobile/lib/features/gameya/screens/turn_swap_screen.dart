import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TurnSwapScreen extends StatefulWidget {
  const TurnSwapScreen({super.key});

  @override
  State<TurnSwapScreen> createState() => _TurnSwapScreenState();
}

class _TurnSwapScreenState extends State<TurnSwapScreen> {
  String? selectedCandidateId;

  // Eligible members who share the exact same ratio (0.5)
  final List<Map<String, dynamic>> eligibleCandidates = [
    {
      'id': 'share_2',
      'name': 'كريم حسن',
      'shareRatio': 0.5,
      'monthNumber': 4,
      'amount': 25000,
    },
    {
      'id': 'share_5',
      'name': 'طارق يوسف',
      'shareRatio': 0.5,
      'monthNumber': 9,
      'amount': 25000,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلب تبديل الدور'),
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
              // Invariant explanation card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppTheme.primaryGreen, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'شرط التبديل العادل (Ratio Matching)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryGreen),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'بما أن حصتك "نصف سهم (50%)"، يظهر فقط الأعضاء المشتركون بنفس الحصة حفاظاً على توازن ميزانية الجمعية.',
                            style: TextStyle(fontSize: 12, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'اختر العضو المراد التبديل معه:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
              ),

              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: eligibleCandidates.length,
                itemBuilder: (context, idx) {
                  final candidate = eligibleCandidates[idx];
                  final isSelected = selectedCandidateId == candidate['id'];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          selectedCandidateId = candidate['id'];
                        });
                      },
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                        child: Text('${candidate['monthNumber']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                      ),
                      title: Text(candidate['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('دور شهر ${candidate['monthNumber']} • حصة: 50% (نصف سهم)'),
                      trailing: Radio<String>(
                        value: candidate['id'],
                        groupValue: selectedCandidateId,
                        activeColor: AppTheme.primaryGreen,
                        onChanged: (val) {
                          setState(() {
                            selectedCandidateId = val;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Workflow Steps Visualizer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('خطوات اعتماد التبديل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 8),
                    Text('1. إرسال طلب التبديل إلى الطرف الثاني للموافقة المبدئية.', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    Text('2. بعد موافقة الطرفين، يتم إشعار المنظم للمراجعة والاعتماد النهائي.', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    Text('3. يتم تحديث جدول القبض تلقائياً وإخطار المشتركين عبر واتساب.', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: selectedCandidateId != null
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إرسال طلب التبديل بنجاح للطرف الثاني وبانتظار موافقته!'),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    : null,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text('إرسال طلب التبديل'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: selectedCandidateId != null ? AppTheme.primaryGreen : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
