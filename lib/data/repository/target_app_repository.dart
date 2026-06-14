import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/database/app_database.dart';
import '../local/database/dao/target_app_dao.dart';
import '../../domain/models/target_app.dart';
import '../../services/interception_service.dart';

final targetAppRepositoryProvider = Provider((ref) => TargetAppRepository(
  TargetAppDao(AppDatabase()),
  ref.read(interceptionServiceProvider),
));

class TargetAppRepository {
  final TargetAppDao _dao;
  final InterceptionService _interceptionService;

  TargetAppRepository(this._dao, this._interceptionService);

  Future<List<TargetApp>> getAll() => _dao.getAll();
  Future<List<TargetApp>> getEnabled() => _dao.getEnabled();

  Future<void> add(TargetApp app) async {
    await _dao.insert(app);
    await _syncToNative();
  }

  Future<void> remove(String packageName) async {
    await _dao.delete(packageName);
    await _syncToNative();
  }

  Future<void> toggle(String packageName, bool enabled) async {
    await _dao.toggleEnabled(packageName, enabled);
    await _syncToNative();
  }

  Future<void> update(TargetApp app) async {
    await _dao.update(app);
    await _syncToNative();
  }

  Future<int> getEnabledCount() => _dao.getCount();

  Future<bool> contains(String packageName) async {
    final app = await _dao.getByPackage(packageName);
    return app != null;
  }

  Future<void> _syncToNative() async {
    final enabled = await _dao.getEnabled();
    final packages = enabled.map((a) => a.packageName).toList();
    await _interceptionService.updateTargetApps(packages);
  }
}
