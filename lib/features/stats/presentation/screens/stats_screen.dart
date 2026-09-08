import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/linkedin_certificate_modal.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _chartController;
  bool _certificateShown = false;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _chartController.forward();
    _chartController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_certificateShown) {
        _certificateShown = true;
        _showCertificate();
      }
    });
  }

  void _showCertificate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const LinkedinCertificateModal(),
    );
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

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
              // Neuroly Score (NEW)
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
                          '985',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            '+125 pts na semana',
                            style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
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
                            painter: _ChartPainter(_chartController.value),
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

class _ChartPainter extends CustomPainter {
  final double progress;

  _ChartPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.secondary.withOpacity(0.4), AppColors.secondary.withOpacity(0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Data points (simulating an upward trend)
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width, size.height * 0.1),
    ];

    if (progress == 0) return;

    // Draw up to the current progress
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
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => oldDelegate.progress != progress;
}
