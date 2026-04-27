import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({super.key});

  @override
  State<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  final Random _rand = Random();
  String _equation = "";
  bool _isActuallyTrue = false;
  int _score = 0;
  bool _isWrong = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    int a = _rand.nextInt(12) + 2; // 2 to 13
    int b = _rand.nextInt(12) + 2;
    int result = a * b;

    _isActuallyTrue = _rand.nextBool();
    
    if (!_isActuallyTrue) {
      // Offset the result by a small amount
      int offset = _rand.nextBool() ? (_rand.nextInt(3) + 1) : -(_rand.nextInt(3) + 1);
      result += offset;
    }

    _equation = "$a x $b = $result";
    _isWrong = false;
  }

  void _checkAnswer(bool userSaidTrue) {
    if (userSaidTrue == _isActuallyTrue) {
      setState(() {
        _score += 40;
        _nextRound();
      });
    } else {
      setState(() {
        _isWrong = true;
        _score = (_score - 20).clamp(0, 9999);
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _isWrong = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cálculo Rápido'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Score: $_score',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.cyan, fontSize: 16),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Verdadeiro ou Falso?',
                style: TextStyle(color: AppColors.textMedium, fontSize: 18),
              ),
            ),
            const SizedBox(height: 64),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isWrong ? Colors.red : AppColors.outline, width: 2),
                boxShadow: [
                  if (_isWrong) BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20)
                ]
              ),
              child: Text(
                _equation,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHigh,
                  letterSpacing: 4,
                ),
              ).animate(key: ValueKey(_equation)).scale(duration: 200.ms),
            ).animate(target: _isWrong ? 1 : 0).shake(),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnswerButton('Falso', Colors.redAccent, false),
                _buildAnswerButton('Verdadeiro', AppColors.secondary, true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String label, Color color, bool value) {
    return InkWell(
      onTap: () => _checkAnswer(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    ).animate().fade().slideY(begin: 0.2, end: 0);
  }
}
