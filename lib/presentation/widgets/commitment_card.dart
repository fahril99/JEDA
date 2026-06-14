import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../domain/models/daily_commitment.dart';

class CommitmentCard extends StatelessWidget {
  final DailyCommitment? commitment;
  final VoidCallback? onTap;
  final VoidCallback? onReview;

  const CommitmentCard({
    super.key,
    this.commitment,
    this.onTap,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    if (commitment == null) {
      return _EmptyCommitment(onTap: onTap);
    }
    return _FilledCommitment(
      commitment: commitment!,
      onTap: onTap,
      onReview: onReview,
    );
  }
}

class _EmptyCommitment extends StatelessWidget {
  final VoidCallback? onTap;
  const _EmptyCommitment({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.softBlue.withOpacity(0.3),
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.softBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.softBlue, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buat komitmen hari ini',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Mulai hari dengan niat yang jelas',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _FilledCommitment extends StatelessWidget {
  final DailyCommitment commitment;
  final VoidCallback? onTap;
  final VoidCallback? onReview;

  const _FilledCommitment({
    required this.commitment,
    this.onTap,
    this.onReview,
  });

  Color get _statusColor {
    switch (commitment.status) {
      case 'success': return AppColors.emerald;
      case 'partial': return AppColors.warningSoft;
      case 'missed': return AppColors.errorSoft;
      default: return AppColors.softBlue;
    }
  }

  IconData get _statusIcon {
    switch (commitment.status) {
      case 'success': return Icons.check_circle_rounded;
      case 'partial': return Icons.remove_circle_rounded;
      case 'missed': return Icons.cancel_rounded;
      default: return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _statusColor.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_statusIcon, color: _statusColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Komitmen hari ini',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (commitment.isActive && onReview != null)
                  GestureDetector(
                    onTap: onReview,
                    child: const Text(
                      'Review',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.softBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              commitment.text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
