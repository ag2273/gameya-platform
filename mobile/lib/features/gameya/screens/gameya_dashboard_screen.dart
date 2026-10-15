import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/whatsapp_helper.dart';
import 'creation_wizard_screen.dart';
import 'member_portal_screen.dart';
import 'turn_swap_screen.dart';
import 'disbursement_screen.dart';
import 'share_transfer_screen.dart';
import 'export_screen.dart';

class GameyaDashboardScreen extends StatefulWidget {
  const GameyaDashboardScreen({super.key});

  @override
  State<GameyaDashboardScreen> createState() => _GameyaDashboardScreenState();
}

class _GameyaDashboardScreenState extends State<GameyaDashboardScreen> {
  // Mock Data for Active Gameya
  final String gameyaName = 'جمعية العائلة الكبرى (10 شهور)';
  final double totalPot = 50000.0;
  final int totalMonths = 10;
  final int currentMonth = 3;
  final String beneficiaryName = 'أحمد محمود (سهم كامل 100%)';

  // Dynamic installments state for Month 3
  List<Map<String, dynamic>> installments = [
    {
      'id': '1',
      'name': 'أحمد محمود (المستفيد)',
      'phone': '01011111111',
      'shareRatio': 1.0,
      'amount': 5000.0,
      'status': 'paid', // paid
      'hasReceipt': false,
    },
    {
      'id': '2',
      'name': 'محمد عبد الله',
      'phone': '01022222222',
      'shareRatio': 0.5,
      'amount': 2500.0,
      'status': 'paid', // paid
      'hasReceipt': false,
    },
    {
      'id': '3',
      'name': 'كريم حسن',
      'phone': '01033333333',
      'shareRatio': 0.5,
      'amount': 2500.0,
      'status': 'pending', // pending
      'hasReceipt': false,
    },
    {
      'id': '4',
      'name': 'سارة إبراهيم',
      'phone': '01044444444',
      'shareRatio': 1.0,
      'amount': 5000.0,
      'status': 'review', // review pending
      'hasReceipt': true,
      'receiptTime': 'اليوم 10:30 ص',
    },
    {
      'id': '5',
      'name': 'محمود عبد العزيز',
      'phone': '01055555555',
      'shareRatio': 1.0,
      'amount': 5000.0,
      'status': 'paid',
      'hasReceipt': false,
    },
    {
      'id': '6',
      'name': 'منى الشاذلي',
      'phone': '01066666666',
      'shareRatio': 1.0,
      'amount': 5000.0,
      'status': 'paid',
      'hasReceipt': false,
    },
    {
      'id': '7',
      'name': 'ياسر جلال',
      'phone': '01077777777',
      'shareRatio': 1.0,
      'amount': 5000.0,
      'status': 'paid',
      'hasReceipt': false,
    },
    {
      'id': '8',
      'name': 'هاني شاكر',
      'phone': '01088888888',
      'shareRatio': 1.0,
      'amount': 5000.0,
      'status': 'paid',
      'hasReceipt': false,
    },
    {
      'id': '9',
      'name': 'عمرو دياب',
      'phone': '01099999999',
      'shareRatio': 1.0,
      'amount': 5000.0,
      'status': 'paid',
      'hasReceipt': false,
    },
    {
      'id': '10',
      'name': 'تامر حسني',
      'phone': '01000000000',
      'shareRatio': 1.0,
      'amount': 5000.0,
      'status': 'paid',
      'hasReceipt': false,
    },
  ];

  double get collectedAmount {
    return installments
        .where((i) => i['status'] == 'paid')
        .fold(0.0, (sum, i) => sum + (i['amount'] as double));
  }

  int get paidCount => installments.where((i) => i['status'] == 'paid').length;
  int get pendingReviewCount => installments.where((i) => i['status'] == 'review').length;
  bool get isCollectionComplete => collectedAmount >= totalPot;

  void _toggleInstallment(int idx) {
    setState(() {
      if (installments[idx]['status'] == 'paid') {
        installments[idx]['status'] = 'pending';
      } else {
        installments[idx]['status'] = 'paid';
      }
    });
  }

  void _openReceiptReview(int idx) {
    final item = installments[idx];
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
                    'مراجعة إيصال التحويل: ${item['name']}',
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
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, size: 56, color: AppTheme.primaryGreen),
                      const SizedBox(height: 8),
                      Text('إشعار تحويل بنكي / إنستاباي - ${(item['amount'] as double).toStringAsFixed(0)} ج.م'),
                      Text('الحجم: 86 KB (مضغوط بتقنية ADR-0009)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          installments[idx]['status'] = 'pending';
                        });
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم رفض الإيصال وطلب إعادة الرفع من المشترك')),
                        );
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
                      onPressed: () {
                        setState(() {
                          installments[idx]['status'] = 'paid';
                        });
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم اعتماد الإيصال وتسجيل القسط كمدفوع بنجاح!'),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
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
    final progressRatio = (collectedAmount / totalPot).clamp(0.0, 1.0);

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
                    Text('المنظم: أيمن جمعة', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
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
              // Pending Review Alert Banner (if any)
              if (pendingReviewCount > 0)
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
                          'يوجد $pendingReviewCount إيصال تحويل بانتظار مراجعتك واعتمادك.',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final reviewIdx = installments.indexWhere((i) => i['status'] == 'review');
                          if (reviewIdx != -1) _openReceiptReview(reviewIdx);
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
                    gameyaName: 'جمعية العائلة الكبرى',
                    currentMonth: currentMonth,
                    beneficiaryName: beneficiaryName,
                    totalCollected: collectedAmount,
                    totalExpected: totalPot,
                    paidCount: paidCount,
                    totalMembers: installments.length,
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
                  Text(
                    'أقساط المشتركين (شهر $currentMonth):',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                  ),
                  Text(
                    'سدد $paidCount من ${installments.length}',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: installments.length,
                itemBuilder: (context, idx) {
                  final item = installments[idx];
                  final isPaid = item['status'] == 'paid';
                  final isReview = item['status'] == 'review';
                  final amount = item['amount'] as double;
                  final shareRatio = item['shareRatio'] as double;
                  final shareText = shareRatio == 1.0 ? 'سهم كامل (100%)' : 'نصف سهم (50%)';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Row(
                        children: [
                          Text('$shareText • ${amount.toStringAsFixed(0)} ج.م • '),
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
                              onPressed: () => _openReceiptReview(idx),
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
                                  phone: item['phone'],
                                  message: WhatsAppHelper.buildInstallmentReminderMessage(
                                    memberName: item['name'],
                                    gameyaName: 'جمعية العائلة الكبرى',
                                    monthNumber: currentMonth,
                                    amount: amount,
                                    currency: 'ج.م',
                                  ),
                                );
                              },
                            ),
                          // 1-Tap Toggle between Paid and Pending
                          IconButton(
                            icon: Icon(
                              isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isPaid ? AppTheme.primaryGreen : Colors.grey,
                            ),
                            tooltip: isPaid ? 'إلغاء السداد' : 'تسجيل السداد بضغطة زر',
                            onPressed: () => _toggleInstallment(idx),
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
