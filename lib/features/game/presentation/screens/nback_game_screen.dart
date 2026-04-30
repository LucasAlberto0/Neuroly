import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/animated_score_badge.dart';

class NBackGameScreen extends StatefulWidget {
  const NBackGameScreen({super.key});

  @override
  State<NBackGameScreen> createState() => _NBackGameScreenState();
}

class _NBackGameScreenState extends State<NBackGameScreen> {
  final List<IconData> _shapes = [
    LucideIcons.circle,
    LucideIcons.square,
    LucideIcons.triangle,
    LucideIcons.hexagon,
    LucideIcons.star,
  ];
  
  final Random _rand = Random();
  final List<IconData> _history = [];
  IconData? _currentShape;
  int _score = 0;
  bool _isPlaying = false;
  bool _hasGuessedThisTurn = false;
  Timer? _timer;
  int _nBack = 2; // Default to 2-back

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _history.clear();
      _isPlaying = true;
    });
    _nextShape();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      _nextShape();
    });
  }

  void _nextShape() {
    setState(() {
      _hasGuessedThisTurn = false;
      // 30% chance to force a match if history is long enough
      if (_history.length >= _nBack && _rand.nextDouble() < 0.3) {
        _currentShape = _history[_history.length - _nBack];
      } else {
        _currentShape = _shapes[_rand.nextInt(_shapes.length)];
      }
      _history.add(_currentShape!);
    });
  }

  void _checkMatch() {
    if (!_isPlaying || _history.length <= _nBack || _hasGuessedThisTurn) return;
    
    _hasGuessedThisTurn = true;
    // Check if current matches the one N steps back
    bool isMatch = _currentShape == _history[_history.length - 1 - _nBack];
    
    setState(() {
      if (isMatch) {
        _score += 100;
      } else {
        _score = (_score - 50).clamp(0, 9999);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Memória de Trabalho'),
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
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'A forma atual é igual a ${_nBack} passos atrás?',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMedium, fontSize: 16),
              ),
            ),
            const SizedBox(height: 64),
            if (!_isPlaying)
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: _startGame,
                  child: const Text('Iniciar N-Back', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            else ...[
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                ),
                alignment: Alignment.center,
                child: _currentShape == null 
                  ? const CircularProgressIndicator()
                  : Icon(
                      _currentShape,
                      size: 80,
                      color: AppColors.primaryDim,
                    ).animate(key: ValueKey(_currentShape.toString() + _history.length.toString())).scale(duration: 300.ms, curve: Curves.easeOutBack),
              ),
              const SizedBox(height: 64),
              ElevatedButton.icon(
                icon: const Icon(LucideIcons.check, color: Colors.white),
                label: const Text('É IGUAL!', style: TextStyle(fontSize: 20, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                onPressed: _checkMatch,
              ).animate().slideY(begin: 0.5),
              const SizedBox(height: 16),
              const Text(
                'Toque apenas se for igual.',
                style: TextStyle(color: AppColors.textMedium),
              ).animate().fade(),
            ],
          ],
        ),
        ),
      ),
    );
  }
}
