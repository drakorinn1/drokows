import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../models/service_request.dart';
import '../../services/requests_repository.dart';
import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/status_badge.dart';
import '../requests/new_request_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onGoToProviders;
  final VoidCallback? onGoToRequests;

  const HomeScreen({super.key, this.onGoToProviders, this.onGoToRequests});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = RequestsRepository();
  late Future<List<ServiceRequest>> _future = _repo.getMyRequests();

  void _reload() => setState(() => _future = _repo.getMyRequests());

  void _openNewRequest([String? category]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NewRequestScreen(defaultCategory: category)),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthState>().displayName?.split(' ').first ?? '';

    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('Merhaba $name,', style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13.5)),
          const SizedBox(height: 2),
          const Text(
            'Bugün hangi iş için usta lazım?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openNewRequest(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryForeground.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.primaryForeground, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Yeni talep oluştur',
                            style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.w800, fontSize: 15.5)),
                        Text('Ücretsiz, dakikalar içinde teklif al',
                            style: TextStyle(color: AppColors.primaryForeground.withOpacity(0.8), fontSize: 12.5)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.primaryForeground),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: _FeatureChip(icon: Icons.verified_user_outlined, label: 'Doğrulanmış ustalar')),
              SizedBox(width: 8),
              Expanded(child: _FeatureChip(icon: Icons.schedule_rounded, label: 'Hızlı dönüş')),
              SizedBox(width: 8),
              Expanded(child: _FeatureChip(icon: Icons.thumb_up_outlined, label: 'Puanlı değerlendirme')),
            ],
          ),
          FutureBuilder<List<ServiceRequest>>(
            future: _future,
            builder: (context, snapshot) {
              final requests = snapshot.data ?? [];
              final active = requests.where((r) => r.status == 'open' || r.status == 'assigned').take(2).toList();
              if (active.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Aktif taleplerin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                        TextButton(onPressed: widget.onGoToRequests, child: const Text('Tümü')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...active.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: widget.onGoToRequests,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                      const SizedBox(height: 2),
                                      Text(categoryName(r.category), style: const TextStyle(fontSize: 11.5, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: r.status),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 26, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hizmet kategorileri', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
                TextButton(onPressed: widget.onGoToProviders, child: const Text('Ustalara göz at')),
              ],
            ),
          ),
          CategoryGrid(onTap: (slug) => _openNewRequest(slug)),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
