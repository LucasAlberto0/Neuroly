import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/animated_score_badge.dart';

class WordPuzzleGameScreen extends StatefulWidget {
  const WordPuzzleGameScreen({super.key});

  @override
  State<WordPuzzleGameScreen> createState() => _WordPuzzleGameScreenState();
}

class _WordPuzzleGameScreenState extends State<WordPuzzleGameScreen> {
  final List<Map<String, String>> _levels = [
    {'word': 'NEURONIO', 'hint': 'Célula do sistema nervoso'},
    {'word': 'CEREBRO', 'hint': 'Órgão principal do sistema nervoso'},
    {'word': 'MEMORIA', 'hint': 'Capacidade de reter informações'},
    {'word': 'FOCO', 'hint': 'Concentração absoluta em algo'},
    {'word': 'SINAPSE', 'hint': 'Comunicação entre neurônios'},
    {'word': 'LOGICA', 'hint': 'Raciocínio coerente'},
  ];
  int _currentLevelIndex = 0;
  
  String get _targetWord => _levels[_currentLevelIndex]['word']!;
  String get _hint => _levels[_currentLevelIndex]['hint']!;
  List<String> _scrambledLetters = [];
  List<String> _selectedLetters = [];
  int _score = 0;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  void _startRound() {
    _scrambledLetters = _targetWord.split('')..shuffle();
    _selectedLetters = [];
    _isSuccess = false;
  }

  void _onLetterTap(String letter, int index) {
    if (_isSuccess) return;
    setState(() {
      _selectedLetters.add(letter);
      _scrambledLetters[index] = ''; // Hide the used letter
    });

    if (_selectedLetters.length == _targetWord.length) {
      if (_selectedLetters.join() == _targetWord) {
        setState(() {
          _score += 100;
          _isSuccess = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _currentLevelIndex = (_currentLevelIndex + 1) % _levels.length;
              _startRound(); 
            });
          }
        });
      } else {
        // Wrong, reset
        setState(() {
          _startRound();
          _score = (_score - 20).clamp(0, 9999);
        });
      }
    }
  }

  void _onRemoveLetterTap(String letter, int index) {
    if (_isSuccess) return;
    setState(() {
      _selectedLetters.removeAt(index);
      // Find the first empty spot in scrambled to put it back
      int emptyIndex = _scrambledLetters.indexOf('');
      if (emptyIndex != -1) {
        _scrambledLetters[emptyIndex] = letter;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cruza-Letras'),
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
          children: [
            const SizedBox(height: 24),
            Text(
              'Dica: $_hint',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ).animate().fade().slideY(),
            const SizedBox(height: 48),
            // The empty boxes or selected letters
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(_targetWord.length, (index) {
                final hasLetter = index < _selectedLetters.length;
                final letter = hasLetter ? _selectedLetters[index] : '';
                return GestureDetector(
                  onTap: hasLetter ? () => _onRemoveLetterTap(letter, index) : null,
                  child: Container(
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      color: hasLetter ? (_isSuccess ? AppColors.secondary : AppColors.primary) : AppColors.surfaceBright,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _isSuccess ? AppColors.secondary : AppColors.outline),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ).animate(target: _isSuccess ? 1 : 0).scale(duration: 300.ms);
              }),
            ),
            const Spacer(),
            // The scrambled letters
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: List.generate(_scrambledLetters.length, (index) {
                  final letter = _scrambledLetters[index];
                  if (letter.isEmpty) return const SizedBox(width: 48, height: 48); // placeholder
                  return GestureDetector(
                    onTap: () => _onLetterTap(letter, index),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outline),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textHigh),
                      ),
                    ),
                  ).animate().scale(delay: (index * 50).ms);
                }),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
