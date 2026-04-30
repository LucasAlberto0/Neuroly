import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BrainProgressIndicator extends StatelessWidget {
  final double percentage; // 0.0 to 1.0

  const BrainProgressIndicator({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: percentage),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Ícone do Cérebro (Fundo e Preenchimento)
            ShaderMask(
              shaderCallback: (Rect bounds) {
                final safeValue = value.clamp(0.0, 1.0);
                return LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.secondary,
                    AppColors.secondary,
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  stops: [0.0, safeValue, safeValue, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: const Icon(
                LucideIcons.brain,
                size: 200,
                color: Colors.white,
              ),
            ),
            
            // Efeito Glow (Sombra atrás)
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.2 * value),
                    blurRadius: 40,
                    spreadRadius: 10,
                  )
                ],
              ),
            ),
            
            // Textos Centrais
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (value * 100).toInt().toString(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 64,
                    color: Colors.white,
                    fontFamily: 'Space Grotesk',
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Nível',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textHigh,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fade(delay: 500.ms, duration: 800.ms),
          ],
        );
      },
    );
  }
}
