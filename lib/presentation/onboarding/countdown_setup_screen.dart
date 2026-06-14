import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/preferences/app_preferences.dart';

class CountdownSetupScreen extends ConsumerStatefulWidget {
  const CountdownSetupScreen({super.key});

  @override
  ConsumerState<CountdownSetupScreen> createState() => _CountdownSetupScreenState();
}

class _CountdownSetupScreenState extends ConsumerState<CountdownSetupScreen> {
  int _selected = AppConstants.defaultCountdownSec;

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
                  Row(children: [_dot(), const SizedBox(width: 8), const Text('4 dari 5', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary))]),
                  const SizedBox(height: 20),
                  const Text('Durasi jeda', style: TextStyle(fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  const Text('Seberapa lama layar jeda ditampilkan?', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  ...AppConstants.countdownOptions.map(_buildOption),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      '💡 Penelitian menunjukkan bahwa jeda 5-10 detik cukup untuk mengaktifkan prefrontal cortex — bagian otak yang membuat keputusan rasional.',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  child: const Text('Lanjut'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int sec) {
    final selected = _selected == sec;
    return GestureDetector(
      onTap: () => setState(() => _selected = sec),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.emerald.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.emerald.withOpacity(0.5) : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected ? AppColors.emerald.withOpacity(0.12) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$sec',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.emerald : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$sec detik',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _getDescription(sec),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.emerald),
          ],
        ),
      ),
    );
  }

  String _getDescription(int sec) {
    if (sec <= 3) return 'Mode cepat — jeda ringan';
    if (sec <= 5) return 'Direkomendasikan — seimbang';
    if (sec <= 10) return 'Lebih kuat — untuk kebiasaan berat';
    if (sec <= 15) return 'Serius — proteksi ekstra';
    if (sec <= 30) return 'Kuat — sangat sadar';
    return 'Maksimum — untuk jam rawan';
  }

  Future<void> _onContinue() async {
    await AppPreferences().setDefaultCountdown(_selected);
    if (mounted) context.go('/onboarding/permissions');
  }

  Widget _dot() => Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.softBlue, shape: BoxShape.circle));
}
