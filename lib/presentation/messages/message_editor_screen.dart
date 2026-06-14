import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repository/message_repository.dart';
import '../../domain/models/motivation_message.dart';

class MessageEditorScreen extends ConsumerStatefulWidget {
  final String? messageId;
  const MessageEditorScreen({super.key, this.messageId});

  @override
  ConsumerState<MessageEditorScreen> createState() => _MessageEditorScreenState();
}

class _MessageEditorScreenState extends ConsumerState<MessageEditorScreen> {
  final _ctrl = TextEditingController();
  String _tone = 'gentle';
  String _category = 'focus';
  bool _loading = false;
  bool _isEdit = false;
  MotivationMessage? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.messageId != null) {
      _isEdit = true;
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final all = await ref.read(messageRepositoryProvider).getAll();
    final msg = all.firstWhere((m) => m.id == widget.messageId);
    setState(() {
      _existing = msg;
      _ctrl.text = msg.text;
      _tone = msg.tone;
      _category = msg.category;
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Pesan' : 'Pesan Baru'),
        actions: [
          if (_isEdit)
            TextButton(
              onPressed: _save,
              child: const Text('Simpan', style: TextStyle(color: AppColors.softBlue, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Preview card
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: AppColors.interstitialGlow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preview', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: AppColors.textTertiary, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  Text(
                    _ctrl.text.isEmpty ? 'Pesan akan muncul di sini...' : '"${_ctrl.text}"',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: _ctrl.text.isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Text input
            const Text('Isi Pesan', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              maxLines: 4,
              maxLength: 200,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Tuliskan pesan yang bermakna untuk dirimu...',
                counterStyle: TextStyle(fontFamily: 'Inter', color: AppColors.textTertiary, fontSize: 11),
              ),
            ),
            const SizedBox(height: 24),

            // Tone
            const Text('Tone', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Row(
              children: AppConstants.messageTones.map((tone) {
                final sel = _tone == tone;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tone = tone),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.softBlue : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? AppColors.softBlue : AppColors.border),
                      ),
                      child: Text(
                        AppConstants.messageToneLabels[tone]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: sel ? AppColors.background : AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Category
            const Text('Kategori', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: AppConstants.messageCategories.map((cat) {
                final sel = _category == cat;
                return ChoiceChip(
                  label: Text(AppConstants.messageCategoryLabels[cat]!),
                  selected: sel,
                  onSelected: (_) => setState(() => _category = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _ctrl.text.trim().isEmpty || _loading ? null : _save,
                child: Text(_loading ? 'Menyimpan...' : (_isEdit ? 'Simpan Perubahan' : 'Tambah Pesan')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final repo = ref.read(messageRepositoryProvider);
    if (_isEdit && _existing != null) {
      await repo.update(_existing!.copyWith(
        text: _ctrl.text.trim(),
        tone: _tone,
        category: _category,
      ));
    } else {
      await repo.createNew(text: _ctrl.text.trim(), category: _category, tone: _tone);
    }
    if (mounted) context.pop();
  }
}
