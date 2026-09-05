import 'package:flutter/material.dart';
import '../../models/service_request.dart';
import '../../services/requests_repository.dart';
import '../../services/reviews_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/customer_request_card.dart';
import 'new_request_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final _requestsRepo = RequestsRepository();
  final _reviewsRepo = ReviewsRepository();
  late Future<({List<ServiceRequest> requests, Set<int> reviewed})> _future = _load();

  Future<({List<ServiceRequest> requests, Set<int> reviewed})> _load() async {
    final requests = await _requestsRepo.getMyRequests();
    final reviewed = await _reviewsRepo.getMyReviewedRequestIds();
    return (requests: requests, reviewed: reviewed);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _openNewRequest() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewRequestScreen()));
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Taleplerim', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ElevatedButton.icon(
                onPressed: _openNewRequest,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Yeni'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(0, 38), padding: const EdgeInsets.symmetric(horizontal: 16)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final requests = snapshot.data?.requests ?? [];
              final reviewed = snapshot.data?.reviewed ?? <int>{};

              if (requests.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(18)),
                        child: const Icon(Icons.assignment_outlined, color: AppColors.mutedForeground, size: 30),
                      ),
                      const SizedBox(height: 16),
                      const Text('Henüz talebin yok', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'İlk usta talebini oluştur, çevrendeki ustalar seninle iletişime geçsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _openNewRequest,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Talep oluştur'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(180, 44)),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  for (final r in requests)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CustomerRequestCard(
                        request: r,
                        reviewed: reviewed.contains(r.id),
                        onCancelled: () async {
                          await _requestsRepo.cancelRequest(r.id);
                          _reload();
                        },
                        onReviewed: _reload,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
