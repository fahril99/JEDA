import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/preferences/app_preferences.dart';
import '../../services/permissions_service.dart';
import '../../services/notification_service.dart';

final _settingsProvider = FutureProvider.autoDispose((ref) async {
  final prefs = AppPreferences();
  final perms = ref.read(permissionsServiceProvider);
  final [countdown, morning, evening, privacy, serviceEnabled, accessEnabled] = await Future.wait([
    prefs.defaultCountdown,
    prefs.morningReminderTime,
    prefs.eveningReviewTime,
    prefs.privacyMode,
    prefs.serviceEnabled,
    perms.isAccessibilityEnabled(),
  ]);
  return {
    'countdown': countdown,
    'morning': morning,
    'evening': evening,
    'privacy': privacy,
    'serviceEnabled': serviceEnabled,
    'accessEnabled': accessEnabled,
  };
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(_settingsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengaturan')),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softBlue)),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) => _buildContent(data),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final countdown = data['countdown'] as int;
    final morning = data['morning'] as String?;
    final evening = data['evening'] as String?;
    final privacy = data['privacy'] as bool;
    final serviceEnabled = data['serviceEnabled'] as bool;
    final accessEnabled = data['accessEnabled'] as bool;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Service status
        if (!accessEnabled)
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorSoft.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.errorSoft.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.errorSoft, size: 22),
                const SizedBox(width: 12),
                const Expanded(child: Text('Accessibility Service tidak aktif', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.errorSoft, height: 1.4))),
                TextButton(
                  onPressed: () => ref.read(permissionsServiceProvider).openAccessibilitySettings(),
                  child: const Text('Aktifkan'),
                ),
              ],
            ),
          ),

        _sectionLabel('Jeda'),
        _settingsTile(
          icon: Icons.timer_outlined,
          title: 'Durasi Default Jeda',
          subtitle: '$countdown detik',
          onTap: () => _showCountdownPicker(countdown),
        ),
        _toggleTile(
          icon: Icons.shield_outlined,
          title: 'JEDA Aktif',
          subtitle: 'Pause sebelum membuka app pemicu',
          value: serviceEnabled,
          onChanged: (v) async {
            await AppPreferences().setServiceEnabled(v);
            ref.invalidate(_settingsProvider);
          },
        ),

        const SizedBox(height: 20),
        _sectionLabel('Pengingat'),
        _settingsTile(
          icon: Icons.wb_sunny_outlined,
          title: 'Reminder Pagi',
          subtitle: morning ?? 'Belum diatur',
          onTap: () => _pickTime(context, isMorning: true, current: morning),
        ),
        _settingsTile(
          icon: Icons.nights_stay_outlined,
          title: 'Review Malam',
          subtitle: evening ?? 'Belum diatur',
          onTap: () => _pickTime(context, isMorning: false, current: evening),
        ),

        const SizedBox(height: 20),
        _sectionLabel('Privasi'),
        _toggleTile(
          icon: Icons.lock_outline_rounded,
          title: 'Mode Privasi',
          subtitle: 'Sembunyikan nama app di statistik',
          value: privacy,
          onChanged: (v) async {
            await AppPreferences().setPrivacyMode(v);
            ref.invalidate(_settingsProvider);
          },
        ),

        const SizedBox(height: 20),
        _sectionLabel('Konten'),
        _settingsTile(
          icon: Icons.message_outlined,
          title: 'Pesan Motivasi',
          subtitle: 'Kelola pesan yang muncul saat jeda',
          onTap: () => context.push('/messages'),
        ),
        _settingsTile(
          icon: Icons.flag_outlined,
          title: 'Tujuan Hidupku',
          subtitle: 'Tetapkan tujuan yang menginspirasi',
          onTap: () => context.push('/goals'),
        ),
        _settingsTile(
          icon: Icons.emoji_events_outlined,
          title: 'Pencapaian',
          subtitle: 'Lihat semua pencapaianmu',
          onTap: () => context.push('/achievements'),
        ),

        const SizedBox(height: 20),
        _sectionLabel('Lainnya'),
        _settingsTile(
          icon: Icons.info_outline_rounded,
          title: 'Tentang JEDA',
          subtitle: 'v1.0.0 — Digital Commitment Companion',
          onTap: () => _showAbout(context),
        ),
        _settingsTile(
          icon: Icons.delete_outline_rounded,
          title: 'Reset Semua Data',
          subtitle: 'Hapus semua data lokal',
          isDestructive: true,
          onTap: () => _confirmReset(context),
        ),

        const SizedBox(height: 40),
        Center(
          child: Column(
            children: const [
              Text('JEDA', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: -0.5)),
              Text('Berhenti sebentar. Pilih dengan sadar.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary)),
              SizedBox(height: 8),
              Text('Data tersimpan 100% di perangkat kamu.', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(), style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 1.0)),
    );
  }

  Widget _settingsTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDestructive ? AppColors.errorSoft.withOpacity(0.15) : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? AppColors.errorSoft : AppColors.textSecondary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: isDestructive ? AppColors.errorSoft : AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDestructive ? AppColors.errorSoft.withOpacity(0.5) : AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile({required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Future<void> _showCountdownPicker(int current) async {
    int selected = current;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Durasi Jeda'),
        content: StatefulBuilder(
          builder: (_, setSt) => Column(
            mainAxisSize: MainAxisSize.min,
            children: AppConstants.countdownOptions.map((sec) {
              final sel = selected == sec;
              return RadioListTile<int>(
                value: sec,
                groupValue: selected,
                title: Text('$sec detik'),
                activeColor: AppColors.softBlue,
                onChanged: (v) { setSt(() => selected = v!); },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await AppPreferences().setDefaultCountdown(selected);
              if (mounted) { ref.invalidate(_settingsProvider); Navigator.pop(context); }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, {required bool isMorning, String? current}) async {
    TimeOfDay initial = const TimeOfDay(hour: 7, minute: 0);
    if (current != null) {
      final parts = current.split(':');
      if (parts.length == 2) {
        initial = TimeOfDay(hour: int.tryParse(parts[0]) ?? 7, minute: int.tryParse(parts[1]) ?? 0);
      }
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    final timeStr = '${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}';
    final prefs = AppPreferences();
    if (isMorning) {
      await prefs.setMorningReminderTime(timeStr);
      await NotificationService.instance.scheduleMorningReminder(picked.hour, picked.minute);
    } else {
      await prefs.setEveningReviewTime(timeStr);
      await NotificationService.instance.scheduleEveningReview(picked.hour, picked.minute);
    }
    ref.invalidate(_settingsProvider);
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tentang JEDA'),
        content: const Text(
          'JEDA v1.0.0\n\nDigital Commitment Companion\n\n'
          '"Berhenti sebentar. Pilih dengan sadar."\n\n'
          'JEDA membantu kamu membangun jeda sadar sebelum membuka aplikasi yang sering menjadi pemicu kebiasaan tidak produktif.\n\n'
          '• Semua data tersimpan lokal di perangkatmu\n'
          '• Tidak ada akun atau server\n'
          '• Tidak ada tracking, iklan, atau analitik pihak ketiga',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Semua Data?'),
        content: const Text('Semua data aplikasi, jurnal, komitmen, dan streak akan dihapus. Tindakan ini tidak bisa dibatalkan.', style: TextStyle(height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorSoft),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await AppPreferences().clear();
      ref.invalidate(_settingsProvider);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil direset')));
    }
  }
}
