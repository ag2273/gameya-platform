import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/gameya/screens/gameya_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // In production, await Firebase.initializeApp(); is invoked here
  runApp(
    const ProviderScope(
      child: SmartGameyaApp(),
    ),
  );
}

class SmartGameyaApp extends StatelessWidget {
  const SmartGameyaApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      
      home: const GameyaDashboardScreen(),
    );
  }
}
