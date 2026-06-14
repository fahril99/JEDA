import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../data/repository/target_app_repository.dart';
import '../../domain/models/target_app.dart';
import '../../services/installed_apps_service.dart';
import '../widgets/app_row_widget.dart';

class AppSelectionScreen extends ConsumerStatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  ConsumerState<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends ConsumerState<AppSelectionScreen> {
  final Set<String> _selected = {};
  List<InstalledApp> _apps = [];
  List<InstalledApp> _filtered = [];
  bool _loading = true;
  String _query = '';

  // Common trigger apps shown first
  static const _suggestedPackages = [
    'com.android.chrome',
    'com.instagram.android',
    'com.zhiliaoapp.musically',
    'com.reddit.frontpage',
    'org.telegram.messenger',
    'com.twitter.android',
    'com.google.android.youtube',
    'com.facebook.katana',
  ];

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await ref.read(installedAppsServiceProvider).getInstalledApps();
    // Sort: suggested first
    final sorted = [...apps]..sort((a, b) {
        final aIdx = _suggestedPackages.indexOf(a.packageName);
        final bIdx = _suggestedPackages.indexOf(b.packageName);
        if (aIdx != -1 && bIdx != -1) return aIdx.compareTo(bIdx);
        if (aIdx != -1) return -1;
        if (bIdx != -1) return 1;
        return a.appName.compareTo(b.appName);
      });
    if (mounted) setState(() { _apps = sorted; _filtered = sorted; _loading = false; });
  }

  void _onSearch(String q) {
    setState(() {
      _query = q;
      _filtered = _apps
          .where((a) => a.appName.toLowerCase().contains(q.toLowerCase()) ||
              a.packageName.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  Future<void> _onContinue() async {
    final repo = ref.read(targetAppRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final pkg in _selected) {
      final app = _apps.firstWhere((a) => a.packageName == pkg);
      await repo.add(TargetApp(
        packageName: pkg,
        appLabel: app.appName,
        iconBase64: app.iconBase64,
        createdAt: now,
      ));
    }
    if (mounted) context.go('/onboarding/messages');
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
            _buildSearch(),
            Expanded(child: _loading ? _buildLoading() : _buildList()),
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _dot(), const SizedBox(width: 8),
            const Text('2 dari 5', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 20),
          const Text('Pilih aplikasi pemicu', style: TextStyle(fontFamily: 'Inter', fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('${_selected.length} dipilih', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        onChanged: _onSearch,
        style: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Cari aplikasi...',
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: AppColors.softBlue));
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final app = _filtered[i];
        final selected = _selected.contains(app.packageName);
        return AppRowWidget(
          packageName: app.packageName,
          appName: app.appName,
          iconBytes: app.iconBytes,
          isSelected: selected,
          onTap: () => setState(() {
            if (selected) _selected.remove(app.packageName);
            else _selected.add(app.packageName);
          }),
        );
      },
    );
  }

  Widget _buildBottom() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selected.isEmpty ? null : _onContinue,
          child: Text(_selected.isEmpty ? 'Pilih minimal 1 app' : 'Lanjut dengan ${_selected.length} app'),
        ),
      ),
    );
  }

  Widget _dot() => Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.softBlue, shape: BoxShape.circle));
}
