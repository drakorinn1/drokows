import 'supabase_config.dart';

/// app/actions/reviews.ts dosyasındaki server action'ların karşılığı.
class ReviewsRepository {
  String get _uid => supabase.auth.currentUser!.id;

  /// Bir talebe daha önce değerlendirme yapılmış mı diye bakmak için
  /// kullanıcının tüm requestId'lerini döner (taleplerim ekranı için).
  Future<Set<int>> getMyReviewedRequestIds() async {
    final rows = await supabase.from('reviews').select('request_id').eq('user_id', _uid);
    return (rows as List)
        .map((r) => (r as Map<String, dynamic>)['request_id'] as int?)
        .whereType<int>()
        .toSet();
  }

  Future<void> createReview({
    required int requestId,
    required int providerId,
    required int rating,
    String? comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Geçerli bir puan verin (1-5)');
    }

    // İlgili talep bu kullanıcıya mı ait, bu usta tarafından tamamlanmış mı?
    final reqRows = await supabase
        .from('service_requests')
        .select()
        .eq('id', requestId)
        .eq('user_id', _uid)
        .eq('provider_id', providerId)
        .eq('status', 'completed')
        .limit(1);
    if ((reqRows as List).isEmpty) {
      throw Exception('Bu iş için değerlendirme yapamazsınız');
    }

    final existing = await supabase
        .from('reviews')
        .select('id')
        .eq('request_id', requestId)
        .eq('user_id', _uid)
        .limit(1);
    if ((existing as List).isNotEmpty) {
      throw Exception('Bu işi zaten değerlendirdiniz');
    }

    await supabase.from('reviews').insert({
      'user_id': _uid,
      'provider_id': providerId,
      'request_id': requestId,
      'rating': rating,
      'comment': comment,
    });

    // Ustanın ortalama puanını yeniden hesapla.
    final all = await supabase.from('reviews').select('rating').eq('provider_id', providerId);
    final ratings = (all as List).map((r) => (r as Map<String, dynamic>)['rating'] as int).toList();
    final count = ratings.length;
    final avg = count > 0 ? ratings.reduce((a, b) => a + b) / count : 0;

    await supabase
        .from('providers')
        .update({'avg_rating': avg, 'rating_count': count})
        .eq('id', providerId);
  }
}
