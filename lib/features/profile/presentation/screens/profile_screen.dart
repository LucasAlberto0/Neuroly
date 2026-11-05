import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/backend/models/backend_models.dart';
import '../../../../core/services/neuroly_api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final NeurolyApiClient _api = NeurolyApiClient();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  bool _notificationsEnabled = true;
  bool _dailyReminder = true;
  bool _darkTheme = true;

  @override
  void initState() {
    super.initState();
    final user = _api.currentUser;
    _nameController = TextEditingController(text: user?.name ?? 'Lucas Alberto');
    _emailController = TextEditingController(text: user?.email ?? 'lucas@neuroly.com');
    _notificationsEnabled = user?.notificationsEnabled ?? true;
    _dailyReminder = user?.dailyReminder ?? true;
    _darkTheme = user?.darkTheme ?? true;

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _api.fetchProfile();
      if (!mounted) return;
      setState(() {
        _nameController.text = profile.name;
        _emailController.text = profile.email;
        _notificationsEnabled = profile.notificationsEnabled;
        _dailyReminder = profile.dailyReminder;
        _darkTheme = profile.darkTheme;
      });
    } catch (_) {}
  }

  Future<void> _savePersonalInfo() async {
    try {
      await _api.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados do perfil salvos com sucesso!')),
      );
    } on BackendException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _updatePreference({
    bool? notificationsEnabled,
    bool? dailyReminder,
    bool? darkTheme,
  }) async {
    setState(() {
      if (notificationsEnabled != null) _notificationsEnabled = notificationsEnabled;
      if (dailyReminder != null) _dailyReminder = dailyReminder;
      if (darkTheme != null) _darkTheme = darkTheme;
    });
    try {
      await _api.updateProfile(
        notificationsEnabled: notificationsEnabled,
        dailyReminder: dailyReminder,
        darkTheme: darkTheme,
      );
    } catch (_) {}
  }

  Future<void> _handleLogout() async {
    await _api.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _api,
      builder: (context, _) {
        final user = _api.currentUser;
        final displayName = user?.name ?? _nameController.text;
        final displayEmail = user?.email ?? _emailController.text;
        final credits = user?.neuroCredits ?? 450;
        final plan = user?.plan ?? 'Neuroly Pro';

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
                  GestureDetector(
                    onTap: _savePersonalInfo,
                    child: Stack(
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
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),

                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    displayEmail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMedium,
                        ),
                  ),

                  const SizedBox(height: 40),

                  // Informações Pessoais
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Informações Pessoais',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: _savePersonalInfo,
                        icon: const Icon(LucideIcons.check, size: 16, color: AppColors.secondary),
                        label: const Text(
                          'Salvar',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GlassContainer(
                    child: Column(
                      children: [
                        _buildTextField('Nome Completo', _nameController, LucideIcons.user),
                        const SizedBox(height: 8),
                        _buildTextField('E-mail', _emailController, LucideIcons.mail),
                      ],
                    ),
                  ).animate().fade(delay: 300.ms).slideX(begin: -0.1),

                  const SizedBox(height: 32),

                  // Assinatura & Saldo
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Assinatura & Saldo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Plano
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.secondary.withOpacity(0.2),
                                AppColors.secondary.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.zap, color: AppColors.secondary, size: 20),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                plan,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Gerenciar plano',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Coins
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.2),
                                AppColors.primary.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.coins, color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$credits Neuro-créditos',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Histórico',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 350.ms).slideY(begin: 0.1),

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
                        _buildSwitchItem(
                          'Notificações Push',
                          _notificationsEnabled,
                          (val) => _updatePreference(notificationsEnabled: val),
                        ),
                        const Divider(color: AppColors.outline),
                        _buildSwitchItem(
                          'Lembrete de Treino Diário',
                          _dailyReminder,
                          (val) => _updatePreference(dailyReminder: val),
                        ),
                        const Divider(color: AppColors.outline),
                        _buildSwitchItem(
                          'Modo Escuro (Cyber-Core)',
                          _darkTheme,
                          (val) => _updatePreference(darkTheme: val),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 400.ms).slideX(begin: -0.1),

                  const SizedBox(height: 48),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(LucideIcons.logOut),
                      label: const Text('Sair do App'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        onSubmitted: (_) => _savePersonalInfo(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMedium),
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.primary.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
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
