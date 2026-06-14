import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repository/message_repository.dart';

class MessageBuilderScreen extends ConsumerStatefulWidget {
  const MessageBuilderScreen({super.key});

  @override
  ConsumerState<MessageBuilderScreen> createState() => _MessageBuilderScreenState();
}

class _MessageBuilderScreenState extends ConsumerState<MessageBuilderScreen> {
  final _ctrl = TextEditingController();
  String _selectedTone = 'gentle';
  String _selectedCategory = 'focus';
  bool _saving = false;

  static const _examples = [
    'Apakah ini benar-benar yang ingin kamu lakukan sekarang?',
    'Kamu tidak perlu menuruti dorongan ini.',
    'Ingat tujuanmu hari ini.',
    'Versi terbaik dirimu memilih dengan sadar.',
    'Tarik napas. Kamu masih punya pilihan.',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildMessageInput(),
                  const SizedBox(height: 20),
                  _buildToneSelector(),
                  const SizedBox(height: 20),
                  _buildCategorySelector(),
                  const SizedBox(height: 28),
                  const Text('Atau pilih contoh:', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  ..._examples.map(_buildExampleChip),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [_dot(), const SizedBox(width: 8), const Text('3 dari 5', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary))]),
          const SizedBox(height: 20),
          const Text('Pesan untuk dirimu', style: TextStyle(fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text('Pesan ini muncul saat jeda. Tuliskan sesuatu yang bermakna.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      controller: _ctrl,
      maxLines: 3,
      maxLength: 200,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: AppColors.textPrimary, fontStyle: FontStyle.italic),
      decoration: const InputDecoration(
        hintText: '"Apakah ini benar-benar yang kamu pilih?"',
        hintStyle: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textTertiary),
        counterStyle: TextStyle(fontFamily: 'Inter', color: AppColors.textTertiary, fontSize: 12),
      ),
    );
  }

  Widget _buildToneSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tone', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        Row(
          children: AppConstants.messageTones.map((tone) {
            final selected = _selectedTone == tone;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTone = tone),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.softBlue : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? AppColors.softBlue : AppColors.border),
                  ),
                  child: Text(
                    AppConstants.messageToneLabels[tone]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? AppColors.background : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.messageCategories.map((cat) {
            final selected = _selectedCategory == cat;
            return ChoiceChip(
              label: Text(AppConstants.messageCategoryLabels[cat]!),
              selected: selected,
              onSelected: (_) => setState(() => _selectedCategory = cat),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExampleChip(String example) {
    return GestureDetector(
      onTap: () => setState(() => _ctrl.text = example),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '"$example"',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              ),
            ),
            const Icon(Icons.add_rounded, color: AppColors.softBlue, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _saveAndContinue(skip: true),
              child: const Text('Lewati'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _saving ? null : () => _saveAndContinue(),
              child: Text(_saving ? 'Menyimpan...' : 'Simpan & Lanjut'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndContinue({bool skip = false}) async {
    setState(() => _saving = true);
    final repo = ref.read(messageRepositoryProvider);

    // Always seed defaults
    await repo.seedDefaultMessages();

    // Save custom message if filled
    if (!skip && _ctrl.text.trim().isNotEmpty) {
      await repo.createNew(
        text: _ctrl.text.trim(),
        category: _selectedCategory,
        tone: _selectedTone,
      );
    }

    if (mounted) context.go('/onboarding/countdown');
  }

  Widget _dot() => Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.softBlue, shape: BoxShape.circle));
}
