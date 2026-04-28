import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/game/presentation/screens/sequence_game_screen.dart';
import 'core/widgets/main_layout_screen.dart';
import 'features/game/presentation/screens/attention_game_screen.dart';
import 'features/game/presentation/screens/memory_game_screen.dart';
import 'features/game/presentation/screens/word_puzzle_game_screen.dart';
import 'features/game/presentation/screens/stroop_game_screen.dart';
import 'features/game/presentation/screens/math_game_screen.dart';
import 'features/game/presentation/screens/nback_game_screen.dart';
import 'features/game/presentation/screens/crossword_game_screen.dart';
import 'features/game/presentation/screens/zen_mode_screen.dart';
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
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/':
            page = const OnboardingScreen();
            break;
          case '/login':
            page = const LoginScreen();
            break;
          case '/register':
            page = const RegisterScreen();
            break;
          case '/home':
            page = const MainLayoutScreen();
            break;
          case '/game_sequence':
            page = const SequenceGameScreen();
            break;
          case '/game_attention':
            page = const AttentionGameScreen();
            break;
          case '/game_memory':
            page = const MemoryGameScreen();
            break;
          case '/game_word_puzzle':
            page = const WordPuzzleGameScreen();
            break;
          case '/game_stroop':
            page = const StroopGameScreen();
            break;
          case '/game_math':
            page = const MathGameScreen();
            break;
          case '/game_nback':
            page = const NBackGameScreen();
            break;
          case '/game_crossword':
            page = const CrosswordGameScreen();
            break;
          case '/zen_mode':
            page = const ZenModeScreen();
            break;
          default:
            page = const OnboardingScreen();
        }

        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutQuart;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
      },
    );
  }
}
