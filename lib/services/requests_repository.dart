import '../models/service_request.dart';
import 'supabase_config.dart';

/// app/actions/requests.ts dosyasındaki server action'ların karşılığı.
/// RLS (Row Level Security) politikaları supabase/schema.sql içinde
/// tanımlıdır; bu yüzden burada ekstra yetki kontrolü yapmaya gerek yoktur.
class RequestsRepository {
  String get _uid => supabase.auth.currentUser!.id;

  Future<void> createRequest({
    required String category,
    required String title,
    String? description,
    String? address,
    String? city,
    String? district,
    String? phone,
    int? budget,
    String? preferredDate,
  }) async {
    if (category.isEmpty || title.isEmpty) {
      throw Exception('Kategori ve başlık zorunludur');
    }
    final name = supabase.auth.currentUser?.userMetadata?['name'] as String?;
    await supabase.from('service_requests').insert({
      'user_id': _uid,
      'customer_name': name,
      'category': category,
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      'district': district,
      'phone': phone,
      'budget': budget,
      'preferred_date': preferredDate,
      'status': 'open',
    });
  }

  Future<List<ServiceRequest>> getMyRequests() async {
    final rows = await supabase
        .from('service_requests')
        .select()
        .eq('user_id', _uid)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((r) => ServiceRequest.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelRequest(int id) async {
    await supabase
        .from('service_requests')
        .update({'status': 'cancelled'})
        .eq('id', id)
        .eq('user_id', _uid);
  }

  // --- Usta (provider) tarafı -------------------------------------------

  /// Ustanın kendi kategorisindeki açık talepler + kendisine atanmış işler.
  Future<({List<ServiceRequest> open, List<ServiceRequest> mine})>
      getProviderJobs(int providerProfileId, String category) async {
    final openRows = await supabase
        .from('service_requests')
        .select()
        .eq('category', category)
        .eq('status', 'open')
        .order('created_at', ascending: false);

    final mineRows = await supabase
        .from('service_requests')
        .select()
        .eq('provider_id', providerProfileId)
        .order('created_at', ascending: false);

    return (
      open: (openRows as List)
          .map((r) => ServiceRequest.fromMap(r as Map<String, dynamic>))
          .toList(),
      mine: (mineRows as List)
          .map((r) => ServiceRequest.fromMap(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> acceptRequest({
    required int requestId,
    required int providerProfileId,
    required String category,
  }) async {
    await supabase
        .from('service_requests')
        .update({'status': 'assigned', 'provider_id': providerProfileId})
        .eq('id', requestId)
        .eq('status', 'open')
        .eq('category', category);
  }

  Future<void> completeJob({
    required int requestId,
    required int providerProfileId,
  }) async {
    await supabase
        .from('service_requests')
        .update({'status': 'completed'})
        .eq('id', requestId)
        .eq('provider_id', providerProfileId)
        .eq('status', 'assigned');
  }
}
