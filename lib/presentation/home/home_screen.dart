import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/datetime_ext.dart';
import '../../data/local/preferences/app_preferences.dart';
import '../../data/repository/commitment_repository.dart';
import '../../data/repository/streak_repository.dart';
import '../../data/repository/interception_repository.dart';
import '../../domain/models/daily_commitment.dart';
import '../../domain/models/achievement.dart';
import '../widgets/streak_card.dart';
import '../widgets/commitment_card.dart';

final _homeDataProvider = FutureProvider.autoDispose((ref) async {
  final commitRepo = ref.read(commitmentRepositoryProvider);
  final streakRepo = ref.read(streakRepositoryProvider);
  final interceptRepo = ref.read(interceptionRepositoryProvider);
  final prefs = AppPreferences();

  final results = await Future.wait([
    commitRepo.getToday(),
    streakRepo.getStreakData(),
    interceptRepo.getTodayCount(),
    interceptRepo.getTodayCancelledCount(),
    prefs.lifeGoalText,
    prefs.primaryGoal,
  ]);

  return {
    'commitment': results[0],
    'streak': results[1],
    'todayCount': results[2],
    'cancelledCount': results[3],
    'lifeGoal': results[4],
    'primaryGoal': results[5],
  };
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_homeDataProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.softBlue,
          backgroundColor: AppColors.surface,
          onRefresh: () async => ref.invalidate(_homeDataProvider),
          child: dataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softBlue)),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.errorSoft))),
            data: (data) => _buildContent(context, ref, data, now),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Map<String, dynamic> data, DateTime now) {
    final commitment = data['commitment'] as DailyCommitment?;
    final streak = data['streak'] as StreakData;
    final todayCount = data['todayCount'] as int;
    final cancelledCount = data['cancelledCount'] as int;
    final lifeGoal = data['lifeGoal'] as String?;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            now.timeGreeting,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          const Text('JEDA', style: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -1)),
                        ],
                      ),
                    ),
                    // Quick actions
                    IconButton(
                      onPressed: () => context.push('/achievements'),
                      icon: const Icon(Icons.emoji_events_outlined, color: AppColors.textSecondary),
                    ),
                    IconButton(
                      onPressed: () => context.push('/goals'),
                      icon: const Icon(Icons.flag_outlined, color: AppColors.textSecondary),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 24),

                // Today's quote
                if (lifeGoal != null && lifeGoal.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_rounded, color: AppColors.softBlue, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            lifeGoal,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                // Streak card
                StreakCard(
                  mainStreak: streak.mainStreak,
                  focusStreak: streak.focusStreak,
                  recoveryStreak: streak.recoveryStreak,
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),

                // Commitment card
                CommitmentCard(
                  commitment: commitment,
                  onTap: () => context.push('/commitment'),
                  onReview: commitment != null ? () => _showReview(context, ref, commitment) : null,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),

                // Today stats
                _buildTodayStats(todayCount, cancelledCount)
                    .animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 20),

                // Focus mode shortcut
                _buildFocusShortcut(context).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 20),

                // Quote of the day
                _buildQuote().animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStats(int todayCount, int cancelledCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hari ini', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatItem(value: '$todayCount', label: 'Jeda total', icon: Icons.pause_circle_outline, color: AppColors.softBlue)),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(child: _StatItem(value: '$cancelledCount', label: 'Batal buka', icon: Icons.check_circle_outline, color: AppColors.emerald)),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(child: _StatItem(
                value: todayCount > 0 ? '${((cancelledCount / todayCount) * 100).round()}%' : '—',
                label: 'Tingkat jeda',
                icon: Icons.trending_up_rounded,
                color: AppColors.warningSoft,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFocusShortcut(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/focus'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D2035), Color(0xFF0A1828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softBlue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.softBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.timer_outlined, color: AppColors.softBlue, size: 26),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mulai Focus Mode', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  Text('Proteksi lebih kuat untuk sesi fokus', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuote() {
    final quotes = AppConstants.builtinQuotes;
    final idx = DateTime.now().day % quotes.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quote hari ini', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Text(quotes[idx], style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.6)),
        ],
      ),
    );
  }

  void _showReview(BuildContext context, WidgetRef ref, DailyCommitment commitment) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _ReviewSheet(commitment: commitment, ref: ref),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatItem({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  final DailyCommitment commitment;
  final WidgetRef ref;
  const _ReviewSheet({required this.commitment, required this.ref});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review komitmen hari ini', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('"${widget.commitment.text}"', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            _option('success', '✅ Berhasil', 'Saya menjalani komitmen ini hari ini', AppColors.emerald),
            const SizedBox(height: 10),
            _option('partial', '🟡 Sebagian', 'Ada beberapa slip, tapi saya mencoba', AppColors.warningSoft),
            const SizedBox(height: 10),
            _option('missed', '📝 Perlu evaluasi', 'Hari ini berat, tapi saya tidak menyerah', AppColors.softBlue),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected == null ? null : () async {
                  await widget.ref.read(commitmentRepositoryProvider).reviewToday(_selected!);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Simpan Review'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _option(String value, String title, String subtitle, Color color) {
    final selected = _selected == value;
    return GestureDetector(
      onTap: () => setState(() => _selected = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color.withOpacity(0.4) : AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: selected ? color : AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
