import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/math_validator.dart';

class CreationWizardScreen extends StatefulWidget {
  const CreationWizardScreen({super.key});

  @override
  State<CreationWizardScreen> createState() => _CreationWizardScreenState();
}

class _CreationWizardScreenState extends State<CreationWizardScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController(text: 'جمعية الزملاء والأصدقاء');
  final _totalPotController = TextEditingController(text: '100000');
  int _totalMonths = 10;
  int _gracePeriodDays = 7;

  // Month allocations: month -> list of member shares (ratio)
  late Map<int, double> _monthAllocations;

  @override
  void initState() {
    super.initState();
    _resetAllocations();
  }

  void _resetAllocations() {
    _monthAllocations = {
      for (int i = 1; i <= _totalMonths; i++) i: (i <= 8 ? 1.0 : (i == 9 ? 0.5 : 0.0)) // Month 9 has 50%, Month 10 has 0% by default to demonstrate balancer!
    };
  }

  double get _totalPot => double.tryParse(_totalPotController.text) ?? 100000.0;
  double get _monthlyInstallment => _totalMonths > 0 ? _totalPot / _totalMonths : 0.0;

  bool get _isBalanced {
    return _monthAllocations.values.every((ratio) => (ratio - 1.0).abs() < 0.001);
  }

  void _fillBalanced() {
    setState(() {
      for (int i = 1; i <= _totalMonths; i++) {
        _monthAllocations[i] = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAllBalanced = _isBalanced;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء جمعية جديدة وميزان الشهور'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calculate, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ميزان الشهور الذكي (Month Balancer)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'لا يمكن تفعيل أي جمعية إلا بعد موازنة كل شهر بنسبة 100% تماماً.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Basic Details
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الجمعية',
                    prefixIcon: Icon(Icons.group, color: AppTheme.primaryGreen),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _totalPotController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'إجمالي الجمعية (ج.م)',
                          prefixIcon: Icon(Icons.account_balance_wallet, color: AppTheme.primaryGreen),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _totalMonths,
                        decoration: const InputDecoration(
                          labelText: 'عدد الشهور',
                          prefixIcon: Icon(Icons.calendar_month, color: AppTheme.primaryGreen),
                        ),
                        items: [5, 10, 12, 20].map((m) => DropdownMenuItem(value: m, child: Text('$m شهور'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _totalMonths = val;
                              _resetAllocations();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Calculated share info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('قيمة القسط الشهري للسهم الكامل (100%):', style: TextStyle(color: AppTheme.textMuted)),
                      Text(
                        '${_monthlyInstallment.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 15),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Month Balancer Grid Title & Auto-balance helper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'توزيع حصص الشهور (ميزان الـ 100%):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                    ),
                    TextButton.icon(
                      onPressed: _fillBalanced,
                      icon: const Icon(Icons.auto_fix_high, size: 16),
                      label: const Text('موازنة تلقائية 100%'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Month Grid
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _totalMonths,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final monthNum = idx + 1;
                    final ratio = _monthAllocations[monthNum] ?? 0.0;
                    final percent = (ratio * 100).round();
                    final isMonthBalanced = (ratio - 1.0).abs() < 0.001;
                    final isOver = ratio > 1.0;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMonthBalanced
                              ? AppTheme.primaryLight
                              : isOver
                                  ? AppTheme.errorRed
                                  : AppTheme.accentGold,
                          width: isMonthBalanced ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isMonthBalanced
                                  ? AppTheme.primaryGreen.withOpacity(0.1)
                                  : isOver
                                      ? AppTheme.errorRed.withOpacity(0.1)
                                      : AppTheme.accentGold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isMonthBalanced
                                  ? Icons.check_circle
                                  : isOver
                                      ? Icons.warning
                                      : Icons.timelapse,
                              color: isMonthBalanced
                                  ? AppTheme.primaryGreen
                                  : isOver
                                      ? AppTheme.errorRed
                                      : AppTheme.accentGold,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'شهر $monthNum',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  'المحجوز: $percent% (المبلغ: ${(ratio * _totalPot).toStringAsFixed(0)} ج.م)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMonthBalanced ? AppTheme.primaryGreen : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Ratio controls: 0.25 steps
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                            onPressed: ratio > 0.0
                                ? () {
                                    setState(() {
                                      _monthAllocations[monthNum] = (ratio - 0.25).clamp(0.0, 2.0);
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            '$percent%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMonthBalanced
                                  ? AppTheme.primaryGreen
                                  : isOver
                                      ? AppTheme.errorRed
                                      : AppTheme.accentGold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryGreen),
                            onPressed: ratio < 2.0
                                ? () {
                                    setState(() {
                                      _monthAllocations[monthNum] = (ratio + 0.25).clamp(0.0, 2.0);
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Hard Activation Banner Guard
                if (!isAllBalanced)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2), // Red light 50
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.errorRed),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, color: AppTheme.errorRed),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'زر التفعيل مقفل: يوجد شهور غير مكتملة بنسبة 100%. اضغط "موازنة تلقائية" أو وزّع الحصص بدقة.',
                            style: TextStyle(color: AppTheme.errorRed, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5), // Emerald light
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryLight),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, color: AppTheme.primaryGreen),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'الميزان مكتمل 100%! الحسابات الرياضية محكمة والجمعية جاهزة للتفعيل.',
                            style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Activate Button
                ElevatedButton(
                  onPressed: isAllBalanced
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إنشاء وتفعيل الجمعية بنجاح مع قفل المعاملات الرياضية!'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAllBalanced ? AppTheme.primaryGreen : Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('حفظ وتفعيل الجمعية (مقفلة حسابياً)', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
