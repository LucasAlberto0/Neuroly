import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_app/core/backend/models/backend_models.dart';
import 'package:flutter_test_app/core/backend/server/embedded_http_server.dart';
import 'package:flutter_test_app/core/backend/storage/local_database.dart';
import 'package:flutter_test_app/core/services/neuroly_api_client.dart';
import 'package:flutter_test_app/features/game/presentation/screens/stroop_game_screen.dart';
import 'package:flutter_test_app/features/game/presentation/screens/zen_mode_screen.dart';
import 'package:flutter_test_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_test_app/features/modules/presentation/screens/modules_screen.dart';
import 'package:flutter_test_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_test_app/features/stats/presentation/screens/stats_screen.dart';
import 'package:flutter_test_app/main.dart';

void main() {
  setUp(() async {
    await EmbeddedHttpServer().stop();
    await LocalDatabase().resetForTesting();
    await EmbeddedHttpServer().start();
    await NeurolyApiClient().login(
      email: 'lucas@neuroly.com',
      password: '123456',
    );
  });

  tearDown(() async {
    await EmbeddedHttpServer().stop();
  });

  group('Back-end Embarcado & API REST (NeurolyApiClient)', () {
    test('Autenticação: login demo, rejeição de senha inválida e novo cadastro', () async {
      final api = NeurolyApiClient();

      final auth = await api.login(
        email: 'lucas@neuroly.com',
        password: '123456',
      );
      expect(auth.user.email, 'lucas@neuroly.com');
      expect(auth.user.neuroCredits, 450);

      await expectLater(
        () => api.login(email: 'lucas@neuroly.com', password: 'wrong_password'),
        throwsA(isA<BackendException>()),
      );

      final reg = await api.register(
        name: 'Maria Clara',
        email: 'maria@neuroly.com',
        password: 'password123',
      );
      expect(reg.user.name, 'Maria Clara');
      expect(reg.user.email, 'maria@neuroly.com');
      expect(reg.user.neuroCredits, 100);
      expect(api.currentUser?.id, reg.user.id);
    });

    test('Telemetria cognitiva, progressão de missões diárias e estatísticas', () async {
      final api = NeurolyApiClient();
      final beforeDashboard = await api.fetchDashboard();
      final beforeStats = await api.fetchStats();

      // Submete 3 sessões de minigames para concluir a missão diária de 3 jogos
      await api.submitGameSession(
        moduleId: 'stroop',
        score: 200,
        durationSeconds: 45,
      );
      await api.submitGameSession(
        moduleId: 'math',
        score: 180,
        durationSeconds: 40,
      );
      await api.submitGameSession(
        moduleId: 'nback',
        score: 150,
        durationSeconds: 50,
      );

      final afterDashboard = await api.fetchDashboard();
      final afterStats = await api.fetchStats();

      expect(afterDashboard.cognitiveLevel, greaterThan(beforeDashboard.cognitiveLevel));
      expect(
        afterDashboard.missions.firstWhere((m) => m.id == 'play_3_games').isCompleted,
        isTrue,
      );
      expect(afterStats.neurolyScore, greaterThan(beforeStats.neurolyScore));
      expect(afterStats.recentSessions.first.moduleId, 'nback');
    });

    test('Desbloqueio de módulo via vídeo recompensado e atualização de perfil', () async {
      final api = NeurolyApiClient();

      final modulesBefore = await api.fetchModules();
      final wordPuzzleBefore =
          modulesBefore.firstWhere((m) => m.id == 'word_puzzle');
      expect(wordPuzzleBefore.isLocked, isTrue);

      final unlocked = await api.unlockModuleWithVideo('word_puzzle');
      expect(unlocked.isLocked, isFalse);

      final updatedUser = await api.updateProfile(
        name: 'Lucas Neuro',
        notificationsEnabled: false,
        dailyReminder: false,
      );
      expect(updatedUser.name, 'Lucas Neuro');
      expect(updatedUser.notificationsEnabled, isFalse);
      expect(updatedUser.dailyReminder, isFalse);
    });
  });

  group('Testes de Interface e Integração de Telas (Widgets)', () {
    testWidgets('NeurolyApp renderiza OnboardingScreen e navega para LoginScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const NeurolyApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('Transforme'), findsOneWidget);
      await tester.tap(find.text('Pular'));
      await tester.pumpAndSettle();

      expect(find.text('Acessar Sistema'), findsOneWidget);
    });

    testWidgets('LoginScreen autentica no back-end e navega para HomeScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const NeurolyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pular'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continuar com Google'));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Seu nível cognitivo hoje'), findsOneWidget);
      expect(find.text('Missões do dia'), findsOneWidget);
    });

    testWidgets('HomeScreen, StatsScreen, ModulesScreen e ProfileScreen exibem dados reais do back-end', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Missões do dia'), findsOneWidget);
      expect(find.text('Jogar 3 minigames'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: StatsScreen()));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Neuroly Score'), findsOneWidget);
      expect(find.text('Histórico de Sessões'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: ModulesScreen()));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Memória Operacional'), findsOneWidget);
      expect(find.text('Cruza-Letras'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Lucas Alberto'), findsWidgets);
      expect(find.text('lucas@neuroly.com'), findsWidgets);
    });

    testWidgets('StroopGameScreen e ZenModeScreen enviam telemetria ao finalizar sessão', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: StroopGameScreen()));
      await tester.pump(const Duration(milliseconds: 400));

      // Toca nas 3 opções para garantir ao menos 1 acerto (+50 pts)
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsNWidgets(3));
      for (int i = 0; i < 3; i++) {
        await tester.tap(buttons.at(i));
        await tester.pump(const Duration(milliseconds: 600));
      }

      // Desmonta StroopGameScreen para disparar _submitSessionIfNeeded no dispose
      await tester.pumpWidget(const MaterialApp(home: ZenModeScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      final statsAfterStroop = await NeurolyApiClient().fetchStats();
      expect(statsAfterStroop.recentSessions.first.moduleId, 'stroop');

      // Avança 15s no Modo Zen para completar ao menos 1 ciclo respiratório (2s intro + 4s + 4s + 4s)
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 5));

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump(const Duration(milliseconds: 500));

      final statsAfterZen = await NeurolyApiClient().fetchStats();
      expect(statsAfterZen.recentSessions.first.moduleId, 'zen_mode');
    });
  });
}
