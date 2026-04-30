import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/widgets/animated_score_badge.dart';

class SequenceGameScreen extends StatefulWidget {
  const SequenceGameScreen({super.key});

  @override
  State<SequenceGameScreen> createState() => _SequenceGameScreenState();
}

class _SequenceGameScreenState extends State<SequenceGameScreen> {
  final List<IconData> _shapes = [
    Icons.change_history, // Triângulo
    Icons.circle,
    Icons.square,
    Icons.star,
    Icons.favorite, // Substituindo pentágono
    Icons.diamond, // Substituindo hexágono
  ];

  List<int> _sequence = [];
  List<int> _userSequence = [];
  bool _isPlaying = false;
  bool _showingSequence = false;
  int? _activeShapeIndex;
  int _score = 0;
  String _message = 'Toque em Iniciar';

  void _startGame() {
    setState(() {
      _score = 0;
      _sequence.clear();
      _userSequence.clear();
      _isPlaying = true;
      _message = 'Observe a sequência';
    });
    _nextRound();
  }

  void _nextRound() {
    _userSequence.clear();
    _sequence.add((DateTime.now().millisecondsSinceEpoch % _shapes.length).toInt());
    _playSequence();
  }

  Future<void> _playSequence() async {
    setState(() {
      _showingSequence = true;
      _message = 'Observe a sequência';
    });

    for (int i = 0; i < _sequence.length; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _activeShapeIndex = _sequence[i];
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _activeShapeIndex = null;
      });
    }

    setState(() {
      _showingSequence = false;
      _message = 'Sua vez!';
    });
  }

  void _onShapeTap(int index) {
    if (!_isPlaying || _showingSequence) return;

    setState(() {
      _userSequence.add(index);
    });

    // Check if correct so far
    for (int i = 0; i < _userSequence.length; i++) {
      if (_userSequence[i] != _sequence[i]) {
        _gameOver();
        return;
      }
    }

    // Check if completed round
    if (_userSequence.length == _sequence.length) {
      setState(() {
        _score += 10;
        _message = 'Combinação Perfeita!';
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _nextRound();
      });
    }
  }

  void _gameOver() {
    setState(() {
      _isPlaying = false;
      _message = 'Fim de Jogo! Pontos: $_score';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Combine a Sequência'),
        ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Toque nas formas na ordem em que apareceram',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _shapes.length,
                  itemBuilder: (context, index) {
                    final isActive = index == _activeShapeIndex;
                    return GestureDetector(
                      onTap: () => _onShapeTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.surfaceBright,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive ? AppColors.textHigh : AppColors.outline,
                            width: isActive ? 4 : 2,
                          ),
                          boxShadow: isActive 
                              ? [BoxShadow(color: AppColors.primary.withOpacity(0.8), blurRadius: 20)] 
                              : [],
                        ),
                        child: Icon(
                          _shapes[index],
                          size: isActive ? 48 : 40,
                          color: isActive ? AppColors.textHigh : AppColors.primary,
                        ),
                      ).animate(target: isActive ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 150.ms),
                    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.2);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _message,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _message.contains('Fim') ? Colors.red : AppColors.secondary,
                ),
              ),
              const SizedBox(height: 16),
              if (!_isPlaying)
                ElevatedButton(
                  onPressed: _startGame,
                  child: const Text('INICIAR'),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
