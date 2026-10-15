import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'turn_swap_screen.dart';

class MemberPortalScreen extends StatefulWidget {
  const MemberPortalScreen({super.key});

  @override
  State<MemberPortalScreen> createState() => _MemberPortalScreenState();
}

class _MemberPortalScreenState extends State<MemberPortalScreen> {
  // Member State
  final String memberName = 'محمد عبد الله';
  final double shareRatio = 0.5; // Half share
  final int payoutMonth = 7;
  final int currentMonth = 3;
  final double monthlyInstallment = 2500.0;
  bool hasUploadedReceipt = false;

  @override
  Widget build(BuildContext context) {
    final remainingMonths = payoutMonth - currentMonth;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بوابتي الشخصية (المشترك)'),
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
              // Member Greeting & Privacy Assurance Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'أهلاً، $memberName',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            shareRatio == 0.5 ? 'نصف سهم (50%)' : 'سهم كامل (100%)',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'جمعية العائلة الكبرى (10 شهور)',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'القسط الشهري الخاص بك: ${monthlyInstallment.toStringAsFixed(0)} ج.م',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Turn Countdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hourglass_top_outlined, color: AppTheme.accentGold, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('موعد استلامك للقبض:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                          Text(
                            'شهر $payoutMonth (متبقي $remainingMonths شهور)',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'قيمة استحقاقك: 25,000 ج.م (نصف سهم)',
                            style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Current Month Action Card (Month 3)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'قسط الشهر الحالي (شهر 3)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasUploadedReceipt
                                ? Colors.blue.withOpacity(0.1)
                                : AppTheme.accentGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            hasUploadedReceipt ? 'قيد مراجعة المنظم' : 'في الانتظار',
                            style: TextStyle(
                              color: hasUploadedReceipt ? Colors.blue : AppTheme.accentGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'المبلغ المطلوب: ${monthlyInstallment.toStringAsFixed(0)} ج.م',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'فترة السماح سارية حتى يوم 10 من الشهر.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Receipt Upload Button
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          hasUploadedReceipt = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم ضغط الصورة لأقل من 150KB ورفع الإيصال بنجاح للمراجعة!'),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                      label: Text(hasUploadedReceipt ? 'تحديث إيصال التحويل' : 'رفع إيصال التحويل (صورة)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasUploadedReceipt ? Colors.blue : AppTheme.primaryGreen,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Swap Turn CTA Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TurnSwapScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.swap_horiz, color: AppTheme.primaryGreen),
                label: const Text('طلب تبديل الدور مع مشترك آخر', style: TextStyle(color: AppTheme.primaryGreen)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.primaryGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 24),

              // My Installment History
              const Text(
                'سجل دفعاتي السابقة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),

              _buildHistoryCard(
                month: 1,
                amount: monthlyInstallment,
                status: 'تم السداد والاعتماد',
                date: '1 يناير 2026',
              ),
              _buildHistoryCard(
                month: 2,
                amount: monthlyInstallment,
                status: 'تم السداد والاعتماد',
                date: '1 فبراير 2026',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard({required int month, required double amount, required String status, required String date}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
        title: Text('قسط شهر $month — ${amount.toStringAsFixed(0)} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('$status • $date', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      ),
    );
  }
}
