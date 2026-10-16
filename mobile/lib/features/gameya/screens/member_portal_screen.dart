import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/installment.dart';
import '../providers/gameya_providers.dart';
import 'turn_swap_screen.dart';

class MemberPortalScreen extends ConsumerStatefulWidget {
  const MemberPortalScreen({super.key});

  @override
  ConsumerState<MemberPortalScreen> createState() => _MemberPortalScreenState();
}

class _MemberPortalScreenState extends ConsumerState<MemberPortalScreen> {
  bool _isUploading = false;

  Future<void> _uploadReceipt(Installment installment) async {
    setState(() => _isUploading = true);
    final repo = ref.read(firestoreRepositoryProvider);

    try {
      // Simulate client-compressed 80KB receipt bytes
      final dummyBytes = List.generate(80 * 1024, (i) => i % 256);
      await repo.uploadReceiptToFirestore(
        gameyaId: installment.gameyaId,
        installmentId: installment.id,
        compressedBytes: dummyBytes,
        filename: 'receipt_${installment.id}.jpg',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع إيصال التحويل بنجاح وبانتظار اعتماد المنظم!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في رفع الإيصال: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final memberSharesAsync = ref.watch(memberSharesStreamProvider);
    final memberShares = memberSharesAsync.value ?? [];

    // If no assigned share found for this phone, provide a graceful state
    final myShare = memberShares.isNotEmpty
        ? memberShares.first
        : null;

    final memberName = user?.displayName ?? (myShare?.memberName ?? 'محمد عبد الله');
    final shareRatio = myShare?.shareRatio ?? 0.5;
    final payoutMonth = myShare?.payoutMonth ?? 7;
    const currentMonth = 3;
    final monthlyInstallment = myShare?.installmentAmount ?? 2500.0;
    final remainingMonths = (payoutMonth - currentMonth).clamp(0, 100);

    final installmentsAsync = ref.watch(activeInstallmentsStreamProvider);
    final allInstallments = installmentsAsync.value ?? [];
    final myInstallment = allInstallments.firstWhere(
      (i) => myShare != null && i.memberShareId == myShare.id,
      orElse: () => Installment(
        id: 'inst_current',
        gameyaId: myShare?.gameyaId ?? 'gameya_family_2026',
        memberShareId: myShare?.id ?? 'm2',
        monthNumber: currentMonth,
        amount: monthlyInstallment,
        status: InstallmentStatus.pending,
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بوابتي الشخصية (المشترك)'),
          actions: [
            // Logout
            IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.errorRed),
              tooltip: 'تسجيل الخروج',
              onPressed: () async {
                final auth = ref.read(authRepositoryProvider);
                await auth.signOut();
                ref.read(currentUserProvider.notifier).state = null;
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Member Greeting Card
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
                          Text(
                            'قيمة استحقاقك: ${(50000 * shareRatio).toStringAsFixed(0)} ج.م',
                            style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
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
                        Text(
                          'قسط الشهر الحالي (شهر $currentMonth)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: myInstallment.status == InstallmentStatus.paid
                                ? AppTheme.primaryGreen.withOpacity(0.1)
                                : myInstallment.status == InstallmentStatus.review
                                    ? Colors.blue.withOpacity(0.1)
                                    : AppTheme.accentGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            myInstallment.status == InstallmentStatus.paid
                                ? 'مدفوع ومُعتمد ✔'
                                : myInstallment.status == InstallmentStatus.review
                                    ? 'قيد مراجعة المنظم'
                                    : 'في الانتظار',
                            style: TextStyle(
                              color: myInstallment.status == InstallmentStatus.paid
                                  ? AppTheme.primaryGreen
                                  : myInstallment.status == InstallmentStatus.review
                                      ? Colors.blue
                                      : AppTheme.accentGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'المبلغ المطلوب: ${myInstallment.amount.toStringAsFixed(0)} ج.م',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'فترة السماح سارية حتى يوم 10 من الشهر.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Receipt Upload Button
                    if (myInstallment.status != InstallmentStatus.paid)
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : () => _uploadReceipt(myInstallment),
                        icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                        label: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(myInstallment.status == InstallmentStatus.review
                                ? 'تحديث إيصال التحويل'
                                : 'رفع إيصال التحويل (صورة)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: myInstallment.status == InstallmentStatus.review ? Colors.blue : AppTheme.primaryGreen,
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
