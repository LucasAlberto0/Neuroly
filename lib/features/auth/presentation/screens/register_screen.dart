import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background abstract shapes
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 100),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 1.seconds),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/simbolo_branco.png',
                        height: 64,
                        errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.brain, size: 64, color: AppColors.primaryDim),
                      ),
                    ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    Text(
                      'Criar Conta',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Inicie sua evolução cognitiva.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 32),
                    GlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Nome Completo',
                              hintText: 'Digite seu nome',
                              prefixIcon: Icon(LucideIcons.user),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'E-mail',
                              hintText: 'exemplo@neuroly.com',
                              prefixIcon: Icon(LucideIcons.mail),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 16),
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              hintText: '••••••••',
                              prefixIcon: Icon(LucideIcons.lock),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // After registering, goes directly to home (or could go to login)
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      },
                      child: const Text('Cadastrar'),
                    ).animate().fade(delay: 600.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to Login
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Já possui uma conta? ',
                          style: TextStyle(color: AppColors.textMedium),
                          children: [
                            TextSpan(
                              text: 'Fazer Login',
                              style: TextStyle(color: AppColors.primaryDim, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: 700.ms),
                  ],
                ),
              ),
            ),
          ),
          // Back button on top left
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textHigh),
              onPressed: () => Navigator.pop(context),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}
