import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../data/local/preferences/app_preferences.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});
  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  final _goalCtrl = TextEditingController();
  bool _showInPopup = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = AppPreferences();
    final [goalText, showInPopup] = await Future.wait([
      prefs.lifeGoalText,
      prefs.showGoalInPopup,
    ]);
    if (mounted) {
      setState(() {
        _goalCtrl.text = (goalText as String?) ?? '';
        _showInPopup = showInPopup as bool;
        _loading = false;
      });
    }
  }

  @override
  void dispose() { _goalCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tujuan Hidup')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.softBlue))
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Goal card preview
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.interstitialGlow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.softBlue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flag_rounded, color: AppColors.softBlue, size: 18),
                            SizedBox(width: 8),
                            Text('Tujuan hidupmu', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.softBlue, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _goalCtrl.text.isEmpty ? 'Tuliskan tujuan hidupmu di bawah...' : '"${_goalCtrl.text}"',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: _goalCtrl.text.isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
                            fontStyle: _goalCtrl.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text('Tujuan Utamamu', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _goalCtrl,
                    maxLines: 4,
                    maxLength: 300,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Contoh: "Saya ingin punya hidup yang fokus dan tenang, dan menjadi versi terbaik diri saya."',
                      counterStyle: TextStyle(fontFamily: 'Inter', color: AppColors.textTertiary, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Suggestions
                  const Text('Contoh tujuan:', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textTertiary)),
                  const SizedBox(height: 10),
                  ...[
                    'Selesaikan skripsi dan wisuda tepat waktu.',
                    'Jaga relasi dengan orang yang berarti bagiku.',
                    'Tidur cukup dan bangun dengan energi penuh.',
                    'Bangun tubuh yang sehat dan pikiran yang jernih.',
                    'Fokus dalam pekerjaan dan hasilkan karya terbaik.',
                  ].map((t) => GestureDetector(
                    onTap: () => setState(() => _goalCtrl.text = t),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                      child: Row(
                        children: [
                          Expanded(child: Text(t, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary))),
                          const Icon(Icons.add_rounded, color: AppColors.softBlue, size: 16),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),

                  // Show in popup toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tampilkan di popup', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              Text('Tujuan muncul saat jeda untuk pengingat', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Switch(value: _showInPopup, onChanged: (v) => setState(() => _showInPopup = v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Menyimpan...' : 'Simpan Tujuan'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prefs = AppPreferences();
    await prefs.setLifeGoalText(_goalCtrl.text.trim());
    await prefs.setShowGoalInPopup(_showInPopup);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tujuan disimpan ✓')),
      );
    }
  }
}
