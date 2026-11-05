import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/backend/models/backend_models.dart';
import '../../../../core/services/neuroly_api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/brain_progress_indicator.dart';
import '../../../../core/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NeurolyApiClient _api = NeurolyApiClient();

  @override
  void initState() {
    super.initState();
    _api.fetchDashboard();
  }

  Future<void> _openGame(String route) async {
    await Navigator.pushNamed(context, route);
    if (mounted) {
      await _api.fetchDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _api,
      builder: (context, _) {
        final dashboard = _api.cachedDashboard;
        final cognitiveLevel = dashboard?.cognitiveLevel ?? 0.72;
        final formattedTime = dashboard?.formattedTimeToday ?? '3h 45m';
        final timeProgress = dashboard?.timeProgressToday ?? 0.4;
        final missions = dashboard?.missions ??
            const [
              MissionDto(
                id: 'play_3_games',
                title: 'Jogar 3 minigames',
                subtitle: '0/3 concluídos',
                isCompleted: false,
              ),
              MissionDto(
                id: 'evolve_5_percent',
                title: 'Evoluir seu cérebro em 5%',
                subtitle: 'Progresso atual: 2%',
                isCompleted: false,
              ),
            ];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Image.asset(
              'assets/images/simbolo_branco.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: AppColors.textMedium),
                onPressed: () {
                  NotificationService().scheduleVideoNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Notificação agendada para 30s! Feche o app e simule a rede social.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Seu nível cognitivo hoje',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fade(duration: 500.ms).slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 48),

                  // Giant Circular Progress for Cognitive Level
                  BrainProgressIndicator(percentage: cognitiveLevel),
                  const SizedBox(height: 48),

                  // Missões do dia
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Missões do dia',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  GlassContainer(
                    child: Column(
                      children: [
                        for (int i = 0; i < missions.length; i++) ...[
                          if (i > 0) const Divider(color: AppColors.outline),
                          _buildMissionItem(
                            context,
                            missions[i].title,
                            missions[i].subtitle,
                            missions[i].isCompleted,
                          ),
                        ],
                      ],
                    ),
                  ).animate().fade(delay: 400.ms).slideX(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  // Tempo
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formattedTime,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontFamily: 'Space Grotesk',
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'hoje',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMedium,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: timeProgress,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    color: AppColors.primary,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ).animate().scaleX(
                        begin: 0,
                        end: 1,
                        duration: 800.ms,
                        curve: Curves.easeOutQuad,
                        alignment: Alignment.centerLeft,
                      ),

                  const SizedBox(height: 48),

                  // Módulos
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Módulos de Treino',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _openGame('/game_sequence'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Column(
                            children: [
                              Icon(LucideIcons.grid),
                              SizedBox(height: 4),
                              Text('Sequência', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _openGame('/game_attention'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Column(
                            children: [
                              Icon(LucideIcons.target),
                              SizedBox(height: 4),
                              Text('Atenção', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _openGame('/game_memory'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Column(
                            children: [
                              Icon(LucideIcons.brain),
                              SizedBox(height: 4),
                              Text('Memória', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 600.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMissionItem(
    BuildContext context,
    String title,
    String subtitle,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? AppColors.secondary : AppColors.textMedium,
                width: 2,
              ),
              color: isCompleted ? AppColors.secondary : Colors.transparent,
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
