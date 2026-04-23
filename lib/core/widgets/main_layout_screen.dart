import 'package:flutter/material.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/modules/presentation/screens/modules_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const StatsScreen(),
    const ModulesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMedium,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.barChart2), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.library), label: 'Módulos'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Perfil'),
        ],
      ),
    );
  }
}
