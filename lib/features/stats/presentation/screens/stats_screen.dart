import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evolução Cognitiva'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monitoramento de uso
              Text(
                'Monitoramento de Uso',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: 0.65,
                            strokeWidth: 10,
                            color: AppColors.cyan,
                            backgroundColor: AppColors.cyan.withOpacity(0.1),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '6h 24m',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontFamily: 'Space Grotesk',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Tempo Focado',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fade(duration: 600.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
              const SizedBox(height: 40),

              // Histórico de Sessões
              Text(
                'Histórico de Sessões',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSessionItem(context, 'Memória (Cartões)', 'Hoje, 14:30', '+45 pts', AppColors.secondary, LucideIcons.brain)
                  .animate().fade(delay: 200.ms).slideX(begin: 0.1),
              const SizedBox(height: 12),
              _buildSessionItem(context, 'Atenção Concentrada', 'Ontem, 09:15', '+30 pts', AppColors.cyan, LucideIcons.target)
                  .animate().fade(delay: 300.ms).slideX(begin: 0.1),
              const SizedBox(height: 12),
              _buildSessionItem(context, 'Sequência Lógica', 'Ontem, 08:45', '+15 pts', AppColors.primary, LucideIcons.grid)
                  .animate().fade(delay: 400.ms).slideX(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionItem(BuildContext context, String title, String date, String points, Color color, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
