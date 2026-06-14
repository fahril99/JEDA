import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';
import '../../data/local/preferences/app_preferences.dart';
import '../../services/permissions_service.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  bool _accessibilityEnabled = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _checking = true);
    final enabled = await ref.read(permissionsServiceProvider).isAccessibilityEnabled();
    if (mounted) setState(() { _accessibilityEnabled = enabled; _checking = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [_dot(), const SizedBox(width: 8), const Text('5 dari 5', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary))]),
                  const SizedBox(height: 20),
                  const Text('Aktifkan pendamping', style: TextStyle(fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Disclosure card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.softBlue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.softBlue, size: 20),
                            const SizedBox(width: 8),
                            const Text('Transparansi Penuh', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.softBlue)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'JEDA menggunakan Accessibility Service untuk mendeteksi saat aplikasi yang kamu pilih dibuka, lalu menampilkan layar jeda sadar.\n\n'
                          'JEDA TIDAK membaca:\n'
                          '• Isi chat atau pesan\n'
                          '• Password atau input sensitif\n'
                          '• Halaman web yang kamu kunjungi\n'
                          '• Konten pribadi di layar\n\n'
                          'Data aktivitas disimpan di perangkat. Tidak ada yang dikirim ke server.',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary, height: 1.6),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 24),
                  // Permission status
                  _buildPermissionRow(
                    icon: Icons.accessibility_new_rounded,
                    title: 'Accessibility Service',
                    subtitle: 'Mendeteksi saat app pemicu dibuka',
                    granted: _accessibilityEnabled,
                    onTap: () async {
                      await ref.read(permissionsServiceProvider).openAccessibilitySettings();
                      await Future.delayed(const Duration(seconds: 2));
                      _checkPermissions();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_accessibilityEnabled)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 22),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Siap! JEDA akan mulai memantau aplikasi pilihanmu.',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.emerald, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                children: [
                  if (!_accessibilityEnabled)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _checking ? null : _checkPermissions,
                          child: const Text('Periksa ulang'),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _finish(),
                      style: _accessibilityEnabled ? null : ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceElevated,
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: Text(_accessibilityEnabled ? 'Mulai JEDA 🎉' : 'Lanjut tanpa izin (mode terbatas)'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool granted,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: granted ? AppColors.emerald.withOpacity(0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: granted ? AppColors.emerald.withOpacity(0.1) : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: granted ? AppColors.emerald : AppColors.textSecondary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (granted)
            const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 22)
          else
            TextButton(
              onPressed: onTap,
              child: const Text('Aktifkan'),
            ),
        ],
      ),
    );
  }

  Future<void> _finish() async {
    await AppPreferences().setOnboardingCompleted(true);
    if (mounted) context.go('/');
  }

  Widget _dot() => Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.softBlue, shape: BoxShape.circle));
}
