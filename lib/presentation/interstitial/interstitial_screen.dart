import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme/app_colors.dart';

/// This screen is rendered inside InterstitialActivity via a second Flutter engine.
/// It receives data through the MethodChannel from native Kotlin.
class InterstitialScreen extends StatefulWidget {
  const InterstitialScreen({super.key});

  @override
  State<InterstitialScreen> createState() => _InterstitialScreenState();
}

class _InterstitialScreenState extends State<InterstitialScreen> with TickerProviderStateMixin {
  static const _channel = MethodChannel('com.jeda.app/interstitial');

  String _packageName = '';
  String _appLabel = '';
  int _countdownTotal = 5;
  int _remaining = 5;
  String _message = '';
  String _commitment = '';
  String _lifeGoal = '';
  String _protectionLevel = 'gentle';
  bool _countdownComplete = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleNativeCall);
    // Request data from native
    _requestData();
  }

  Future<void> _requestData() async {
    try {
      final data = await _channel.invokeMethod<Map>('getInterstitialData');
      if (data != null && mounted) {
        setState(() {
          _packageName = data['packageName'] as String? ?? '';
          _appLabel = data['appLabel'] as String? ?? _packageName.split('.').last;
          _countdownTotal = data['countdownSec'] as int? ?? 5;
          _remaining = _countdownTotal;
          _message = data['message'] as String? ?? '';
          _commitment = data['commitment'] as String? ?? '';
          _lifeGoal = data['lifeGoal'] as String? ?? '';
          _protectionLevel = data['protectionLevel'] as String? ?? 'gentle';
        });
        _startCountdown();
      }
    } on PlatformException {
      // Fallback — start with defaults
      _startCountdown();
    }
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    // Native can push data or force-close
    if (call.method == 'forceClose') {
      _dismiss('timeout');
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _countdownComplete = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _dismiss(String action) {
    _timer?.cancel();
    try {
      _channel.invokeMethod('onUserAction', {
        'action': action,
        'packageName': _packageName,
        'countdownSec': _countdownTotal,
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050B14), Color(0xFF0A1525), Color(0xFF050B14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // JEDA header
                const Text('JEDA', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 2))
                    .animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'Kamu membuka $_appLabel',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 100.ms),
                const Spacer(flex: 1),

                // Countdown ring
                _buildCountdownRing().animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 32),

                // Motivation message
                if (_message.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.softBlue.withOpacity(0.15)),
                    ),
                    child: Text(
                      '"$_message"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: AppColors.textPrimary, fontStyle: FontStyle.italic, height: 1.5),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                // Commitment
                if (_commitment.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.emerald.withOpacity(0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.flag_rounded, color: AppColors.emerald, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _commitment,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.emerald, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ],

                // Life goal
                if (_lifeGoal.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    _lifeGoal,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textTertiary, height: 1.4),
                  ).animate().fadeIn(delay: 600.ms),
                ],

                const Spacer(flex: 2),

                // Action buttons
                if (_countdownComplete) ...[
                  // Cancel — go back
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _dismiss('cancelled'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Kembali — Pilihan Lebih Baik', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
                  const SizedBox(height: 10),
                  // Continue — open app
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        if (_protectionLevel == 'strong') {
                          _showReasonPicker();
                        } else {
                          _dismiss('continued');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textTertiary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Tetap buka $_appLabel',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ] else
                  Text(
                    'Tarik napas...',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary.withOpacity(0.6)),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 1500.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownRing() {
    final progress = _countdownTotal > 0 ? 1.0 - (_remaining / _countdownTotal) : 1.0;
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160, height: 160,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: AppColors.border.withOpacity(0.3),
              color: _countdownComplete ? AppColors.emerald : AppColors.softBlue,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_countdownComplete)
                const Icon(Icons.check_rounded, color: AppColors.emerald, size: 48)
              else
                Text(
                  '$_remaining',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 52, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -3),
                ),
              if (!_countdownComplete)
                const Text('detik', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  void _showReasonPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kenapa kamu ingin membuka?', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ...['Perlu untuk kerja/tugas', 'Ada pesan penting', 'Hanya sebentar saja', 'Tidak bisa menahan'].map((reason) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _dismiss('continued');
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(reason, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary)),
              ),
            )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); _dismiss('cancelled'); },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald, foregroundColor: AppColors.background),
                child: const Text('Batal — Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
