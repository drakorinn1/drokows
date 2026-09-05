import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/provider_profile.dart';
import '../../models/service_request.dart';
import '../../services/providers_repository.dart';
import '../../services/requests_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_badge.dart';

/// Not: Orijinal v0 (Next.js) projesinde /usta sayfası için arayüz henüz
/// oluşturulmamıştı, sadece navigasyon linki ve gerekli server action'lar
/// (createProviderProfile, getProviderJobs, acceptRequest, completeJob)
/// vardı. Bu ekran o eksik arayüzü Flutter tarafında tamamlar.
class UstaPanelScreen extends StatefulWidget {
  const UstaPanelScreen({super.key});

  @override
  State<UstaPanelScreen> createState() => _UstaPanelScreenState();
}

class _UstaPanelScreenState extends State<UstaPanelScreen> {
  final _providersRepo = ProvidersRepository();
  final _requestsRepo = RequestsRepository();

  late Future<ProviderProfile?> _profileFuture = _providersRepo.getMyProviderProfile();

  void _reload() => setState(() => _profileFuture = _providersRepo.getMyProviderProfile());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: FutureBuilder<ProviderProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
          if (profile == null) {
            return _CreateProfileForm(onCreated: _reload);
          }
          return _ProviderJobsView(profile: profile, requestsRepo: _requestsRepo, onChanged: _reload);
        },
      ),
    );
  }
}

class _CreateProfileForm extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateProfileForm({required this.onCreated});

  @override
  State<_CreateProfileForm> createState() => _CreateProfileFormState();
}

class _CreateProfileFormState extends State<_CreateProfileForm> {
  final _repo = ProvidersRepository();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  String? _category;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _category == null) {
      setState(() => _error = 'İsim ve kategori zorunludur');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.upsertProviderProfile(
        displayName: _nameCtrl.text.trim(),
        category: _category!,
        phone: _phoneCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        hourlyRate: int.tryParse(_rateCtrl.text.trim()),
      );
      widget.onCreated();
    } catch (_) {
      setState(() => _error = 'Profil kaydedilemedi. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        const Text('Usta Paneli', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text(
          'Müşterilerin görebilmesi için önce bir usta profili oluştur.',
          style: TextStyle(fontSize: 13.5, color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 20),
        const Text('Ad Soyad / İşletme adı', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Örn. Mehmet Usta')),
        const SizedBox(height: 14),
        const Text('Hizmet kategorisi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _category,
          decoration: const InputDecoration(hintText: 'Kategori seçin'),
          items: [for (final c in kCategories) DropdownMenuItem(value: c.slug, child: Text(c.name))],
          onChanged: (v) => setState(() => _category = v),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('İl', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(controller: _cityCtrl, decoration: const InputDecoration(hintText: 'İstanbul')),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('İlçe', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(controller: _districtCtrl, decoration: const InputDecoration(hintText: 'Kadıköy')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Telefon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '05xx xxx xx xx')),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saatlik ücret (₺)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(controller: _rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Örn. 400')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text('Kısa tanıtım', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(controller: _bioCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Deneyimin, uzmanlık alanların vb.')),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppColors.destructive, fontSize: 13.5)),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: Text(_loading ? 'Kaydediliyor...' : 'Usta olarak katıl'),
        ),
      ],
    );
  }
}

class _ProviderJobsView extends StatefulWidget {
  final ProviderProfile profile;
  final RequestsRepository requestsRepo;
  final VoidCallback onChanged;

  const _ProviderJobsView({required this.profile, required this.requestsRepo, required this.onChanged});

  @override
  State<_ProviderJobsView> createState() => _ProviderJobsViewState();
}

class _ProviderJobsViewState extends State<_ProviderJobsView> with SingleTickerProviderStateMixin {
  late Future<({List<ServiceRequest> open, List<ServiceRequest> mine})> _future = _load();

  Future<({List<ServiceRequest> open, List<ServiceRequest> mine})> _load() {
    return widget.requestsRepo.getProviderJobs(widget.profile.id, widget.profile.category);
  }

  Future<void> _accept(ServiceRequest r) async {
    await widget.requestsRepo.acceptRequest(requestId: r.id, providerProfileId: widget.profile.id, category: widget.profile.category);
    setState(() => _future = _load());
  }

  Future<void> _complete(ServiceRequest r) async {
    await widget.requestsRepo.completeJob(requestId: r.id, providerProfileId: widget.profile.id);
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.profile.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(categoryName(widget.profile.category), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const TabBar(tabs: [Tab(text: 'Açık talepler'), Tab(text: 'İşlerim')], labelColor: AppColors.primary, unselectedLabelColor: AppColors.mutedForeground, indicatorColor: AppColors.primary),
          Expanded(
            child: FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final open = snapshot.data?.open ?? [];
                final mine = snapshot.data?.mine ?? [];
                return TabBarView(
                  children: [
                    _JobList(
                      requests: open,
                      emptyText: 'Şu anda kategorinde açık talep yok.',
                      actionBuilder: (r) => ElevatedButton(onPressed: () => _accept(r), child: const Text('Talebi üstlen')),
                    ),
                    _JobList(
                      requests: mine,
                      emptyText: 'Henüz üstlendiğin bir iş yok.',
                      actionBuilder: (r) => r.status == 'assigned'
                          ? OutlinedButton(onPressed: () => _complete(r), child: const Text('İşi tamamla'))
                          : null,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _JobList extends StatelessWidget {
  final List<ServiceRequest> requests;
  final String emptyText;
  final Widget? Function(ServiceRequest) actionBuilder;

  const _JobList({required this.requests, required this.emptyText, required this.actionBuilder});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(emptyText, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.mutedForeground)),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        for (final r in requests)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700))),
                    StatusBadge(status: r.status),
                  ],
                ),
                if (r.description != null && r.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(r.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                ],
                if ((r.city ?? r.district) != null) ...[
                  const SizedBox(height: 6),
                  Text([r.district, r.city].where((e) => e != null && e.isNotEmpty).join(', '), style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                ],
                if (actionBuilder(r) != null) ...[
                  const SizedBox(height: 10),
                  actionBuilder(r)!,
                ],
              ],
            ),
          ),
      ],
    );
  }
}
