import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../data/repository/interception_repository.dart';
import '../../data/repository/journal_repository.dart';
import '../../data/repository/streak_repository.dart';

final _insightsProvider = FutureProvider.autoDispose((ref) async {
  final interceptRepo = ref.read(interceptionRepositoryProvider);
  final journalRepo = ref.read(journalRepositoryProvider);
  final streakRepo = ref.read(streakRepositoryProvider);

  final results = await Future.wait([
    interceptRepo.getActionCounts(days: 30),
    interceptRepo.getAppCounts(days: 30),
    interceptRepo.getHourlyDistribution(days: 30),
    journalRepo.getTriggerFrequency(days: 30),
    journalRepo.getEmotionFrequency(days: 30),
    streakRepo.getStreakData(),
  ]);
  return {
    'actionCounts': results[0],
    'appCounts': results[1],
    'hourlyDist': results[2],
    'triggerFreq': results[3],
    'emotionFreq': results[4],
    'streak': results[5],
  };
});

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_insightsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Insight')),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softBlue)),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) => _buildContent(data),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final actionCounts = data['actionCounts'] as Map<String, int>;
    final appCounts = data['appCounts'] as Map<String, int>;
    final hourlyDist = data['hourlyDist'] as Map<int, int>;
    final triggerFreq = data['triggerFreq'] as Map<String, int>;
    final emotionFreq = data['emotionFreq'] as Map<String, int>;

    final total = actionCounts.values.fold(0, (a, b) => a + b);
    final cancelled = actionCounts['cancelled'] ?? 0;
    final continued = actionCounts['continued'] ?? 0;
    final cancelRate = total > 0 ? (cancelled / total * 100).round() : 0;

    return RefreshIndicator(
      color: AppColors.softBlue,
      backgroundColor: AppColors.surface,
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Summary cards
          Row(children: [
            Expanded(child: _summaryCard('Total Jeda', '$total', '30 hari', AppColors.softBlue, Icons.pause_circle_outline)),
            const SizedBox(width: 12),
            Expanded(child: _summaryCard('Batal Buka', '$cancelRate%', 'tingkat jeda', AppColors.emerald, Icons.check_circle_outline)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _summaryCard('Dilanjutkan', '$continued', 'kali dibuka', AppColors.warningSoft, Icons.arrow_forward_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _summaryCard('Jeda Sadar', '$cancelled', 'kali kembali', AppColors.emerald, Icons.favorite_border)),
          ]),
          const SizedBox(height: 28),

          // Hourly heatmap
          if (hourlyDist.isNotEmpty) ...[
            _sectionHeader('Jam Rawan', Icons.access_time_rounded),
            const SizedBox(height: 14),
            _buildHourlyHeatmap(hourlyDist),
            const SizedBox(height: 8),
            _buildNightZoneWarning(hourlyDist),
            const SizedBox(height: 28),
          ],

          // App breakdown
          if (appCounts.isNotEmpty) ...[
            _sectionHeader('Aplikasi Pemicu', Icons.apps_rounded),
            const SizedBox(height: 14),
            _buildAppBreakdown(appCounts),
            const SizedBox(height: 28),
          ],

          // Trigger frequency
          if (triggerFreq.isNotEmpty) ...[
            _sectionHeader('Trigger Paling Sering', Icons.psychology_outlined),
            const SizedBox(height: 14),
            _buildFrequencyBars(triggerFreq, AppColors.warningSoft),
            const SizedBox(height: 28),
          ],

          // Emotion frequency
          if (emotionFreq.isNotEmpty) ...[
            _sectionHeader('Emosi Saat Slip', Icons.sentiment_dissatisfied_outlined),
            const SizedBox(height: 14),
            _buildFrequencyBars(emotionFreq, AppColors.softBlue),
            const SizedBox(height: 28),
          ],

          if (total == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.insights_outlined, color: AppColors.textTertiary, size: 64),
                    const SizedBox(height: 16),
                    const Text('Data belum tersedia', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    const Text('Insight akan muncul setelah JEDA merekam beberapa interaksi.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary, height: 1.5)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.softBlue, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildHourlyHeatmap(Map<int, int> dist) {
    final maxVal = dist.values.isEmpty ? 1 : dist.values.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(24, (h) {
              final count = dist[h] ?? 0;
              final intensity = maxVal > 0 ? count / maxVal : 0.0;
              final isNight = h >= 22 || h < 2;
              return Expanded(
                child: Tooltip(
                  message: '${h.toString().padLeft(2,'0')}:00 — $count jeda',
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: isNight
                          ? AppColors.errorSoft.withOpacity(0.15 + intensity * 0.7)
                          : AppColors.softBlue.withOpacity(0.1 + intensity * 0.8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['00', '06', '12', '18', '23'].map((h) =>
              Text(h, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: AppColors.textTertiary))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNightZoneWarning(Map<int, int> dist) {
    final nightCount = [22, 23, 0, 1].fold(0, (s, h) => s + (dist[h] ?? 0));
    if (nightCount == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorSoft.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.errorSoft.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.nightlight_rounded, color: AppColors.errorSoft, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text('Jam 22:00–02:00 adalah periode paling rawan ($nightCount jeda).', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.errorSoft, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildAppBreakdown(Map<String, int> appCounts) {
    final total = appCounts.values.fold(0, (a, b) => a + b);
    final sorted = appCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        children: sorted.take(5).map((entry) {
          final pct = total > 0 ? (entry.value / total) : 0.0;
          final appName = entry.key.split('.').last;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(appName, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary))),
                    Text('${(pct * 100).round()}% (${entry.value}x)', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.surfaceElevated,
                    color: AppColors.softBlue,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFrequencyBars(Map<String, int> freq, Color color) {
    final sorted = freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.isEmpty ? 1 : sorted.first.value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        children: sorted.take(5).map((entry) {
          final pct = maxVal > 0 ? entry.value / maxVal : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(width: 100, child: Text(entry.key, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: pct, backgroundColor: AppColors.surfaceElevated, color: color, minHeight: 8),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${entry.value}x', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
