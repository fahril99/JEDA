import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/extensions/datetime_ext.dart';
import '../../data/repository/journal_repository.dart';
import '../../domain/models/relapse_journal.dart';

final _journalProvider = FutureProvider.autoDispose(
  (ref) => ref.read(journalRepositoryProvider).getRecent(30),
);

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_journalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Jurnal')),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softBlue)),
        error: (e, _) => Center(child: Text('$e')),
        data: (entries) {
          if (entries.isEmpty) return _buildEmpty(context);
          return RefreshIndicator(
            color: AppColors.softBlue,
            backgroundColor: AppColors.surface,
            onRefresh: () async => ref.invalidate(_journalProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: entries.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) return _buildInsightBanner(entries);
                return _buildEntry(context, entries[i - 1]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/journal/new').then((_) => ref.invalidate(_journalProvider)),
        backgroundColor: AppColors.softBlue,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Catat Slip', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.surfaceElevated, shape: BoxShape.circle),
              child: const Icon(Icons.book_outlined, color: AppColors.textTertiary, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Belum ada catatan', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            const Text('Jurnal membantu kamu memahami pola.\nCatat dengan jujur, bukan untuk menghakimi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightBanner(List<RelapseJournal> entries) {
    if (entries.length < 2) return const SizedBox.shrink();
    // Find most common trigger
    final triggerMap = <String, int>{};
    for (final e in entries) {
      triggerMap[e.trigger] = (triggerMap[e.trigger] ?? 0) + 1;
    }
    final topTrigger = triggerMap.entries.reduce((a, b) => a.value >= b.value ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.softBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.softBlue, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(
            'Trigger paling sering: "${topTrigger.key}" (${topTrigger.value}x dalam 30 hari)',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.softBlue, height: 1.4),
          )),
        ],
      ),
    );
  }

  Widget _buildEntry(BuildContext context, RelapseJournal entry) {
    final dt = entry.occurredAtDateTime;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(dt.toFriendlyDate(), style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary)),
              const SizedBox(width: 6),
              Text(dt.toTimeString(), style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.warningSoft.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(entry.trigger, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.warningSoft)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _infoChip('😶', entry.emotion),
              const SizedBox(width: 8),
              _infoChip('📊', 'Intensitas ${entry.intensity}/5'),
              if (entry.packageName != null) ...[
                const SizedBox(width: 8),
                _infoChip('📱', entry.packageName!.split('.').last),
              ],
            ],
          ),
          if (entry.note != null && entry.note!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(entry.note!, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.4)),
          ],
          if (entry.nextAction != null && entry.nextAction!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('→ ', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w700)),
                Expanded(child: Text(entry.nextAction!, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.emerald, height: 1.3))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(8)),
      child: Text('$emoji $text', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textSecondary)),
    );
  }
}
