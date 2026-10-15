import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/firebase_auth_repository.dart';
import '../../gameya/providers/gameya_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController(text: '01000000000');
  final _nameController = TextEditingController(text: 'أيمن جمعة');
  UserRole _selectedRole = UserRole.organizer;
  bool _isLoading = false;

  Future<void> _submitLogin({String? phone, String? name, UserRole? role}) async {
    setState(() => _isLoading = true);
    final authRepo = ref.read(authRepositoryProvider);

    final finalPhone = phone ?? _phoneController.text.trim();
    final finalName = name ?? _nameController.text.trim();
    final finalRole = role ?? _selectedRole;

    try {
      final user = await authRepo.signIn(
        phone: finalPhone,
        displayName: finalName,
        role: finalRole,
      );
      ref.read(currentUserProvider.notifier).state = user;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تسجيل الدخول: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Branding
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, size: 48, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'منصة إدارة الجمعيات الذكية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'تسجيل الدخول وإدارة الصلاحيات (Role-Based Access)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),

                  const SizedBox(height: 32),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'تسجيل الدخول برقم الهاتف',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'الاسم بالكامل',
                            prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryGreen),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف (الواتساب)',
                            hintText: '01xxxxxxxxx',
                            prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryGreen),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text('نوع الحساب / الصلاحية:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('منظم الجمعية (Admin)')),
                                selected: _selectedRole == UserRole.organizer,
                                selectedColor: AppTheme.primaryLight.withOpacity(0.2),
                                onSelected: (_) => setState(() => _selectedRole = UserRole.organizer),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('مشترك (Member)')),
                                selected: _selectedRole == UserRole.member,
                                selectedColor: AppTheme.primaryLight.withOpacity(0.2),
                                onSelected: (_) => setState(() => _selectedRole = UserRole.member),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _submitLogin(),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('دخول إلى المنصة', style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Fast Testing Switchers
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('أو اختبار سريع بضغطة زر', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _submitLogin(
                              phone: '01000000000',
                              name: 'أيمن جمعة (المنظم)',
                              role: UserRole.organizer,
                            ),
                    icon: const Icon(Icons.admin_panel_settings, color: AppTheme.primaryGreen),
                    label: const Text('دخول كمنظم: إدارة الجمعية والأعضاء والتحصيل'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.primaryGreen),
                    ),
                  ),

                  const SizedBox(height: 10),

                  OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _submitLogin(
                              phone: '01022222222',
                              name: 'محمد عبد الله (مشترك)',
                              role: UserRole.member,
                            ),
                    icon: const Icon(Icons.person, color: Colors.blue),
                    label: const Text('دخول كمشترك: بوابتي الخاصة ودفع الأقساط'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
