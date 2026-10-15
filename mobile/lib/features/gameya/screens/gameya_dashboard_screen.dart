import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/whatsapp_helper.dart';

class GameyaDashboardScreen extends StatefulWidget {
  const GameyaDashboardScreen({super.key});

  @override
  State<GameyaDashboardScreen> createState() => _GameyaDashboardScreenState();
}

class _GameyaDashboardScreenState extends State<GameyaDashboardScreen> {
  bool isOrganizerRole = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جمعية العائلة الكبرى (10 شهور)'),
        actions: [
          // Role Toggle Pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: ChoiceChip(
              label: Text(isOrganizerRole ? 'وضع المنظم (أدمن)' : 'وضع المشترك'),
              selected: isOrganizerRole,
              selectedColor: AppTheme.primaryLight.withOpacity(0.2),
              onSelected: (val) {
                setState(() {
                  isOrganizerRole = !isOrganizerRole;
                });
              },
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Real-Time Month Balancer Alert
              _buildMonthBalancerBanner(),

              const SizedBox(height: 16),

              // KPI Summary Cards
              _buildKpiGrid(),

              const SizedBox(height: 20),

              // Broadcast Summary Button (Organizer Only)
              if (isOrganizerRole) _buildGroupBroadcastButton(),

              const SizedBox(height: 16),

              // Month Payout Beneficiary Highlight
              _buildBeneficiaryCard(),

              const SizedBox(height: 16),

              // Installment Tracking Table / Member List
              _buildInstallmentsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: isOrganizerRole
          ? FloatingActionButton.extended(
              onPressed: () {
                // Open new Gameya wizard
              },
              backgroundColor: AppTheme.primaryGreen,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('إنشاء جمعية جديدة', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildMonthBalancerBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5), // Emerald light 50
        borderRadius: BorderRadius.circular(12),
        border: Border.pad(BorderSide(color: AppTheme.primaryLight, width: 1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'الحماية الرياضية: جميع شهور الجمعية (1-10) مكتملة وموزونة بنسبة 100% بدون أي عجز.',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'إجمالي الصندوق',
            value: '50,000 ج.م',
            subtitle: '5,000 ج.م شهرياً',
            icon: Icons.account_balance_wallet_outlined,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            title: 'الشهر الحالي',
            value: 'شهر 3 من 10',
            subtitle: 'فترة سماح 7 أيام',
            icon: Icons.calendar_month_outlined,
            color: AppTheme.accentGold,
          ),
        ),
      ],
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

  Widget _buildGroupBroadcastButton() {
    return ElevatedButton.icon(
      onPressed: () {
        final broadcastText = WhatsAppHelper.buildGroupBroadcastSummary(
          gameyaName: 'جمعية العائلة الكبرى',
          currentMonth: 3,
          beneficiaryName: 'أحمد محمود (سهم كامل)',
          totalCollected: 35000,
          totalExpected: 50000,
          paidCount: 7,
          totalMembers: 10,
          currency: 'ج.م',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم نسخ تقرير المتابعة لمشاركته في جروب الواتساب:\n\n$broadcastText'),
            duration: const Duration(seconds: 4),
          ),
        );
      },
      icon: const Icon(Icons.share_outlined, color: Colors.white),
      label: const Text('مشاركة تقرير المتابعة في جروب الواتساب'),
    );
  }

  Widget _buildBeneficiaryCard() {
    return Container(
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
              color: AppTheme.primaryLight.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المستفيد من القبض (شهر 3)',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                Text(
                  'أحمد محمود — 50,000 ج.م',
                  style: TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'الحالة: في انتظار اكتمال تحصيل الأقساط للتسليم',
                  style: TextStyle(color: AppTheme.accentGold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أقساط المشتركين (شهر 3)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        _buildMemberRow(
          name: 'محمد عبد الله (نصف سهم - 50%)',
          phone: '01012345678',
          amount: '2,500 ج.م',
          status: 'مدفوع ✔',
          statusColor: AppTheme.primaryGreen,
          isPaid: true,
        ),
        _buildMemberRow(
          name: 'كريم حسن (نصف سهم - 50%)',
          phone: '01123456789',
          amount: '2,500 ج.م',
          status: 'في الانتظار (تذكير)',
          statusColor: AppTheme.accentGold,
          isPaid: false,
        ),
        _buildMemberRow(
          name: 'سارة إبراهيم (سهم كامل - 100%)',
          phone: '01234567890',
          amount: '5,000 ج.م',
          status: 'قيد مراجعة الإيصال',
          statusColor: Colors.blue,
          isPaid: false,
        ),
      ],
    );
  }

  Widget _buildMemberRow({
    required String name,
    required String phone,
    required String amount,
    required String status,
    required Color statusColor,
    required bool isPaid,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text('المبلغ: $amount • $status', style: TextStyle(color: statusColor, fontSize: 12)),
        trailing: isOrganizerRole && !isPaid
            ? IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryGreen),
                tooltip: 'تذكير واتساب بضغطة زر',
                onPressed: () {
                  WhatsAppHelper.openWhatsApp(
                    phone: phone,
                    message: WhatsAppHelper.buildInstallmentReminderMessage(
                      memberName: name,
                      gameyaName: 'جمعية العائلة الكبرى',
                      monthNumber: 3,
                      amount: 2500,
                      currency: 'ج.م',
                    ),
                  );
                },
              )
            : isPaid
                ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen)
                : null,
      ),
    );
  }
}
