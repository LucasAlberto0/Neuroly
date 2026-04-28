import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class ZenModeScreen extends StatefulWidget {
  const ZenModeScreen({super.key});

  @override
  State<ZenModeScreen> createState() => _ZenModeScreenState();
}

class _ZenModeScreenState extends State<ZenModeScreen> {
  String _instruction = "Prepare-se...";
  double _scale = 1.0;
  Timer? _timer;
  int _phase = -1; // -1: intro, 0: inhale, 1: hold in, 2: exhale, 3: hold out
  
  // Box breathing config (4-4-4-4)
  final Duration _inhaleDuration = const Duration(seconds: 4);
  final Duration _holdDuration = const Duration(seconds: 4);
  final Duration _exhaleDuration = const Duration(seconds: 4);

  int _cyclesCompleted = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Start automatically after a short delay
    Future.delayed(const Duration(seconds: 2), _startBreathing);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    if (!mounted) return;
    setState(() {
      _isPlaying = true;
      _phase = 0;
    });
    _nextPhase();
  }

  void _nextPhase() {
    if (!mounted) return;
    setState(() {
      if (_phase == 0) {
        _instruction = "Inspire...";
        _scale = 2.2;
        _timer = Timer(_inhaleDuration, () { _phase = 1; _nextPhase(); });
      } else if (_phase == 1) {
        _instruction = "Segure...";
        _timer = Timer(_holdDuration, () { _phase = 2; _nextPhase(); });
      } else if (_phase == 2) {
        _instruction = "Expire...";
        _scale = 1.0;
        _timer = Timer(_exhaleDuration, () { _phase = 3; _nextPhase(); });
      } else if (_phase == 3) {
        _instruction = "Segure...";
        _cyclesCompleted++;
        _timer = Timer(_holdDuration, () { _phase = 0; _nextPhase(); });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the duration of the current animation phase
    Duration currentDuration = _inhaleDuration;
    if (_phase == 2) currentDuration = _exhaleDuration;
    if (_phase == 1 || _phase == 3) currentDuration = _holdDuration;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Modo Zen', style: TextStyle(color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.surface, // Escuro até mais claro na base
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Contador de ciclos
                if (_isPlaying)
                  Text(
                    'Ciclos completados: $_cyclesCompleted',
                    style: const TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fade(duration: 1.seconds),
                
                const Spacer(),
                
                // Círculos Respiratórios (Glassmorphism Effect)
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Aura externa
                      AnimatedContainer(
                        duration: currentDuration,
                        curve: Curves.easeInOutSine,
                        width: 120 * _scale,
                        height: 120 * _scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.05),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 2.seconds),
                      
                      // Círculo intermediário
                      AnimatedContainer(
                        duration: currentDuration,
                        curve: Curves.easeInOutSine,
                        width: 90 * _scale,
                        height: 90 * _scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondary.withOpacity(0.15),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scale(begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02), duration: 3.seconds),
                      
                      // Círculo interno brilhante
                      AnimatedContainer(
                        duration: currentDuration,
                        curve: Curves.easeInOutSine,
                        width: 60 * _scale,
                        height: 60 * _scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              AppColors.cyan,
                              AppColors.primary,
                            ]
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withOpacity(0.4),
                              blurRadius: 30 * _scale,
                              spreadRadius: 5 * _scale,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.wind, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Texto de Instrução (Fade dinâmico)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    _instruction,
                    key: ValueKey<String>(_instruction),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Footer
                const Padding(
                  padding: EdgeInsets.only(bottom: 32.0, left: 32, right: 32),
                  child: Text(
                    "Concentre-se no movimento do círculo.\nIsto ajudará a baixar sua frequência cardíaca.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ).animate().fade(delay: 1.seconds),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
