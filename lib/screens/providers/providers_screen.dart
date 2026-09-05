import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/provider_profile.dart';
import '../../services/providers_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/provider_card.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  final _repo = ProvidersRepository();
  String? _category;
  late Future<List<ProviderProfile>> _future = _repo.getProvidersByCategory(_category);

  void _selectCategory(String? slug) {
    setState(() {
      _category = slug;
      _future = _repo.getProvidersByCategory(_category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _selectCategory(_category),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text('Ustalar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            _category != null ? '${categoryName(_category!)} kategorisindeki ustalar' : 'Tüm kategorilerdeki ustalar',
            style: const TextStyle(fontSize: 13.5, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(label: 'Tümü', selected: _category == null, onTap: () => _selectCategory(null)),
                for (final c in kCategories)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _CategoryChip(label: c.name, selected: _category == c.slug, onTap: () => _selectCategory(c.slug)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<ProviderProfile>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(18)),
                        child: const Icon(Icons.people_outline_rounded, color: AppColors.mutedForeground, size: 30),
                      ),
                      const SizedBox(height: 16),
                      const Text('Bu kategoride henüz usta yok', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          "Sen bir usta mısın? Usta Paneli'nden profilini oluşturarak burada listelen.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [for (final p in list) Padding(padding: const EdgeInsets.only(bottom: 10), child: ProviderCard(provider: p))],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primaryForeground : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
