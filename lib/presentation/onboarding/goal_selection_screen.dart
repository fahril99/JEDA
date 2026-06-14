import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/local/preferences/app_preferences.dart';

class GoalSelectionScreen extends ConsumerStatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  ConsumerState<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends ConsumerState<GoalSelectionScreen> {
  final Set<String> _selected = {};
  String? _customText;

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
                  const SizedBox(height: 8),
                  ...AppConstants.goalCategories.map(_buildGoalTile),
                  if (_selected.contains('custom')) _buildCustomInput(),
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
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.softBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '1 dari 5',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Apa yang ingin\nkamu kurangi?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih satu atau lebih. Kamu bisa ubah kapan saja.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTile(Map<String, dynamic> goal) {
    final id = goal['id'] as String;
    final selected = _selected.contains(id);
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _selected.remove(id);
        } else {
          _selected.add(id);
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppColors.softBlue.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.softBlue.withOpacity(0.5) : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(goal['icon'] as String, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                goal['label'] as String,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.softBlue : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.softBlue : AppColors.border,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 13, color: AppColors.background)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        autofocus: true,
        style: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Tulis tujuanmu sendiri...',
        ),
        onChanged: (v) => _customText = v,
      ),
    );
  }

  Widget _buildBottom() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selected.isEmpty ? null : _onContinue,
          child: const Text('Lanjut'),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    final goalLabel = _selected.isNotEmpty
        ? AppConstants.goalCategories
            .firstWhere((g) => g['id'] == _selected.first,
                orElse: () => {'label': _customText ?? ''})['label']
        : '';
    await AppPreferences().setPrimaryGoal(goalLabel as String);
    if (mounted) context.go('/onboarding/apps');
  }
}
