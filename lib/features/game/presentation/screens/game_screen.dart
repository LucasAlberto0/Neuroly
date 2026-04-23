import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  double targetX = 0.5;
  double targetY = 0.5;
  final Random random = Random();
  bool isPlaying = false;

  void startGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      isPlaying = true;
    });
    moveTarget();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          endGame();
        }
      });
    });
  }

  void endGame() {
    timer?.cancel();
    setState(() {
      isPlaying = false;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Treino Concluído!', style: Theme.of(context).textTheme.titleLarge),
        content: Text('Sua pontuação foi: $score', style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to home
            },
            child: const Text('Voltar', style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              startGame();
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  void hitTarget() {
    if (!isPlaying) return;
    setState(() {
      score += 10;
    });
    moveTarget();
  }

  void moveTarget() {
    setState(() {
      targetX = random.nextDouble() * 0.8 + 0.1; // keep it somewhat away from edges
      targetY = random.nextDouble() * 0.8 + 0.1;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textHigh),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reação Rápida', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.timer, color: AppColors.cyan, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '00:${timeLeft.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Space Grotesk'),
                        ),
                      ],
                    ),
                  ),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.award, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '$score',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'Space Grotesk'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isPlaying
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Positioned(
                              left: constraints.maxWidth * targetX - 30, // 30 is half of target size
                              top: constraints.maxHeight * targetY - 30,
                              child: GestureDetector(
                                onTap: hitTarget,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(LucideIcons.target, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Center(
                      child: ElevatedButton(
                        onPressed: startGame,
                        child: const Text('COMEÇAR TREINO'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
