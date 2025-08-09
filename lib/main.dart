import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/speech_translation_screen_new.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  runApp(const SpeechTranslationApp());
}

class SpeechTranslationApp extends StatelessWidget {
  const SpeechTranslationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoWave',
      theme: AppTheme.lightTheme,
      home: AuthService.isLoggedIn 
          ? const SpeechTranslationScreen() 
          : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
