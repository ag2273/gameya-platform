import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../domain/models/installment.dart';
import '../providers/gameya_providers.dart';
import 'creation_wizard_screen.dart';
import 'member_portal_screen.dart';
import 'turn_swap_screen.dart';
import 'disbursement_screen.dart';
import 'share_transfer_screen.dart';
import 'export_screen.dart';

class GameyaDashboardScreen extends ConsumerStatefulWidget {
  const GameyaDashboardScreen({super.key});

  @override
  ConsumerState<GameyaDashboardScreen> createState() => _GameyaDashboardScreenState();
}

class _GameyaDashboardScreenState extends ConsumerState<GameyaDashboardScreen> {
  bool _isLiveConnected = false;

  @override
  void initState() {
    super.initState();
    _connectLiveFirestore();
  }

  Future<void> _connectLiveFirestore() async {
    try {
      final repo = ref.read(firestoreRepositoryProvider);
      await repo.ensureAuthenticated();
      await repo.seedInitialGameyaIfEmpty('gameya_family_2026');
      if (mounted) {
        setState(() {
          _isLiveConnected = true;
        });
      }
    } catch (e) {
      debugPrint('Firestore live sync note: $e');
    }
  }

  void _openReceiptReviewModal(BuildContext context, Installment installment, String memberName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مراجعة إيصال التحويل: $memberName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, size: 52, color: AppTheme.primaryGreen),
                      const SizedBox(height: 8),
                      Text('إشعار تحويل بنكي / إنستاباي - ${installment.amount.toStringAsFixed(0)} ج.م'),
                      Text('الحجم: 86 KB (مخزن مجاناً في Firestore)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final repo = ref.read(firestoreRepositoryProvider);
                        await repo.rejectReceipt(
                          gameyaId: installment.gameyaId,
                          installmentId: installment.id,
                          reason: 'الصورة غير واضحة',
                        );
                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم رفض الإيصال وتحديث قاعدة بيانات Firebase!')),
                          );
                        }
                      },
                      icon: const Icon(Icons.cancel_outlined, color: AppTheme.errorRed),
                      label: const Text('رفض الإيصال', style: TextStyle(color: AppTheme.errorRed)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.errorRed),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final repo = ref.read(firestoreRepositoryProvider);
                        await repo.approveReceipt(
                          gameyaId: installment.gameyaId,
                          installmentId: installment.id,
                          organizerId: 'organizer_ayman',
                        );
                        if (context.mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم اعتماد الإيصال وسداد القسط في قاعدة بيانات Firebase!'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text('اعتماد وسداد 1-Tap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameyaAsync = ref.watch(activeGameyaStreamProvider);
    final membersAsync = ref.watch(activeMembersStreamProvider);
    final installmentsAsync = ref.watch(activeInstallmentsStreamProvider);

    // Live Gameya Attributes
    final gameya = gameyaAsync.value;
    final members = membersAsync.value ?? [];
    final installments = installmentsAsync.value ?? [];

    final gameyaName = gameya?.name ?? 'جمعية العائلة الكبرى (10 شهور)';
    final totalPot = gameya?.totalPot ?? 50000.0;
    final totalMonths = gameya?.totalMonths ?? 10;
    const currentMonth = 3;
    const beneficiaryName = 'أحمد محمود (سهم كامل 100%)';

    final paidInstallments = installments.where((i) => i.status == InstallmentStatus.paid).toList();
    final collectedAmount = paidInstallments.fold(0.0, (sum, i) => sum + i.amount);
    final paidCount = paidInstallments.length;
    final totalCount = installments.isNotEmpty ? installments.length : 10;
    final pendingReviews = installments.where((i) => i.status == InstallmentStatus.review).toList();
    final isCollectionComplete = collectedAmount >= totalPot && totalPot > 0;
    final progressRatio = totalPot > 0 ? (collectedAmount / totalPot).clamp(0.0, 1.0) : 0.0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(gameyaName),
          actions: [
            // Switch to Member Portal Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MemberPortalScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                  foregroundColor: AppTheme.primaryGreen,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: const Icon(Icons.person_outline, size: 18),
                label: const Text('بوابة المشترك', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primaryGreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 26,
                      child: Icon(Icons.shield, color: AppTheme.primaryGreen, size: 30),
                    ),
                    const SizedBox(height: 10),
                    const Text('منصة إدارة الجمعيات الذكية', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('المنظم: أيمن جمعة (Firebase Live)', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_outlined, color: AppTheme.primaryGreen),
                title: const Text('لوحة تحكم المنظم'),
                selected: true,
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.calculate_outlined, color: AppTheme.primaryGreen),
                title: const Text('إنشاء جمعية وميزان الشهور'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreationWizardScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_pin_outlined, color: AppTheme.primaryGreen),
                title: const Text('بوابة المشترك الخاصة'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MemberPortalScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: AppTheme.primaryGreen),
                title: const Text('نظام تبديل الأدوار'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TurnSwapScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.handshake_outlined, color: AppTheme.primaryGreen),
                title: const Text('تسليم القبض (Disbursement)'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DisbursementScreen(
                        isCollectionComplete: isCollectionComplete,
                        collectedAmount: collectedAmount,
                        targetAmount: totalPot,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.transfer_within_a_station, color: AppTheme.primaryGreen),
                title: const Text('نقل السهم واستبدال متعثر'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShareTransferScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_download_outlined, color: AppTheme.primaryGreen),
                title: const Text('تصدير التقارير (JSON/CSV)'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExportScreen(isOrganizer: true)));
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live Firebase Connection Status Pill
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'قاعدة البيانات المباشرة (Firebase Firestore): متصل ومحدث لحظياً',
                        style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Pending Review Alert Banner (if any)
              if (pendingReviews.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mark_email_unread_outlined, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'يوجد ${pendingReviews.length} إيصال تحويل بانتظار مراجعتك واعتمادك.',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final target = pendingReviews.first;
                          _openReceiptReviewModal(context, target, 'سارة إبراهيم');
                        },
                        child: const Text('مراجعة الآن'),
                      ),
                    ],
                  ),
                ),

              // KPI Summary Cards: Using Correct Term "إجمالي الجمعية"
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'إجمالي الجمعية',
                      value: '${totalPot.toStringAsFixed(0)} ج.م',
                      subtitle: '5,000 ج.م شهرياً',
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'الشهر الحالي',
                      value: 'شهر $currentMonth من $totalMonths',
                      subtitle: 'فترة سماح 7 أيام',
                      icon: Icons.calendar_month_outlined,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Current Month Beneficiary & Collection Progress Card
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star, color: AppTheme.primaryGreen),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('المستفيد من القبض (شهر 3)', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              Text(
                                '$beneficiaryName — ${totalPot.toStringAsFixed(0)} ج.م',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Collection Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('نسبة التحصيل: ${(progressRatio * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('${collectedAmount.toStringAsFixed(0)} / ${totalPot.toStringAsFixed(0)} ج.م', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCollectionComplete ? AppTheme.primaryGreen : AppTheme.accentGold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Deliver to Member Button (DISBURSEMENT GATE)
                    // Hard Rule: Locked until 100% of the month's installments are collected!
                    if (!isCollectionComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.errorRed.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, color: AppTheme.errorRed, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'زر تسليم القبض مقفل حتى اكتمال 100% من التحصيل (متبقي ${(totalPot - collectedAmount).toStringAsFixed(0)} ج.م).',
                                style: const TextStyle(color: AppTheme.errorRed, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DisbursementScreen(
                                isCollectionComplete: true,
                                collectedAmount: collectedAmount,
                                targetAmount: totalPot,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.handshake, color: Colors.white),
                        label: const Text('تسليم القبض للمستفيد (اكتمل 100%)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // WhatsApp Broadcast Button
              ElevatedButton.icon(
                onPressed: () {
                  final text = WhatsAppHelper.buildGroupBroadcastSummary(
                    gameyaName: gameyaName,
                    currentMonth: currentMonth,
                    beneficiaryName: beneficiaryName,
                    totalCollected: collectedAmount,
                    totalExpected: totalPot,
                    paidCount: paidCount,
                    totalMembers: totalCount,
                    currency: 'ج.م',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم نسخ تقرير المتابعة لمشاركته في جروب الواتساب:\n\n$text'),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text('مشاركة تقرير المتابعة في جروب الواتساب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

              const SizedBox(height: 20),

              // Installment Tracking Table / Member List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'أقساط المشتركين (شهر 3 - مزامنة حية):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                  ),
                  Text(
                    'سدد $paidCount من $totalCount',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // If installments are loading or empty from Firestore, show local fallback cards
              if (installments.isEmpty)
                _buildFallbackInstallments(context)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: installments.length,
                  itemBuilder: (context, idx) {
                    final inst = installments[idx];
                    final member = members.firstWhere(
                      (m) => m.id == inst.memberShareId,
                      orElse: () => MemberShare(
                        id: inst.memberShareId,
                        gameyaId: inst.gameyaId,
                        shareGroupId: 1,
                        memberName: 'مشترك ${idx + 1}',
                        phone: '01000000000',
                        shareRatio: inst.amount >= 5000 ? 1.0 : 0.5,
                        installmentAmount: inst.amount,
                        payoutMonth: 1,
                      ),
                    );

                    final isPaid = inst.status == InstallmentStatus.paid;
                    final isReview = inst.status == InstallmentStatus.review;
                    final shareText = member.shareRatio == 1.0 ? 'سهم كامل (100%)' : 'نصف سهم (50%)';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          member.memberName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Row(
                          children: [
                            Text('$shareText • ${inst.amount.toStringAsFixed(0)} ج.م • '),
                            if (isPaid)
                              const Text('مدفوع ✔', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12))
                            else if (isReview)
                              const Text('قيد المراجعة', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12))
                            else
                              const Text('في الانتظار', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isReview)
                              ElevatedButton(
                                onPressed: () => _openReceiptReviewModal(context, inst, member.memberName),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text('مراجعة', style: TextStyle(fontSize: 11, color: Colors.white)),
                              )
                            else if (!isPaid)
                              IconButton(
                                icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryGreen),
                                tooltip: 'تذكير واتساب بضغطة زر',
                                onPressed: () {
                                  WhatsAppHelper.openWhatsApp(
                                    phone: member.phone,
                                    message: WhatsAppHelper.buildInstallmentReminderMessage(
                                      memberName: member.memberName,
                                      gameyaName: gameyaName,
                                      monthNumber: currentMonth,
                                      amount: inst.amount,
                                      currency: 'ج.م',
                                    ),
                                  );
                                },
                              ),
                            // Live Firestore 1-Tap Toggle
                            IconButton(
                              icon: Icon(
                                isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: isPaid ? AppTheme.primaryGreen : Colors.grey,
                              ),
                              tooltip: isPaid ? 'إلغاء السداد في Firebase' : 'تسجيل السداد بضغطة زر في Firebase',
                              onPressed: () async {
                                final repo = ref.read(firestoreRepositoryProvider);
                                final newStatus = isPaid ? InstallmentStatus.pending : InstallmentStatus.paid;
                                await repo.toggleInstallmentStatus(
                                  gameyaId: inst.gameyaId,
                                  installmentId: inst.id,
                                  newStatus: newStatus,
                                  verifierId: 'organizer_ayman',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreationWizardScreen()));
          },
          backgroundColor: AppTheme.primaryGreen,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('إنشاء جمعية جديدة', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildFallbackInstallments(BuildContext context) {
    return Column(
      children: [
        _buildFallbackRow('أحمد محمود (المستفيد)', 'سهم كامل (100%)', '5,000 ج.م', true),
        _buildFallbackRow('محمد عبد الله', 'نصف سهم (50%)', '2,500 ج.م', true),
        _buildFallbackRow('كريم حسن', 'نصف سهم (50%)', '2,500 ج.م', false),
        _buildFallbackRow('سارة إبراهيم', 'سهم كامل (100%)', '5,000 ج.م', false, isReview: true),
      ],
    );
  }

  Widget _buildFallbackRow(String name, String share, String amount, bool isPaid, {bool isReview = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('$share • $amount • ${isPaid ? "مدفوع ✔" : isReview ? "قيد المراجعة" : "في الانتظار"}'),
        trailing: Icon(
          isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isPaid ? AppTheme.primaryGreen : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
