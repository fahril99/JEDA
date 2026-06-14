import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repository/journal_repository.dart';
import '../../data/repository/achievement_repository.dart';
import '../../domain/models/relapse_journal.dart';

class JournalFormScreen extends ConsumerStatefulWidget {
  const JournalFormScreen({super.key});
  @override
  ConsumerState<JournalFormScreen> createState() => _JournalFormScreenState();
}

class _JournalFormScreenState extends ConsumerState<JournalFormScreen> {
  String? _trigger;
  String? _emotion;
  int _intensity = 3;
  final _noteCtrl = TextEditingController();
  final _nextCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _noteCtrl.dispose(); _nextCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Catat dengan Jujur')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.emerald.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.emerald.withOpacity(0.2)),
              ),
              child: const Text(
                'Mencatat ini bukan tanda kelemahan. Ini tanda kesadaran diri yang tinggi. Kamu tidak perlu merasa malu.',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.emerald, height: 1.5),
              ),
            ),
            const SizedBox(height: 28),

            // Trigger
            _sectionLabel('Apa yang memicunya?'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: AppConstants.triggers.map((t) {
                final sel = _trigger == t;
                return GestureDetector(
                  onTap: () => setState(() => _trigger = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.warningSoft.withOpacity(0.15) : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppColors.warningSoft.withOpacity(0.6) : AppColors.border),
                    ),
                    child: Text(t, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppColors.warningSoft : AppColors.textSecondary)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Emotion
            _sectionLabel('Emosi saat itu?'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: AppConstants.emotions.map((e) {
                final sel = _emotion == e;
                return GestureDetector(
                  onTap: () => setState(() => _emotion = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.softBlue.withOpacity(0.12) : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppColors.softBlue.withOpacity(0.5) : AppColors.border),
                    ),
                    child: Text(e, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppColors.softBlue : AppColors.textSecondary)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Intensity slider
            _sectionLabel('Seberapa kuat dorongan itu? ($_intensity/5)'),
            const SizedBox(height: 8),
            Slider(
              value: _intensity.toDouble(),
              min: 1, max: 5, divisions: 4,
              label: _intensityLabel(_intensity),
              onChanged: (v) => setState(() => _intensity = v.round()),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Lemah', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary)),
              const Text('Sangat Kuat', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary)),
            ]),
            const SizedBox(height: 28),

            // Note
            _sectionLabel('Catatan (opsional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Apa yang terjadi sebelumnya? Bagaimana perasaanmu?'),
            ),
            const SizedBox(height: 20),

            // Next action
            _sectionLabel('Apa yang bisa dilakukan lain kali?'),
            const SizedBox(height: 8),
            TextField(
              controller: _nextCtrl,
              maxLines: 2,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Contoh: aktifkan Focus Mode saat jam 22:00'),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_trigger == null || _emotion == null || _saving) ? null : _save,
                child: Text(_saving ? 'Menyimpan...' : 'Simpan Refleksi'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Lewati'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  String _intensityLabel(int v) {
    switch (v) {
      case 1: return 'Sangat Lemah';
      case 2: return 'Lemah';
      case 3: return 'Sedang';
      case 4: return 'Kuat';
      default: return 'Sangat Kuat';
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(journalRepositoryProvider).create(
      trigger: _trigger!,
      emotion: _emotion!,
      intensity: _intensity,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      nextAction: _nextCtrl.text.trim().isEmpty ? null : _nextCtrl.text.trim(),
    );
    // Award honest reflection achievement
    await ref.read(achievementRepositoryProvider).checkHonestReflection();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terima kasih sudah jujur dengan dirimu sendiri. 💪')),
      );
      context.pop();
    }
  }
}
