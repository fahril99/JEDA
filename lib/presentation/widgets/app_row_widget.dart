import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class AppRowWidget extends StatelessWidget {
  final String packageName;
  final String appName;
  final Uint8List? iconBytes;
  final bool isSelected;
  final bool showSwitch;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  const AppRowWidget({
    super.key,
    required this.packageName,
    required this.appName,
    this.iconBytes,
    this.isSelected = false,
    this.showSwitch = false,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.softBlue.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.softBlue.withOpacity(0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // App icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: iconBytes != null
                  ? Image.memory(iconBytes!, width: 40, height: 40, fit: BoxFit.cover)
                  : Container(
                      width: 40,
                      height: 40,
                      color: AppColors.surfaceElevated,
                      child: const Icon(Icons.apps_rounded,
                          color: AppColors.textTertiary, size: 22),
                    ),
            ),
            const SizedBox(width: 14),
            // App name and package
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    packageName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Trailing — switch or checkbox
            if (showSwitch && onToggle != null)
              Switch(value: isSelected, onChanged: onToggle)
            else if (!showSwitch)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.softBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColors.softBlue : AppColors.border,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: AppColors.background)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
