import '../models/provider_profile.dart';
import 'supabase_config.dart';

/// app/actions/providers.ts dosyasındaki server action'ların karşılığı.
class ProvidersRepository {
  String get _uid => supabase.auth.currentUser!.id;

  Future<ProviderProfile?> getMyProviderProfile() async {
    final rows = await supabase
        .from('providers')
        .select()
        .eq('user_id', _uid)
        .limit(1);
    final list = rows as List;
    if (list.isEmpty) return null;
    return ProviderProfile.fromMap(list.first as Map<String, dynamic>);
  }

  Future<void> upsertProviderProfile({
    required String displayName,
    required String category,
    String? phone,
    String? city,
    String? district,
    String? bio,
    int? hourlyRate,
  }) async {
    if (displayName.isEmpty || category.isEmpty) {
      throw Exception('İsim ve kategori zorunludur');
    }

    final data = {
      'user_id': _uid,
      'display_name': displayName,
      'category': category,
      'phone': phone,
      'city': city,
      'district': district,
      'bio': bio,
      'hourly_rate': hourlyRate,
    };

    // upsert işlemi ile güncelleme/eklemeyi tek adımda ve çökmeden güvenle yapıyoruz
    await supabase.from('providers').upsert(
      data,
      onConflict: 'user_id', // user_id çakışırsa güncelle, yoksa ekle
    );
  }

  /// Müşteri tarafındaki usta dizini (herkese açık okuma).
  Future<List<ProviderProfile>> getProvidersByCategory(String? category) async {
    var query = supabase.from('providers').select();
    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }
    final rows = await query
        .order('avg_rating', ascending: false)
        .order('jobs_completed', ascending: false);
    return (rows as List)
        .map((r) => ProviderProfile.fromMap(r as Map<String, dynamic>))
        .toList();
  }
}