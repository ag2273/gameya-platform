import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'data/services/firebase_auth_repository.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/gameya/screens/gameya_dashboard_screen.dart';
import 'features/gameya/screens/member_portal_screen.dart';
import 'features/gameya/providers/gameya_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom user-friendly error fallback widget to prevent red screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, size: 56, color: Color(0xFF0F766E)),
              const SizedBox(height: 16),
              const Text(
                'منصة إدارة الجمعيات الذكية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'يرجى التحقق من قواعد أمان Firebase Firestore (Rules) في الكونسول.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  runApp(
    const ProviderScope(
      child: SmartGameyaApp(),
    ),
  );
}

class SmartGameyaApp extends ConsumerWidget {
  const SmartGameyaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return MaterialApp(
      title: 'منصة إدارة الجمعيات الذكية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // Native Arabic RTL First Configuration
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Real Role-Based Access Control Gate
      home: user == null
          ? const AuthScreen()
          : user.role == UserRole.organizer
              ? const GameyaDashboardScreen()
              : const MemberPortalScreen(),
    );
  }
}
