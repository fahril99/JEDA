import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../data/repository/message_repository.dart';
import '../../domain/models/motivation_message.dart';
import '../widgets/message_card.dart';

final _messagesProvider = FutureProvider.autoDispose(
  (ref) => ref.read(messageRepositoryProvider).getAll(),
);

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_messagesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesan Motivasi'),
        actions: [
          IconButton(
            onPressed: () => context.push('/messages/edit'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softBlue)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (messages) {
          if (messages.isEmpty) {
            return const Center(
              child: Text('Belum ada pesan.\nTambahkan pesan motivasi pertamamu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary, height: 1.6)),
            );
          }
          final defaults = messages.where((m) => m.isDefault).toList();
          final custom = messages.where((m) => !m.isDefault).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (custom.isNotEmpty) ...[
                const _SectionHeader(title: 'Pesanmu'),
                const SizedBox(height: 12),
                ...custom.map((m) => MessageCard(
                  message: m,
                  onEdit: () => context.push('/messages/edit?id=${m.id}'),
                  onToggle: () async {
                    await ref.read(messageRepositoryProvider).update(m.copyWith(isEnabled: !m.isEnabled));
                    ref.invalidate(_messagesProvider);
                  },
                  onDelete: () async {
                    await ref.read(messageRepositoryProvider).delete(m.id);
                    ref.invalidate(_messagesProvider);
                  },
                )),
                const SizedBox(height: 24),
              ],
              if (defaults.isNotEmpty) ...[
                const _SectionHeader(title: 'Pesan Bawaan'),
                const SizedBox(height: 12),
                ...defaults.map((m) => MessageCard(
                  message: m,
                  onToggle: () async {
                    await ref.read(messageRepositoryProvider).update(m.copyWith(isEnabled: !m.isEnabled));
                    ref.invalidate(_messagesProvider);
                  },
                )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5),
  );
}
