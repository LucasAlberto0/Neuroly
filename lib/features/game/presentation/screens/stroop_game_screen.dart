import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/services/neuroly_api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_score_badge.dart';

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
  late DateTime _sessionStartTime;
  bool _sessionSubmitted = false;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
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

  void _submitSessionIfNeeded() {
    if (_sessionSubmitted || _score <= 0) return;
    _sessionSubmitted = true;
    final elapsed = DateTime.now().difference(_sessionStartTime).inSeconds;
    NeurolyApiClient().submitGameSession(
      moduleId: 'stroop',
      score: max(0, _score),
      durationSeconds: max(5, elapsed),
    );
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
  void dispose() {
    _submitSessionIfNeeded();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _submitSessionIfNeeded();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Conflito de Cores'),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: AnimatedScoreBadge(score: _score),
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
                  border: Border.all(
                    color: _isWrong ? Colors.red : AppColors.outline,
                    width: 2,
                  ),
                ),
                child: Text(
                  _displayWord,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _displayColor,
                  ),
                )
                    .animate(key: ValueKey(_displayWord + _displayColor.toString()))
                    .scale(duration: 200.ms),
              ).animate(target: _isWrong ? 1 : 0).shake(),
              const SizedBox(height: 64),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
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
      ),
    );
  }
}
