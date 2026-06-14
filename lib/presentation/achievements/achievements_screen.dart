import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../data/repository/achievement_repository.dart';
import '../../domain/models/achievement.dart';
import '../widgets/achievement_badge.dart';

final _achievementsProvider = FutureProvider.autoDispose(
  (ref) => ref.read(achievementRepositoryProvider).getAll(),
);

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_achievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pencapaian')),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softBlue)),
        error: (e, _) => Center(child: Text('$e')),
        data: (achievements) {
          final unlocked = achievements.where((a) => a.isUnlocked).toList();
          final locked = achievements.where((a) => !a.isUnlocked).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Stats row
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A1E10), Color(0xFF070E0A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.emerald.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statCol('${unlocked.length}', 'Terbuka', AppColors.emerald),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _statCol('${locked.length}', 'Belum', AppColors.textTertiary),
                    Container(width: 1, height: 40, color: AppColors.border),
                    _statCol('${achievements.length}', 'Total', AppColors.softBlue),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              if (unlocked.isNotEmpty) ...[
                _sectionHeader('✨ Sudah Diraih'),
                const SizedBox(height: 12),
                ...unlocked.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AchievementBadge(achievement: a),
                )),
                const SizedBox(height: 24),
              ],

              if (locked.isNotEmpty) ...[
                _sectionHeader('🔒 Belum Terbuka'),
                const SizedBox(height: 12),
                ...locked.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AchievementBadge(achievement: a),
                )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _statCol(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary)),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }
}
