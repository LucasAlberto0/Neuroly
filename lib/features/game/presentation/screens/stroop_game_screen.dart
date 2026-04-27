import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class StroopGameScreen extends StatefulWidget {
  const StroopGameScreen({super.key});

  @override
  State<StroopGameScreen> createState() => _StroopGameScreenState();
}

class _StroopGameScreenState extends State<StroopGameScreen> {
  final Map<String, Color> _colorData = {
    'VERMELHO': Colors.red,
    'AZUL': Colors.blue,
    'VERDE': Colors.green,
    'AMARELO': Colors.yellow,
    'ROXO': Colors.purple,
  };

  late String _displayWord;
  late Color _displayColor;
  late List<String> _options;
  int _score = 0;
  bool _isWrong = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    final rand = Random();
    final keys = _colorData.keys.toList();
    _displayWord = keys[rand.nextInt(keys.length)];
    // Sometimes word and color match, sometimes they don't
    _displayColor = _colorData[keys[rand.nextInt(keys.length)]]!;
    
    // Generate 3 random options including the correct one
    final correctColorName = _colorData.entries.firstWhere((e) => e.value == _displayColor).key;
    _options = [correctColorName];
    while (_options.length < 3) {
      final randomKey = keys[rand.nextInt(keys.length)];
      if (!_options.contains(randomKey)) {
        _options.add(randomKey);
      }
    }
    _options.shuffle();
    _isWrong = false;
  }

  void _checkAnswer(String selectedColorName) {
    final correctColorName = _colorData.entries.firstWhere((e) => e.value == _displayColor).key;
    if (selectedColorName == correctColorName) {
      setState(() {
        _score += 50;
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
        title: const Text('Conflito de Cores'),
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
                'Selecione a COR que a palavra está pintada, não o que está escrito!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMedium),
              ),
            ),
            const SizedBox(height: 64),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isWrong ? Colors.red : AppColors.outline, width: 2),
              ),
              child: Text(
                _displayWord,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _displayColor,
                ),
              ).animate(key: ValueKey(_displayWord + _displayColor.toString())).scale(duration: 200.ms),
            ).animate(target: _isWrong ? 1 : 0).shake(),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _options.map((option) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceBright,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  onPressed: () => _checkAnswer(option),
                  child: Text(option, style: const TextStyle(color: AppColors.textHigh)),
                ).animate().fade().slideY();
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
