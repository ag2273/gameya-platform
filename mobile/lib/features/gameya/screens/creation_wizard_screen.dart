import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../domain/models/gameya.dart';
import '../../../domain/models/member_share.dart';
import '../providers/gameya_providers.dart';

class MemberSlot {
  String name;
  String phone;
  double shareRatio; // 0.25, 0.5, 1.0
  int payoutMonth;

  MemberSlot({
    required this.name,
    required this.phone,
    required this.shareRatio,
    required this.payoutMonth,
  });
}

class CreationWizardScreen extends ConsumerStatefulWidget {
  const CreationWizardScreen({super.key});

  @override
  ConsumerState<CreationWizardScreen> createState() => _CreationWizardScreenState();
}

class _CreationWizardScreenState extends ConsumerState<CreationWizardScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'جمعية العمل والأصدقاء');
  final _totalPotController = TextEditingController(text: '50000');
  int _totalMonths = 10;
  bool _isSaving = false;

  late List<List<MemberSlot>> _monthSlots;

  @override
  void initState() {
    super.initState();
    _initializeSlots();
  }

  void _initializeSlots() {
    _monthSlots = List.generate(
      _totalMonths,
      (idx) => [
        MemberSlot(
          name: '',
          phone: '',
          shareRatio: 1.0,
          payoutMonth: idx + 1,
        )
      ],
    );
  }

  double get _totalPot => double.tryParse(_totalPotController.text) ?? 50000.0;
  double get _monthlyInstallment => _totalMonths > 0 ? _totalPot / _totalMonths : 0.0;

  bool get _isAllBalanced {
    for (int m = 0; m < _totalMonths; m++) {
      final sum = _monthSlots[m].fold(0.0, (acc, slot) => acc + slot.shareRatio);
      if ((sum - 1.0).abs() > 0.001) return false;
    }
    return true;
  }

  bool get _hasValidNamesAndPhones {
    for (int m = 0; m < _totalMonths; m++) {
      for (final slot in _monthSlots[m]) {
        if (slot.name.trim().isEmpty || slot.phone.trim().length < 9) {
          return false;
        }
      }
    }
    return true;
  }

  void _fillSampleRealMembers() {
    setState(() {
      final sampleNames = [
        'أحمد محمود', 'محمد عبد الله', 'كريم حسن', 'سارة إبراهيم', 'محمود عبد العزيز',
        'منى الشاذلي', 'ياسر جلال', 'هاني شاكر', 'عمرو دياب', 'تامر حسني'
      ];
      final samplePhones = [
        '01011111111', '01022222222', '01033333333', '01044444444', '01055555555',
        '01066666666', '01077777777', '01088888888', '01099999999', '01000000000'
      ];

      for (int m = 0; m < _totalMonths; m++) {
        _monthSlots[m] = [
          MemberSlot(
            name: sampleNames[m % sampleNames.length],
            phone: samplePhones[m % samplePhones.length],
            shareRatio: 1.0,
            payoutMonth: m + 1,
          )
        ];
      }
    });
  }

  Future<void> _saveAndActivateGameya() async {
    if (!_isAllBalanced || !_hasValidNamesAndPhones) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء استكمال بيانات جميع المشتركين وموازنة كل شهر بنسبة 100%')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider);
    final repo = ref.read(firestoreRepositoryProvider);

    final gameyaId = 'gam_${DateTime.now().millisecondsSinceEpoch}';
    final gameya = Gameya(
      id: gameyaId,
      name: _nameController.text.trim(),
      organizerId: user?.uid ?? 'organizer',
      totalPot: _totalPot,
      monthlyShareInstallment: _monthlyInstallment,
      totalMonths: _totalMonths,
      startDate: DateTime.now(),
      status: GameyaStatus.active,
      inviteCode: 'INV-${gameyaId.substring(gameyaId.length - 6)}',
      currency: 'ج.م',
      gracePeriodDays: 7,
      createdAt: DateTime.now(),
    );

    final List<MemberShare> members = [];
    int shareIdCounter = 1;

    for (int m = 0; m < _totalMonths; m++) {
      for (final slot in _monthSlots[m]) {
        members.add(
          MemberShare(
            id: 'share_${gameyaId}_$shareIdCounter',
            gameyaId: gameyaId,
            shareGroupId: m + 1,
            memberName: slot.name.trim(),
            phone: WhatsAppHelper.normalizePhone(slot.phone.trim()),
            shareRatio: slot.shareRatio,
            installmentAmount: _monthlyInstallment * slot.shareRatio,
            payoutMonth: m + 1,
          ),
        );
        shareIdCounter++;
      }
    }

    try {
      await repo.createRealGameya(gameya: gameya, members: members);
      ref.read(activeGameyaIdProvider.notifier).state = gameyaId;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الجمعية وتعيين جميع المشتركين بنجاح في قاعدة البيانات!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ الجمعية: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBalanced = _isAllBalanced;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء جمعية جديدة وتعيين المشتركين'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton.icon(
              onPressed: _fillSampleRealMembers,
              icon: const Icon(Icons.auto_fix_high, size: 16, color: AppTheme.primaryGreen),
              label: const Text('ملء تجريبي', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.people_alt_outlined, color: AppTheme.primaryGreen, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تعيين المشتركين وميزان الشهور',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'أدخل أسماء المشتركين وأرقام هواتفهم لكل شهر (سهم كامل أو أنصاف أسهم).',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Gameya Details
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
                          labelText: 'المدة بالأشهر',
                          prefixIcon: Icon(Icons.calendar_month, color: AppTheme.primaryGreen),
                        ),
                        items: [5, 10, 12].map((m) => DropdownMenuItem(value: m, child: Text('$m شهور'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _totalMonths = val;
                              _initializeSlots();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Month Members Assignment Section
                const Text(
                  'جدول تعيين المشتركين لكل شهر:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 8),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _totalMonths,
                  itemBuilder: (context, mIdx) {
                    final monthNum = mIdx + 1;
                    final slots = _monthSlots[mIdx];
                    final currentRatioSum = slots.fold(0.0, (acc, s) => acc + s.shareRatio);
                    final isMonthBalanced = (currentRatioSum - 1.0).abs() < 0.001;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: isMonthBalanced ? AppTheme.primaryLight : AppTheme.errorRed,
                          width: isMonthBalanced ? 1.5 : 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'شهر $monthNum (الاستحقاق: ${_totalPot.toStringAsFixed(0)} ج.م)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isMonthBalanced
                                        ? AppTheme.primaryGreen.withOpacity(0.1)
                                        : AppTheme.errorRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${(currentRatioSum * 100).toInt()}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isMonthBalanced ? AppTheme.primaryGreen : AppTheme.errorRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),

                            // Slots in this month
                            for (int sIdx = 0; sIdx < slots.length; sIdx++) ...[
                              _buildMemberSlotRow(mIdx, sIdx),
                              if (sIdx < slots.length - 1) const Divider(height: 12),
                            ],

                            // Split Share Button (allow adding partner if under 100%)
                            if (currentRatioSum < 1.0 && slots.length < 4)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    final remaining = 1.0 - currentRatioSum;
                                    slots.add(
                                      MemberSlot(
                                        name: '',
                                        phone: '',
                                        shareRatio: remaining > 0.5 ? 0.5 : remaining,
                                        payoutMonth: monthNum,
                                      ),
                                    );
                                  });
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('إضافة شريك في نفس الشهر (Split Share)'),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: isBalanced && !_isSaving ? _saveAndActivateGameya : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBalanced ? AppTheme.primaryGreen : Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('حفظ وتفعيل الجمعية وتوليد الأقساط', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberSlotRow(int mIdx, int sIdx) {
    final slot = _monthSlots[mIdx][sIdx];

    return Row(
      children: [
        // Member Name
        Expanded(
          flex: 4,
          child: TextFormField(
            initialValue: slot.name,
            decoration: InputDecoration(
              labelText: 'اسم المشترك',
              hintText: 'مثال: أحمد محمود',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              prefixIcon: const Icon(Icons.person, size: 18),
            ),
            onChanged: (val) => slot.name = val,
          ),
        ),
        const SizedBox(width: 8),

        // Phone
        Expanded(
          flex: 4,
          child: TextFormField(
            initialValue: slot.phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'رقم الواتساب',
              hintText: '01xxxxxxxxx',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              prefixIcon: const Icon(Icons.phone, size: 18),
            ),
            onChanged: (val) => slot.phone = val,
          ),
        ),
        const SizedBox(width: 8),

        // Share ratio selector
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<double>(
            value: slot.shareRatio,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 1.0, child: Text('100%')),
              DropdownMenuItem(value: 0.5, child: Text('50%')),
              DropdownMenuItem(value: 0.25, child: Text('25%')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => slot.shareRatio = val);
              }
            },
          ),
        ),

        // Delete button if multiple
        if (_monthSlots[mIdx].length > 1)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed, size: 20),
            onPressed: () {
              setState(() {
                _monthSlots[mIdx].removeAt(sIdx);
              });
            },
          ),
      ],
    );
  }
}
