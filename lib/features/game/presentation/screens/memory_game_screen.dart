import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final List<IconData> _baseIcons = [
    LucideIcons.brain,
    LucideIcons.zap,
    LucideIcons.activity,
    LucideIcons.flame,
    LucideIcons.moon,
    LucideIcons.sun,
  ];

  late List<IconData> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  
  int _score = 0;
  bool _isPlaying = false;
  int? _firstSelectedIndex;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _cards = [..._baseIcons, ..._baseIcons];
    _cards.shuffle();
    _flipped = List.generate(_cards.length, (index) => false);
    _matched = List.generate(_cards.length, (index) => false);
    _score = 0;
    _firstSelectedIndex = null;
    _isPlaying = true;
    _isProcessing = false;
  }

  void _startGame() {
    setState(() {
      _initGame();
    });
  }

  void _onCardTap(int index) {
    if (!_isPlaying || _isProcessing || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;
    });

    if (_firstSelectedIndex == null) {
      _firstSelectedIndex = index;
    } else {
      _isProcessing = true;
      int firstIndex = _firstSelectedIndex!;
      
      if (_cards[firstIndex] == _cards[index]) {
        // Match!
        setState(() {
          _matched[firstIndex] = true;
          _matched[index] = true;
          _score += 20;
          _firstSelectedIndex = null;
          _isProcessing = false;
        });
        
        _checkWin();
      } else {
        // No match
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            _flipped[firstIndex] = false;
            _flipped[index] = false;
            _score -= 5;
            _firstSelectedIndex = null;
            _isProcessing = false;
          });
        });
      }
    }
  }

  void _checkWin() {
    if (_matched.every((element) => element)) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memória'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '$_score pts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
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
                'Encontre os pares de símbolos',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final isFlipped = _flipped[index] || _matched[index];
                    
                    return GestureDetector(
                      onTap: () => _onCardTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: _matched[index] 
                              ? AppColors.secondary.withOpacity(0.2)
                              : isFlipped ? AppColors.surfaceBright : AppColors.primaryDim,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _matched[index] ? AppColors.secondary : AppColors.outline,
                          ),
                        ),
                        child: Center(
                          child: isFlipped
                              ? Icon(_cards[index], color: _matched[index] ? AppColors.secondary : AppColors.primary, size: 32)
                              : const Icon(LucideIcons.brain, color: AppColors.textMedium, size: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!_isPlaying)
                Column(
                  children: [
                    Text('Você venceu!', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.secondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _startGame,
                      child: const Text('JOGAR NOVAMENTE'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
