import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

class AnimatedScoreBadge extends StatelessWidget {
  final int score;

  const AnimatedScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 500; // Aumentado o limiar de tela pequena

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 16,
        vertical: isCompact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cyan.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.zap,
            color: AppColors.cyan,
            size: isCompact ? 18 : 20,
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1000.ms)
           .shimmer(duration: 1500.ms),
          SizedBox(width: isCompact ? 4 : 8),
          Text(
            isCompact ? '$score' : 'Pontos: $score',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 14 : 16,
            ),
          ).animate(
            key: ValueKey(score),
          ).scale(
            begin: const Offset(1.3, 1.3),
            end: const Offset(1.0, 1.0),
            curve: Curves.easeOutBack,
            duration: 300.ms,
          ).tint(
            color: AppColors.cyan,
            duration: 200.ms,
          ),
        ],
      ),
    );
  }
}
