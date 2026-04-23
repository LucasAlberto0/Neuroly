import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _dailyReminder = true;
  bool _darkTheme = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      color: AppColors.surfaceBright,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/profile_pic.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.edit2, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Text(
                'Lucas Alberto',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'lucas@neuroly.com',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Informações Pessoais
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Informações Pessoais',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                child: Column(
                  children: [
                    _buildTextField('Nome Completo', 'Lucas Alberto', LucideIcons.user),
                    const Divider(color: AppColors.outline),
                    _buildTextField('E-mail', 'lucas@neuroly.com', LucideIcons.mail),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Preferências
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Preferências',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GlassContainer(
                child: Column(
                  children: [
                    _buildSwitchItem('Notificações Push', _notificationsEnabled, (val) => setState(() => _notificationsEnabled = val)),
                    const Divider(color: AppColors.outline),
                    _buildSwitchItem('Lembrete de Treino Diário', _dailyReminder, (val) => setState(() => _dailyReminder = val)),
                    const Divider(color: AppColors.outline),
                    _buildSwitchItem('Modo Escuro (Cyber-Core)', _darkTheme, (val) => setState(() => _darkTheme = val)),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: const Icon(LucideIcons.logOut),
                  label: const Text('Sair do App'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMedium),
          hintText: placeholder,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: const TextStyle(color: AppColors.textHigh),
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.textHigh, fontSize: 16),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
