import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/service_request.dart';
import '../services/reviews_repository.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

class CustomerRequestCard extends StatefulWidget {
  final ServiceRequest request;
  final bool reviewed;
  final VoidCallback onCancelled;
  final VoidCallback onReviewed;

  const CustomerRequestCard({
    super.key,
    required this.request,
    required this.reviewed,
    required this.onCancelled,
    required this.onReviewed,
  });

  @override
  State<CustomerRequestCard> createState() => _CustomerRequestCardState();
}

class _CustomerRequestCardState extends State<CustomerRequestCard> {
  final _reviewsRepo = ReviewsRepository();
  bool _busy = false;
  bool _showReview = false;
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  String? _error;
  late bool _done = widget.reviewed;

  Future<void> _cancel() async {
    setState(() => _busy = true);
    try {
      widget.onCancelled();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitReview() async {
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      await _reviewsRepo.createReview(
        requestId: widget.request.id,
        providerId: widget.request.providerId!,
        rating: _rating,
        comment: _commentCtrl.text.trim(),
      );
      setState(() {
        _done = true;
        _showReview = false;
      });
      widget.onReviewed();
    } catch (_) {
      setState(() => _error = 'Değerlendirme kaydedilemedi.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName(r.category),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              StatusBadge(status: r.status),
            ],
          ),
          if (r.description != null && r.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              r.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, color: AppColors.mutedForeground, height: 1.4),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              if ((r.city ?? r.district) != null)
                _meta(Icons.location_on_outlined, [r.district, r.city].where((e) => e != null && e.isNotEmpty).join(', ')),
              if (r.preferredDate != null && r.preferredDate!.isNotEmpty)
                _meta(Icons.calendar_today_outlined, r.preferredDate!),
              if (r.budget != null) _meta(Icons.account_balance_wallet_outlined, '${r.budget} ₺'),
            ],
          ),
          if (r.status == 'open') ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy ? null : _cancel,
              child: const Text('Talebi iptal et'),
            ),
          ],
          if (r.status == 'completed' && !_done && !_showReview) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _showReview = true),
              child: const Text('Ustayı değerlendir'),
            ),
          ],
          if (r.status == 'completed' && _done) ...[
            const SizedBox(height: 12),
            const Text(
              'Değerlendirmen için teşekkürler.',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.chart3),
            ),
          ],
          if (_showReview) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var i = 1; i <= 5; i++)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => setState(() => _rating = i),
                          icon: Icon(
                            i <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 28,
                            color: i <= _rating ? AppColors.primary : AppColors.mutedForeground.withOpacity(0.4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Deneyimini birkaç kelimeyle anlat (opsiyonel)',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 6),
                    Text(_error!, style: const TextStyle(color: AppColors.destructive, fontSize: 13)),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _busy ? null : _submitReview,
                        child: const Text('Gönder'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => setState(() => _showReview = false),
                        child: const Text('Vazgeç'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String label) {
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
