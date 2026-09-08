import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  // Estado local para simular módulos desbloqueados
  final Set<String> _unlockedModules = {
    'attention',
    'memory',
    'sequence',
  };

  void _showUnlockDialog(String moduleId, String title) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Módulo Bloqueado', style: TextStyle(color: AppColors.textHigh)),
          content: Text(
            'Para jogar "$title", você precisa desbloqueá-lo com Neuro-créditos ou assistir a um vídeo parceiro.',
            style: const TextStyle(color: AppColors.textMedium),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textMedium)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _playMockVideo(moduleId);
              },
              icon: const Icon(LucideIcons.video, size: 18),
              label: const Text('Assistir Vídeo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _playMockVideo(String moduleId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return const _MockVideoScreen();
      },
    ).then((_) {
      _showCoinAnimation(moduleId);
    });
  }

  void _showCoinAnimation(String moduleId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(ctx);
            setState(() {
              _unlockedModules.add(moduleId);
            });
          }
        });
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.coins, size: 80, color: Colors.amber)
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1.seconds)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
              const SizedBox(height: 16),
              const Text(
                '+50 Neuro-créditos',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ).animate().fade().slideY(begin: 0.5),
              const SizedBox(height: 8),
              const Text(
                'Módulo Desbloqueado!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ).animate().fade(delay: 400.ms),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de Módulos'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Domine suas rotinas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 24),
              _buildModuleCard(
                id: 'attention',
                title: 'Atenção Concentrada',
                description: 'Treine seu foco ignorando distrações.',
                progress: 0.45,
                color: AppColors.cyan,
                icon: LucideIcons.target,
                route: '/game_attention',
              ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildModuleCard(
                id: 'memory',
                title: 'Memória Operacional',
                description: 'Aumente sua capacidade de reter informações.',
                progress: 0.80,
                color: AppColors.primaryDim,
                icon: LucideIcons.brain,
                route: '/game_memory',
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildModuleCard(
                id: 'sequence',
                title: 'Sequência Lógica',
                description: 'Melhore seu raciocínio de padrões complexos.',
                progress: 0.20,
                color: AppColors.primary,
                icon: LucideIcons.grid,
                route: '/game_sequence',
              ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildModuleCard(
                id: 'word_puzzle',
                title: 'Cruza-Letras',
                description: 'Desembaralhe palavras e ative a linguagem mental.',
                progress: 0.0,
                color: Colors.orangeAccent,
                icon: LucideIcons.type,
                route: '/game_word_puzzle',
              ).animate().fade(delay: 400.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildModuleCard(
                id: 'stroop',
                title: 'Conflito de Cores',
                description: 'Efeito Stroop para treinar a inibição cognitiva.',
                progress: 0.0,
                color: Colors.redAccent,
                icon: LucideIcons.palette,
                route: '/game_stroop',
              ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildModuleCard(
                id: 'math',
                title: 'Cálculo Rápido',
                description: 'Matemática mental sob pressão e raciocínio.',
                progress: 0.0,
                color: Colors.blueAccent,
                icon: LucideIcons.calculator,
                route: '/game_math',
              ).animate().fade(delay: 600.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildModuleCard(
                id: 'nback',
                title: 'Memória de Trabalho',
                description: 'Teste N-Back científico de retenção contínua.',
                progress: 0.0,
                color: Colors.purpleAccent,
                icon: LucideIcons.layers,
                route: '/game_nback',
              ).animate().fade(delay: 700.ms).slideY(begin: 0.1),
              const SizedBox(height: 16),
              _buildModuleCard(
                id: 'crossword',
                title: 'Palavras Cruzadas',
                description: 'Preencha a grade usando o conhecimento cognitivo.',
                progress: 0.0,
                color: Colors.tealAccent,
                icon: LucideIcons.grid,
                route: '/game_crossword',
              ).animate().fade(delay: 800.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required String id,
    required String title,
    required String description,
    required double progress,
    required Color color,
    required IconData icon,
    required String route,
  }) {
    final isLocked = !_unlockedModules.contains(id);

    return GestureDetector(
      onTap: () {
        if (isLocked) {
          _showUnlockDialog(id, title);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Opacity(
          opacity: isLocked ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLocked ? AppColors.outline.withOpacity(0.5) : color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(isLocked ? LucideIcons.lock : icon, color: isLocked ? AppColors.textMedium : color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLocked ? 'Bloqueado' : '${(progress * 100).toInt()}% Dominado',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isLocked ? AppColors.textMedium : color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, color: AppColors.textMedium),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
              if (!isLocked) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.outline.withOpacity(0.3),
                  color: color,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _MockVideoScreen extends StatefulWidget {
  const _MockVideoScreen();

  @override
  State<_MockVideoScreen> createState() => _MockVideoScreenState();
}

class _MockVideoScreenState extends State<_MockVideoScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _controller.forward().then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.playCircle, size: 64, color: AppColors.primary)
                    .animate(onPlay: (c) => c.repeat())
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 500.ms),
                const SizedBox(height: 24),
                const Text(
                  'Vídeo Parceiro em Exibição...',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _controller.value,
                  backgroundColor: Colors.white24,
                  color: AppColors.secondary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
