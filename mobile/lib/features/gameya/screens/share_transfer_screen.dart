import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ShareTransferScreen extends StatefulWidget {
  const ShareTransferScreen({super.key});

  @override
  State<ShareTransferScreen> createState() => _ShareTransferScreenState();
}

class _ShareTransferScreenState extends State<ShareTransferScreen> {
  final _newMemberNameController = TextEditingController();
  final _newMemberPhoneController = TextEditingController();
  String _selectedDropoutMember = 'كريم حسن (شهر 4 - نصف سهم)';
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نقل السهم واستبدال متعثر'),
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
              // Audit integrity assurance card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryLight.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.history_edu, color: AppTheme.primaryGreen, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الحفاظ على السجل التاريخي (Audit Preservation)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryGreen),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'الأقساط المسددة سابقاً تظل مقيدة باسم العضو القديم للأمانة المالية، بينما يستلم العضو البديل الالتزامات والقبض بدءاً من الشهر الجاري.',
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
                'العضو المنسحب / المتعثر:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedDropoutMember,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_remove, color: AppTheme.errorRed),
                ),
                items: [
                  'كريم حسن (شهر 4 - نصف سهم)',
                  'سارة إبراهيم (شهر 8 - سهم كامل)',
                ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDropoutMember = val);
                },
              ),

              const SizedBox(height: 16),

              const Text(
                'بيانات العضو البديل الجديد:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _newMemberNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العضو الجديد بالكامل',
                  prefixIcon: Icon(Icons.person_add, color: AppTheme.primaryGreen),
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _newMemberPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم هاتف الواتساب (01xxxxxxxxx)',
                  prefixIcon: Icon(Icons.phone, color: AppTheme.primaryGreen),
                ),
              ),

              const SizedBox(height: 24),

              if (_isSuccess)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryGreen),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'تم نقل السهم للعضو البديل بنجاح!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'تم إرسال دعوة الانضمام ورابط الجمعية عبر واتساب، وحفظ السجلات السابقة في الأرشيف.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    if (_newMemberNameController.text.trim().isEmpty || _newMemberPhoneController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('برجاء إدخال اسم ورقم هاتف العضو البديل')),
                      );
                      return;
                    }
                    setState(() => _isSuccess = true);
                  },
                  icon: const Icon(Icons.transfer_within_a_station, color: Colors.white),
                  label: const Text('تأكيد نقل السهم وحفظ الأرشيف'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
