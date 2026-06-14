import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class CountdownRing extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isComplete;

  const CountdownRing({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.isComplete = false,
  });

  double get progress =>
      totalSeconds > 0 ? 1 - (remainingSeconds / totalSeconds) : 1.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: const Size(140, 140),
            painter: _RingPainter(
              progress: 1.0,
              color: AppColors.ringBackground,
              strokeWidth: 8,
            ),
          ),
          // Progress ring
          AnimatedBuilder(
            animation: AlwaysStoppedAnimation(progress),
            builder: (_, __) => CustomPaint(
              size: const Size(140, 140),
              painter: _RingPainter(
                progress: progress,
                color: isComplete ? AppColors.emerald : AppColors.ringProgress,
                strokeWidth: 8,
              ),
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isComplete
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.emerald, size: 40,
                        key: ValueKey('check'))
                    : Text(
                        remainingSeconds.toString().padLeft(2, '0'),
                        key: ValueKey(remainingSeconds),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -2,
                        ),
                      ),
              ),
              if (!isComplete)
                const Text(
                  'detik',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
