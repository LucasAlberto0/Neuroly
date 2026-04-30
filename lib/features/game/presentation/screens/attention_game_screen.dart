import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/animated_score_badge.dart';

class AttentionGameScreen extends StatefulWidget {
  const AttentionGameScreen({super.key});

  @override
  State<AttentionGameScreen> createState() => _AttentionGameScreenState();
}

class _AttentionGameScreenState extends State<AttentionGameScreen> {
  final List<Color> _colors = [AppColors.primary, AppColors.secondary, AppColors.cyan, Colors.red];
  final Color _targetColor = AppColors.secondary;
  
  Color _currentColor = AppColors.surfaceBright;
  bool _isPlaying = false;
  int _score = 0;
  Timer? _gameTimer;
  Timer? _colorTimer;
  int _timeLeft = 30;
  bool _isWrongTap = false;

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isPlaying = true;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _endGame();
      }
    });

    _nextColor();
  }

  void _nextColor() {
    if (!_isPlaying) return;
    
    setState(() {
      _currentColor = _colors[Random().nextInt(_colors.length)];
    });

    _colorTimer?.cancel();
    _colorTimer = Timer(Duration(milliseconds: 800 + Random().nextInt(1000)), () {
      if (_isPlaying) _nextColor();
    });
  }

  void _onTap() {
    if (!_isPlaying) return;
    
    if (_currentColor == _targetColor) {
      setState(() {
        _score += 15;
        _currentColor = AppColors.surfaceBright; // hide
      });
      _colorTimer?.cancel();
      _nextColor();
    } else {
      setState(() {
        _score -= 5;
        _isWrongTap = true;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _isWrongTap = false);
      });
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _colorTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _currentColor = AppColors.surfaceBright;
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _colorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Atenção Concentrada'),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '$_timeLeft s',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _timeLeft <= 5 ? Colors.red : AppColors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Toque APENAS quando a cor for VERDE',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              AnimatedScoreBadge(score: _score),
              const Spacer(),
              Center(
                child: GestureDetector(
                  onTap: _onTap,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(48),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentColor,
                        boxShadow: [
                          if (_currentColor != AppColors.surfaceBright)
                            BoxShadow(
                              color: _currentColor.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            )
                        ],
                      ),
                    ).animate(target: _currentColor != AppColors.surfaceBright ? 1 : 0)
                     .scale(duration: 200.ms, curve: Curves.easeOutBack),
                  ),
                ).animate(target: _isWrongTap ? 1 : 0).shake(hz: 8, curve: Curves.easeInOutCubic, duration: 300.ms),
              ),
              const Spacer(),
              if (!_isPlaying)
                ElevatedButton(
                  onPressed: _startGame,
                  child: const Text('INICIAR'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
