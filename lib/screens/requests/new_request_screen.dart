import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/requests_repository.dart';
import '../../theme/app_theme.dart';

class NewRequestScreen extends StatefulWidget {
  final String? defaultCategory;
  const NewRequestScreen({super.key, this.defaultCategory});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _repo = RequestsRepository();

  late String? _category = widget.defaultCategory;
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  DateTime? _preferredDate;

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() => _error = null);
    if (_category == null || _category!.isEmpty) {
      setState(() => _error = 'Lütfen bir kategori seçin');
      return;
    }
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Lütfen kısa bir başlık girin');
      return;
    }

    setState(() => _loading = true);
    try {
      await _repo.createRequest(
        category: _category!,
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        budget: int.tryParse(_budgetCtrl.text.trim()),
        preferredDate: _preferredDate != null
            ? '${_preferredDate!.year}-${_preferredDate!.month.toString().padLeft(2, '0')}-${_preferredDate!.day.toString().padLeft(2, '0')}'
            : null,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      setState(() => _error = 'Talep oluşturulamadı. Lütfen tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Yeni usta talebi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            const Text(
              'İşini anlat, çevrendeki ustalar talebini görüp seninle iletişime geçsin.',
              style: TextStyle(fontSize: 13.5, color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 22),
            const _Label('Hizmet kategorisi'),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(hintText: 'Kategori seçin'),
              items: [for (final c in kCategories) DropdownMenuItem(value: c.slug, child: Text(c.name))],
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 16),
            const _Label('Kısa başlık'),
            TextField(
              controller: _titleCtrl,
              maxLength: 120,
              decoration: const InputDecoration(hintText: 'Örn. Salon duvarları boyanacak'),
            ),
            const _Label('İşin detayı'),
            TextField(
              controller: _descriptionCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Yapılacak işi kısaca anlatın: oda sayısı, metrekare, mevcut durum vb.',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('İl'),
                      TextField(controller: _cityCtrl, decoration: const InputDecoration(hintText: 'İstanbul')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('İlçe'),
                      TextField(controller: _districtCtrl, decoration: const InputDecoration(hintText: 'Kadıköy')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Label('Adres (opsiyonel)'),
            TextField(controller: _addressCtrl, decoration: const InputDecoration(hintText: 'Mahalle, sokak, bina no')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Telefon'),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(hintText: '05xx xxx xx xx'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Bütçe (₺)'),
                      TextField(
                        controller: _budgetCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Örn. 3000'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Label('Tercih edilen tarih (opsiyonel)'),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _preferredDate = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(),
                child: Text(
                  _preferredDate != null
                      ? '${_preferredDate!.day.toString().padLeft(2, '0')}.${_preferredDate!.month.toString().padLeft(2, '0')}.${_preferredDate!.year}'
                      : 'Tarih seçin',
                  style: TextStyle(color: _preferredDate != null ? AppColors.foreground : AppColors.mutedForeground),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!, style: const TextStyle(color: AppColors.destructive, fontSize: 13.5)),
            ],
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: Text(_loading ? 'Gönderiliyor...' : 'Talebi gönder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
