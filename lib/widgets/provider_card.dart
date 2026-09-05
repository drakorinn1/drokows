import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/category.dart';
import '../models/provider_profile.dart';
import '../theme/app_theme.dart';
import 'star_rating.dart';

class ProviderCard extends StatelessWidget {
  final ProviderProfile provider;
  const ProviderCard({super.key, required this.provider});

  String get _initials {
    final parts = provider.displayName.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _initials,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            provider.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (provider.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                        ],
                      ],
                    ),
                    Text(
                      categoryName(provider.category),
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    StarRating(value: provider.avgRating, count: provider.ratingCount),
                  ],
                ),
              ),
              if (provider.hourlyRate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatTL(provider.hourlyRate!)} ₺',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Text('saatlik', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
            ],
          ),
          if (provider.bio != null && provider.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              provider.bio!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, color: AppColors.mutedForeground, height: 1.4),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              if ((provider.city ?? provider.district) != null)
                _MetaChip(
                  icon: Icons.location_on_outlined,
                  label: [provider.district, provider.city].where((e) => e != null && e.isNotEmpty).join(', '),
                ),
              _MetaChip(icon: Icons.work_outline_rounded, label: '${provider.jobsCompleted} iş tamamladı'),
            ],
          ),
          if (provider.phone != null && provider.phone!.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => launchUrlString('tel:${provider.phone}'),
                icon: const Icon(Icons.call_rounded, size: 18),
                label: const Text('Ustayı ara'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatTL(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
      ],
    );
  }
}
