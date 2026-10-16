import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DisbursementScreen extends StatefulWidget {
  final bool isCollectionComplete;
  final double collectedAmount;
  final double targetAmount;

  const DisbursementScreen({
    super.key,
    this.isCollectionComplete = true,
    this.collectedAmount = 50000.0,
    this.targetAmount = 50000.0,
  });

  @override
  State<DisbursementScreen> createState() => _DisbursementScreenState();
}

class _DisbursementScreenState extends State<DisbursementScreen> {
  final _beneficiaryName = 'أحمد محمود';
  final _amount = 50000.0;
  final _payoutMethod = 'تحويل بنكي / إنستاباي (InstaPay)';
  bool _isDelivered = false;

  @override
  Widget build(BuildContext context) {
    final canDisburse = widget.isCollectionComplete;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسليم القبض لشهر 3'),
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
              // Beneficiary summary card
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
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                          radius: 24,
                          child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _beneficiaryName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                              ),
                              const Text('المستحق للقبض في دور شهر 3 (سهم كامل 100%)', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('مبلغ القبض المستحق:', style: TextStyle(color: AppTheme.textMuted)),
                        Text(
                          '${_amount.toStringAsFixed(0)} ج.م',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('وسيلة الاستلام المفضلة:', style: TextStyle(color: AppTheme.textMuted)),
                        Text(_payoutMethod, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Collection Validation Status Box
              if (!canDisburse)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.errorRed),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: AppTheme.errorRed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تسليم القبض مقفل حتى اكتمال 100% من تحصيل أقساط الشهر.\nتم تحصيل ${widget.collectedAmount.toStringAsFixed(0)} من إجمالي ${widget.targetAmount.toStringAsFixed(0)} ج.م.',
                          style: const TextStyle(color: AppTheme.errorRed, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryLight),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.primaryGreen),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'جميع أقساط شهر 3 مكتملة ومحصلة بنسبة 100% (50,000 ج.م). يمكنك تسليم القبض بأمان.',
                          style: TextStyle(color: AppTheme.primaryGreen, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // 48-Hour Auto-Confirmation explanation
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
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: AppTheme.accentGold),
                        SizedBox(width: 8),
                        Text(
                          'نافذة التأكيد التلقائي (48 ساعة)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'عند تسجيل التسليم وإرفاق إشعار التحويل، يُمنح العضو 48 ساعة لتأكيد الاستلام يدوياً. إذا لم يعترض خلال 48 ساعة، يقوم النظام بتأكيد العملية وإغلاق الدورة تلقائياً.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_isDelivered)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryGreen),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.verified, color: AppTheme.primaryGreen, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'تم تسجيل تسليم القبض بنجاح!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'العد التنازلي للتأكيد التلقائي: 47 ساعة و 58 دقيقة',
                        style: TextStyle(fontSize: 13, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: canDisburse
                      ? () {
                          setState(() {
                            _isDelivered = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تسجيل تسليم القبض وبدء نافذة الـ 48 ساعة للتأكيد التلقائي!'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.handshake_outlined, color: Colors.white),
                  label: const Text('تسجيل تسليم القبض وإرفاق الإشعار'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: canDisburse ? AppTheme.primaryGreen : Colors.grey[400],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
