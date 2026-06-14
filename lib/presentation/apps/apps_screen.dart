import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repository/target_app_repository.dart';
import '../../data/repository/message_repository.dart';
import '../../domain/models/target_app.dart';
import '../../services/installed_apps_service.dart';
import '../../services/permissions_service.dart';
import '../widgets/app_row_widget.dart';

final _appsScreenProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.read(targetAppRepositoryProvider);
  final perms = ref.read(permissionsServiceProvider);
  final [apps, accessEnabled] = await Future.wait([
    repo.getAll(),
    perms.isAccessibilityEnabled(),
  ]);
  return {'apps': apps, 'accessEnabled': accessEnabled};
});

class AppsScreen extends ConsumerWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(_appsScreenProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Aplikasi Pantauan'),
        actions: [
          IconButton(
            onPressed: () => _showAddSheet(context, ref),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah app',
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softBlue)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final apps = data['apps'] as List<TargetApp>;
          final accessEnabled = data['accessEnabled'] as bool;
          return RefreshIndicator(
            color: AppColors.softBlue,
            backgroundColor: AppColors.surface,
            onRefresh: () async => ref.invalidate(_appsScreenProvider),
            child: CustomScrollView(
              slivers: [
                if (!accessEnabled)
                  SliverToBoxAdapter(child: _buildAccessWarning(context, ref)),
                if (apps.isEmpty)
                  SliverFillRemaining(child: _buildEmpty(context))
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _buildAppTile(context, ref, apps[i]),
                        childCount: apps.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccessWarning(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningSoft.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warningSoft.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.warningSoft, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Accessibility Service tidak aktif. Jeda tidak akan muncul.',
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.warningSoft, height: 1.4),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(permissionsServiceProvider).openAccessibilitySettings(),
            child: const Text('Aktifkan'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.textTertiary, size: 64),
          const SizedBox(height: 16),
          const Text('Belum ada app pantauan', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Tambahkan aplikasi yang ingin\nkamu pantau', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textTertiary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddSheet(context, null),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Aplikasi'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppTile(BuildContext context, WidgetRef ref, TargetApp app) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(app.packageName),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.errorSoft.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: AppColors.errorSoft),
        ),
        confirmDismiss: (_) async => _confirmDelete(context, app.appLabel),
        onDismissed: (_) async {
          await ref.read(targetAppRepositoryProvider).remove(app.packageName);
          ref.invalidate(_appsScreenProvider);
        },
        child: AppRowWidget(
          packageName: app.packageName,
          appName: app.appLabel,
          isSelected: app.isEnabled,
          showSwitch: true,
          onToggle: (v) async {
            await ref.read(targetAppRepositoryProvider).toggle(app.packageName, v);
            ref.invalidate(_appsScreenProvider);
          },
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus aplikasi?'),
        content: Text('Hapus $name dari daftar pantauan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.errorSoft)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showAddSheet(BuildContext context, WidgetRef? ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddAppSheet(),
    );
  }
}

class _AddAppSheet extends ConsumerStatefulWidget {
  const _AddAppSheet();

  @override
  ConsumerState<_AddAppSheet> createState() => _AddAppSheetState();
}

class _AddAppSheetState extends ConsumerState<_AddAppSheet> {
  List<InstalledApp> _apps = [];
  List<InstalledApp> _filtered = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final apps = await ref.read(installedAppsServiceProvider).getInstalledApps();
    final existing = await ref.read(targetAppRepositoryProvider).getAll();
    final existingPkgs = existing.map((a) => a.packageName).toSet();
    final filtered = apps.where((a) => !existingPkgs.contains(a.packageName)).toList();
    if (mounted) setState(() { _apps = filtered; _filtered = filtered; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Container(height: 4, width: 40, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              autofocus: true,
              onChanged: (q) => setState(() {
                _query = q;
                _filtered = _apps.where((a) => a.appName.toLowerCase().contains(q.toLowerCase())).toList();
              }),
              decoration: const InputDecoration(hintText: 'Cari aplikasi...', prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary)),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.softBlue))
                : ListView.separated(
                    controller: ctrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final app = _filtered[i];
                      return AppRowWidget(
                        packageName: app.packageName,
                        appName: app.appName,
                        iconBytes: app.iconBytes,
                        onTap: () async {
                          final now = DateTime.now().millisecondsSinceEpoch;
                          await ref.read(targetAppRepositoryProvider).add(TargetApp(
                            packageName: app.packageName,
                            appLabel: app.appName,
                            iconBase64: app.iconBase64,
                            createdAt: now,
                          ));
                          if (context.mounted) Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
