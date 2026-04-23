import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/game/presentation/screens/sequence_game_screen.dart';
import 'core/widgets/main_layout_screen.dart';
import 'features/game/presentation/screens/attention_game_screen.dart';
import 'features/game/presentation/screens/memory_game_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  runApp(const NeurolyApp());
}

class NeurolyApp extends StatelessWidget {
  const NeurolyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neuroly Cognitive Evolution Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainLayoutScreen(),
        '/game_sequence': (context) => const SequenceGameScreen(),
        '/game_attention': (context) => const AttentionGameScreen(),
        '/game_memory': (context) => const MemoryGameScreen(),
      },
    );
  }
}
