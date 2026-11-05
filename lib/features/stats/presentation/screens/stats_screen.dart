import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/backend/models/backend_models.dart';
import '../../../../core/services/neuroly_api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  final NeurolyApiClient _api = NeurolyApiClient();
  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();
    _api.fetchStats();
    _chartController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _chartController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  Color _colorForModule(String moduleId) {
    switch (moduleId) {
      case 'memory':
        return AppColors.secondary;
      case 'attention':
        return AppColors.cyan;
      case 'sequence':
        return AppColors.primary;
      case 'word_puzzle':
        return Colors.orangeAccent;
      case 'stroop':
        return Colors.redAccent;
      case 'math':
        return Colors.blueAccent;
      case 'nback':
        return Colors.purpleAccent;
      case 'crossword':
        return Colors.tealAccent;
      case 'zen_mode':
        return AppColors.cyan;
      default:
        return AppColors.secondary;
    }
  }

  IconData _iconForModule(String moduleId) {
    switch (moduleId) {
      case 'memory':
        return LucideIcons.brain;
      case 'attention':
        return LucideIcons.target;
      case 'sequence':
        return LucideIcons.grid;
      case 'word_puzzle':
        return LucideIcons.type;
      case 'stroop':
        return LucideIcons.palette;
      case 'math':
        return LucideIcons.calculator;
      case 'nback':
        return LucideIcons.layers;
      case 'crossword':
        return LucideIcons.grid;
      case 'zen_mode':
        return LucideIcons.wind;
      default:
        return LucideIcons.brain;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _api,
      builder: (context, _) {
        final stats = _api.cachedStats;
        final score = stats?.neurolyScore ?? 985;
        final weeklyGain = stats?.weeklyGain ?? 125;
        final chartPoints = stats?.chartPoints ?? const [0.8, 0.6, 0.7, 0.3, 0.4, 0.1];
        final focusedTime = stats?.formattedFocusedTime ?? '6h 24m';
        final focusedProgress = stats?.focusedTimeProgress ?? 0.65;
        final sessions = stats?.recentSessions ??
            const [
              SessionRecordDto(
                id: 's1',
                moduleId: 'memory',
                title: 'Memória (Cartões)',
                dateLabel: 'Hoje, 14:30',
                pointsLabel: '+45 pts',
                points: 45,
                durationSeconds: 120,
                timestampIso: '',
              ),
              SessionRecordDto(
                id: 's2',
                moduleId: 'attention',
                title: 'Atenção Concentrada',
                dateLabel: 'Ontem, 09:15',
                pointsLabel: '+30 pts',
                points: 30,
                durationSeconds: 90,
                timestampIso: '',
              ),
              SessionRecordDto(
                id: 's3',
                moduleId: 'sequence',
                title: 'Sequência Lógica',
                dateLabel: 'Ontem, 08:45',
                pointsLabel: '+15 pts',
                points: 15,
                durationSeconds: 60,
                timestampIso: '',
              ),
            ];

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
                  // Neuroly Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Neuroly Score',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Icon(LucideIcons.trendingUp, color: AppColors.secondary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$score',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Text(
                                '+$weeklyGain pts na semana',
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: AnimatedBuilder(
                            animation: _chartController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _ChartPainter(
                                  _chartController.value,
                                  chartPoints,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 600.ms).slideY(begin: 0.1),
                  const SizedBox(height: 40),

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
                                value: focusedProgress,
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
                                  focusedTime,
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
                  ).animate().fade(duration: 600.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 40),

                  // Histórico de Sessões
                  Text(
                    'Histórico de Sessões',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (sessions.isEmpty)
                    const GlassContainer(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Nenhuma sessão registrada ainda. Jogue um módulo para começar!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMedium),
                        ),
                      ),
                    )
                  else
                    for (int i = 0; i < sessions.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      _buildSessionItem(
                        context,
                        sessions[i].title,
                        sessions[i].dateLabel,
                        sessions[i].pointsLabel,
                        _colorForModule(sessions[i].moduleId),
                        _iconForModule(sessions[i].moduleId),
                      ).animate().fade(delay: (100 * (i + 1)).ms).slideX(begin: 0.1),
                    ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionItem(
    BuildContext context,
    String title,
    String date,
    String points,
    Color color,
    IconData icon,
  ) {
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMedium,
                      ),
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

class _ChartPainter extends CustomPainter {
  final double progress;
  final List<double> yRatios;

  _ChartPainter(this.progress, this.yRatios);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.secondary.withOpacity(0.4),
          AppColors.secondary.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final effectiveRatios = yRatios.length >= 2
        ? yRatios
        : const <double>[0.8, 0.6, 0.7, 0.3, 0.4, 0.1];

    final points = List.generate(effectiveRatios.length, (i) {
      final x = size.width * (i / (effectiveRatios.length - 1));
      final y = size.height * effectiveRatios[i].clamp(0.05, 0.95);
      return Offset(x, y);
    });

    if (progress == 0) return;

    final totalPoints = points.length;
    final currentPointIndex = (progress * (totalPoints - 1)).floor();
    final pointProgress = (progress * (totalPoints - 1)) - currentPointIndex;

    path.moveTo(points[0].dx, size.height);
    path.lineTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < currentPointIndex; i++) {
      path.lineTo(points[i + 1].dx, points[i + 1].dy);
      fillPath.lineTo(points[i + 1].dx, points[i + 1].dy);
    }

    if (currentPointIndex < totalPoints - 1) {
      final p1 = points[currentPointIndex];
      final p2 = points[currentPointIndex + 1];
      final currentX = p1.dx + (p2.dx - p1.dx) * pointProgress;
      final currentY = p1.dy + (p2.dy - p1.dy) * pointProgress;

      path.lineTo(currentX, currentY);
      fillPath.lineTo(currentX, currentY);
      fillPath.lineTo(currentX, size.height);
    } else {
      fillPath.lineTo(points.last.dx, size.height);
    }

    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw point dots
    final dotPaint = Paint()..color = Colors.white;
    for (int i = 0; i <= currentPointIndex; i++) {
      canvas.drawCircle(points[i], 6, paint);
      canvas.drawCircle(points[i], 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.yRatios != yRatios;
}
