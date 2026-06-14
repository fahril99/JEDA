import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../local/database/app_database.dart';
import '../local/database/dao/daily_commitment_dao.dart';
import '../../domain/models/daily_commitment.dart';
import '../../core/constants/app_constants.dart';

final commitmentRepositoryProvider = Provider((ref) => CommitmentRepository(
  DailyCommitmentDao(AppDatabase()),
));

class CommitmentRepository {
  final DailyCommitmentDao _dao;
  CommitmentRepository(this._dao);

  Future<DailyCommitment?> getToday() => _dao.getToday();

  Future<List<DailyCommitment>> getRecent(int days) => _dao.getRecent(days);

  Future<DailyCommitment> createForToday(String text) async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final commitment = DailyCommitment(
      id: const Uuid().v4(),
      date: dateStr,
      text: text,
      status: AppConstants.commitmentActive,
      morningCreatedAt: now.millisecondsSinceEpoch,
    );
    await _dao.insert(commitment);
    return commitment;
  }

  Future<void> reviewToday(String status) async {
    final today = await _dao.getToday();
    if (today == null) return;
    await _dao.updateStatus(
      today.id,
      status,
      reviewAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<int> getCompletedCount() => _dao.getCompletedCount();

  static const List<String> templates = [
    'Hari ini saya tidak akan membuka konten yang merusak fokus saya.',
    'Hari ini saya memakai media sosial hanya untuk hal yang perlu.',
    'Hari ini saya memilih tidur lebih cepat daripada scrolling.',
    'Hari ini saya memilih produktivitas daripada hiburan digital.',
    'Hari ini saya akan jeda setiap kali merasa ingin membuka aplikasi pemicu.',
    'Hari ini saya memilih fokus pada pekerjaan yang penting.',
    'Hari ini saya hadir penuh dalam setiap momen.',
  ];
}
