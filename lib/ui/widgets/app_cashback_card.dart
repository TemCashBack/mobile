import 'package:flutter/material.dart';
import 'package:mobile/ui/theme/app_styles.dart';
import 'package:mobile/ui/theme/colors.dart';

class AppCashbackCard extends StatelessWidget {
  const AppCashbackCard({
    super.key,
    required this.balanceChild,
    this.usedChild,
  });

  final Widget balanceChild;
  final Widget? usedChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.62,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: secondaryThemeColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: secondaryThemeColor.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cashback disponível',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          balanceChild,
          if (usedChild != null) ...[
            const SizedBox(height: 6),
            usedChild!,
          ],
        ],
      ),
    );
  }
}

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    super.key,
    required this.label,
    required this.approved,
  });

  final String label;
  final bool approved;

  @override
  Widget build(BuildContext context) {
    final color = approved ? primaryThemeColor : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: approved ? primaryThemeColor.shade700 : AppColors.error,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
