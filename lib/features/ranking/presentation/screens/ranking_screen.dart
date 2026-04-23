import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for the leaderboard
    final List<Map<String, dynamic>> rankingData = [
      {'name': 'Lucas Silva', 'score': 12500},
      {'name': 'Mariana Costa', 'score': 11200},
      {'name': 'Você', 'score': 10500, 'avatar': 'assets/images/profile_pic.jpg', 'isMe': true},
      {'name': 'Pedro Alves', 'score': 9800},
      {'name': 'Ana Paula', 'score': 9400},
      {'name': 'Carlos Eduardo', 'score': 8900},
      {'name': 'Julia Rocha', 'score': 8200},
      {'name': 'Rafael Gomes', 'score': 7600},
      {'name': 'Fernanda Lima', 'score': 7100},
      {'name': 'Bruno Souza', 'score': 6500},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking Nacional', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter, color: AppColors.textMedium),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildPodium(rankingData.sublist(0, 3)),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: rankingData.length - 3,
                  itemBuilder: (context, index) {
                    final item = rankingData[index + 3];
                    return _buildRankingItem(item, index + 4)
                        .animate()
                        .fade(duration: 400.ms, delay: (100 * index).ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPodiumItem(top3[1], 2, 100, AppColors.cyan), // 2nd Place
          _buildPodiumItem(top3[0], 1, 140, const Color(0xFFFFD700)), // 1st Place (Gold)
          _buildPodiumItem(top3[2], 3, 80, const Color(0xFFCD7F32)), // 3rd Place (Bronze)
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> user, int position, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: CircleAvatar(
                radius: position == 1 ? 40 : 32,
                backgroundColor: color,
                child: CircleAvatar(
                  radius: position == 1 ? 36 : 28,
                  backgroundColor: AppColors.surfaceBright,
                  backgroundImage: user['avatar'] != null ? AssetImage(user['avatar']) : null,
                  child: user['avatar'] == null
                      ? Text(
                          user['name'].toString().substring(0, 1),
                          style: TextStyle(
                            color: AppColors.textHigh,
                            fontSize: position == 1 ? 24 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            if (position == 1)
              const Icon(LucideIcons.crown, color: Color(0xFFFFD700), size: 28)
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 1500.ms, color: Colors.white),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user['name'].toString().split(' ')[0], // First name only
          style: TextStyle(
            color: AppColors.textHigh,
            fontWeight: position == 1 ? FontWeight.bold : FontWeight.w500,
            fontSize: position == 1 ? 16 : 14,
          ),
        ),
        Text(
          '${user['score']} pts',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: position == 1 ? 90 : 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border.all(color: color.withOpacity(0.5), width: 1),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            '$position',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ]
    ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutBack).fade();
  }

  Widget _buildRankingItem(Map<String, dynamic> user, int position) {
    final isMe = user['isMe'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(20),
        border: isMe ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#$position',
              style: TextStyle(
                color: isMe ? AppColors.primaryDim : AppColors.textMedium,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              backgroundColor: AppColors.surfaceBright,
              backgroundImage: user['avatar'] != null ? AssetImage(user['avatar']) : null,
              child: user['avatar'] == null
                  ? Text(
                      user['name'].toString().substring(0, 1),
                      style: const TextStyle(
                        color: AppColors.textHigh,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ],
        ),
        title: Text(
          user['name'],
          style: TextStyle(
            color: isMe ? AppColors.primaryDim : AppColors.textHigh,
            fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        trailing: Text(
          '${user['score']} pts',
          style: const TextStyle(
            color: AppColors.cyan,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
