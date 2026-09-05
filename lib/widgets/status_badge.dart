import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final info = kRequestStatus[status] ?? RequestStatusInfo(status, 'open');
    final colors = {
      'open': AppColors.primary,
      'assigned': AppColors.chart2,
      'done': AppColors.chart3,
      'cancelled': AppColors.mutedForeground,
    };
    final color = colors[info.tone] ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        info.label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
