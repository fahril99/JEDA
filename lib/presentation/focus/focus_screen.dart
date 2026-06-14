import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../data/repository/focus_session_repository.dart';
import '../../data/repository/target_app_repository.dart';
import '../../data/repository/streak_repository.dart';
import '../../domain/models/focus_session.dart';
import '../../services/notification_service.dart';

final _focusProvider = FutureProvider.autoDispose((ref) async {
  final sessionRepo = ref.read(focusSessionRepositoryProvider);
  final appRepo = ref.read(targetAppRepositoryProvider);
  final [active, apps] = await Future.wait([
    sessionRepo.getActiveSession(),
    appRepo.getEnabled(),
  ]);
  return {'active': active, 'apps': apps};
});

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});
  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  int _durationMinutes = 30;
  String _protectionLevel = 'gentle';
  bool _starting = false;

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(_focusProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Focus Mode')),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softBlue)),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          final active = data['active'] as FocusSession?;
          if (active != null && active.isActive) {
            return _buildActiveSession(active);
          }
          return _buildSetup();
        },
      ),
    );
  }

  Widget _buildActiveSession(FocusSession session) {
    final remaining = session.remaining;
    final total = Duration(minutes: session.durationMinutes);
    final progress = 1.0 - (remaining.inSeconds / total.inSeconds).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0A1E35), Color(0xFF050E1A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.shield_rounded, color: AppColors.emerald, size: 48),
                const SizedBox(height: 20),
                const Text('Focus Mode Aktif', style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  '${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2,'0')} tersisa',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.emerald, letterSpacing: -2),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(value: progress, backgroundColor: AppColors.surfaceElevated, color: AppColors.emerald, minHeight: 8),
                ),
                const SizedBox(height: 8),
                Text('${session.durationMinutes} menit total', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.softBlue, size: 18),
                const SizedBox(width: 10),
                Text('${session.targetPackages.length} aplikasi dilindungi', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary)),
                const Spacer(),
                Text(session.protectionLevel == 'strong' ? '⚡ Strong' : '🌿 Gentle', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _endSession(session.id, completed: false),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.errorSoft, side: const BorderSide(color: AppColors.errorSoft)),
              child: const Text('Hentikan Sesi'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _endSession(session.id, completed: true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: AppColors.background),
              child: const Text('Selesaikan Sesi ✓'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetup() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Mulai sesi fokus', style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        const Text('Selama sesi aktif, jeda akan lebih tegas untuk aplikasi pilihanmu.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 28),

        // Duration
        const Text('Durasi', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(
          children: [30, 60, 120].map((min) {
            final sel = _durationMinutes == min;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _durationMinutes = min),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.softBlue : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppColors.softBlue : AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text('${min >= 60 ? min ~/ 60 : min}', style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w700, color: sel ? AppColors.background : AppColors.textPrimary)),
                      Text(min >= 60 ? 'jam' : 'mnt', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: sel ? AppColors.background.withOpacity(0.7) : AppColors.textTertiary)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Protection level
        const Text('Mode Proteksi', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        _protectionOption('gentle', '🌿 Gentle', 'Jeda pendek, pesan reflektif'),
        const SizedBox(height: 8),
        _protectionOption('strong', '⚡ Strong', 'Jeda lebih panjang, pilih alasan membuka'),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _starting ? null : _startSession,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(_starting ? 'Memulai...' : 'Mulai Sesi Fokus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _protectionOption(String value, String title, String subtitle) {
    final sel = _protectionLevel == value;
    return GestureDetector(
      onTap: () => setState(() => _protectionLevel = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? AppColors.emerald.withOpacity(0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? AppColors.emerald.withOpacity(0.4) : AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: sel ? AppColors.textPrimary : AppColors.textSecondary)),
                Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary)),
              ],
            )),
            if (sel) const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _startSession() async {
    setState(() => _starting = true);
    final apps = await ref.read(targetAppRepositoryProvider).getEnabled();
    final packages = apps.map((a) => a.packageName).toList();
    await ref.read(focusSessionRepositoryProvider).startSession(
      durationMinutes: _durationMinutes,
      targetPackages: packages,
      protectionLevel: _protectionLevel,
    );
    await NotificationService.instance.showFocusSessionStarted(_durationMinutes);
    ref.invalidate(_focusProvider);
    if (mounted) setState(() => _starting = false);
  }

  Future<void> _endSession(String id, {required bool completed}) async {
    await ref.read(focusSessionRepositoryProvider).endSession(id, completed: completed);
    await NotificationService.instance.cancelFocusNotification();
    if (completed) {
      await ref.read(streakRepositoryProvider).incrementFocusStreak();
    }
    ref.invalidate(_focusProvider);
  }
}
