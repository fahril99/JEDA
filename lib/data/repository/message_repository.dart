import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/database/dao/motivation_message_dao.dart';
import '../../domain/models/motivation_message.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/weighted_random.dart';

final messageRepositoryProvider = Provider((ref) => MessageRepository(
  MotivationMessageDao(AppDatabase()),
));

class MessageRepository {
  final MotivationMessageDao _dao;
  final _random = WeightedRandom();
  final _recentIds = <String>[];
  static const _recentWindow = 5;

  MessageRepository(this._dao);

  Future<List<MotivationMessage>> getAll() => _dao.getAll();

  Future<List<MotivationMessage>> getEnabled({String? packageName}) =>
      _dao.getEnabled(packageName: packageName);

  Future<void> add(MotivationMessage message) => _dao.insert(message);

  Future<void> update(MotivationMessage message) => _dao.update(message);

  Future<void> delete(String id) => _dao.delete(id);

  Future<void> rate(String id, int rating) => _dao.rateMessage(id, rating);

  Future<MotivationMessage?> pickRandom({String? packageName}) async {
    final messages = await _dao.getEnabled(packageName: packageName);
    if (messages.isEmpty) return null;

    final picked = _random.pickByWeight<MotivationMessage>(
      messages,
      (m) => m.weight,
      recentIds: _recentIds,
      idGetter: (m) => m.id,
    );

    // Track recently shown
    _recentIds.add(picked.id);
    if (_recentIds.length > _recentWindow) _recentIds.removeAt(0);

    // Update last shown timestamp
    await _dao.updateLastShown(picked.id, DateTime.now().millisecondsSinceEpoch);

    return picked;
  }

  Future<void> seedDefaultMessages() async {
    final hasDefaults = await _dao.hasDefaultMessages();
    if (hasDefaults) return;

    final uuid = const Uuid();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final msgData in AppConstants.defaultMessages) {
      await _dao.insert(MotivationMessage(
        id: uuid.v4(),
        text: msgData['text']!,
        category: msgData['category']!,
        tone: msgData['tone']!,
        isDefault: true,
        weight: 5,
        createdAt: now,
      ));
    }
  }

  Future<int> getUserMessageCount() => _dao.getUserMessageCount();

  Future<MotivationMessage> createNew({
    required String text,
    required String category,
    required String tone,
    String? targetPackageName,
  }) async {
    final message = MotivationMessage(
      id: const Uuid().v4(),
      text: text,
      category: category,
      tone: tone,
      targetPackageName: targetPackageName,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _dao.insert(message);
    return message;
  }
}
