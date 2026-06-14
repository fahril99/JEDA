import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../data/repository/commitment_repository.dart';
import '../../domain/models/daily_commitment.dart';
import '../../core/extensions/datetime_ext.dart';

class CommitmentScreen extends ConsumerStatefulWidget {
  const CommitmentScreen({super.key});

  @override
  ConsumerState<CommitmentScreen> createState() => _CommitmentScreenState();
}

class _CommitmentScreenState extends ConsumerState<CommitmentScreen> {
  final _ctrl = TextEditingController();
  int _selectedTemplate = -1;
  bool _saving = false;
  DailyCommitment? _existing;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final existing = await ref.read(commitmentRepositoryProvider).getToday();
    if (existing != null && mounted) {
      setState(() {
        _existing = existing;
        _ctrl.text = existing.text;
      });
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Komitmen Hari Ini')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (_existing != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(child: Text('Kamu sudah membuat komitmen hari ini.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.emerald))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            const Text('Saya hari ini akan...', style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            // Custom input
            TextField(
              controller: _ctrl,
              maxLines: 3,
              maxLength: 200,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Tulis komitmenmu sendiri...',
                counterStyle: TextStyle(fontFamily: 'Inter', color: AppColors.textTertiary, fontSize: 11),
              ),
              onChanged: (_) => setState(() => _selectedTemplate = -1),
            ),
            const SizedBox(height: 24),
            const Text('Atau pilih template:', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ...List.generate(CommitmentRepository.templates.length, (i) {
              final sel = _selectedTemplate == i;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedTemplate = i;
                  _ctrl.text = CommitmentRepository.templates[i];
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.softBlue.withOpacity(0.08) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? AppColors.softBlue.withOpacity(0.4) : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(CommitmentRepository.templates[i], style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: sel ? AppColors.textPrimary : AppColors.textSecondary, height: 1.4))),
                      if (sel) const Icon(Icons.check_circle_rounded, color: AppColors.softBlue, size: 18),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            // Recent commitments
            FutureBuilder<List<DailyCommitment>>(
              future: ref.read(commitmentRepositoryProvider).getRecent(7),
              builder: (_, snap) {
                final items = snap.data ?? [];
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Komitmen Terakhir', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    ...items.take(5).map((c) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _statusIcon(c.status),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.text, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(c.date, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary)),
                            ],
                          )),
                        ],
                      ),
                    )),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _ctrl.text.trim().isEmpty || _saving ? null : _save,
              child: Text(_saving ? 'Menyimpan...' : (_existing != null ? 'Perbarui Komitmen' : 'Simpan Komitmen')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusIcon(String status) {
    switch (status) {
      case 'success': return const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 16);
      case 'partial': return const Icon(Icons.remove_circle_rounded, color: AppColors.warningSoft, size: 16);
      case 'missed': return const Icon(Icons.cancel_rounded, color: AppColors.errorSoft, size: 16);
      default: return const Icon(Icons.radio_button_unchecked, color: AppColors.textTertiary, size: 16);
    }
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await ref.read(commitmentRepositoryProvider).createForToday(_ctrl.text.trim());
    if (mounted) context.pop();
  }
}
