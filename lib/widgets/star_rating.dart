import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final double value;
  final int? count;
  final double size;

  const StarRating({super.key, required this.value, this.count, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final rounded = value.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rounded ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i <= rounded ? AppColors.primary : AppColors.mutedForeground.withOpacity(0.4),
          ),
        const SizedBox(width: 4),
        Text(
          (value > 0 ? value.toStringAsFixed(1) : 'Yeni') +
              (count != null && count! > 0 ? ' ($count)' : ''),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
