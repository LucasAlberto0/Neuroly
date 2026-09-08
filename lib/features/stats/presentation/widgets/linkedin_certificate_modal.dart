import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class LinkedinCertificateModal extends StatefulWidget {
  const LinkedinCertificateModal({super.key});

  @override
  State<LinkedinCertificateModal> createState() => _LinkedinCertificateModalState();
}

class _LinkedinCertificateModalState extends State<LinkedinCertificateModal> {
  late ConfettiController _confettiController;
  bool _showingPreview = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [AppColors.primary, AppColors.secondary, Colors.amber, Colors.white],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _showingPreview ? _buildPreview() : _buildCertificate(),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificate() {
    return GlassContainer(
      key: const ValueKey('cert'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.award, size: 64, color: Colors.amber)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2.seconds)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.seconds),
          const SizedBox(height: 16),
          Text(
            'Parabéns, Lucas!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHigh,
                ),
          ).animate().fade().slideY(begin: 0.3),
          const SizedBox(height: 8),
          Text(
            'Certificado de Consistência Cognitiva Liberado!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fade(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            'Seu Neuroly Score atingiu o topo. Você demonstrou foco, memória e lógica excepcionais.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMedium,
                ),
          ).animate().fade(delay: 400.ms),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showingPreview = true;
                });
              },
              icon: const Icon(LucideIcons.linkedin, size: 20),
              label: const Text('Compartilhar no LinkedIn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary, // Electric Blue
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ).animate().fade(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: AppColors.textMedium)),
          ).animate().fade(delay: 800.ms),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return GlassContainer(
      key: const ValueKey('preview'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text('L', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lucas', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('Agora mesmo • 🌎', style: TextStyle(color: AppColors.textMedium, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Muito feliz em compartilhar meu mais novo Certificado de Consistência Cognitiva pelo @Neuroly! 🧠🚀 Foram semanas de foco e dedicação para melhorar minha memória e raciocínio lógico.',
            style: TextStyle(color: AppColors.textHigh, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceBright,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.award, size: 48, color: Colors.amber),
                  SizedBox(height: 8),
                  Text(
                    'Top 1% Neuroly Score',
                    style: TextStyle(color: AppColors.textHigh, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: AppColors.textMedium)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Compartilhado com sucesso!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Publicar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
