
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../main.dart';
import '../../domain/models/rating.dart';

/// Rating Repository
/// Handles all rating related operations with Supabase
class RatingRepository {
  final SupabaseClient _client;

  RatingRepository({SupabaseClient? client}) 
      : _client = client ?? supabase;

  /// Submit a new rating for a completed service request
  Future<Rating> submitRating({
    required String requestId,
    required String customerId,
    required String providerId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _client
          .from('ratings')
          .insert({
            'request_id': requestId,
            'customer_id': customerId,
            'provider_id': providerId,
            'stars': rating,
            'comment': comment,
          })
          .select()
          .single();

      return Rating.fromJson(response);
    } on PostgrestException catch (e) {
      // Handle unique constraint violation (already rated)
      if (e.code == '23505') {
        throw Exception('Bu talep zaten değerlendirildi.');
      }
      throw Exception('Değerlendirme gönderilemedi: ${e.message}');
    } catch (e) {
      throw Exception('Değerlendirme gönderilemedi: $e');
    }
  }

  /// Get rating for a specific request
  Future<Rating?> getRatingForRequest(String requestId) async {
    try {
      final response = await _client
          .from('ratings')
          .select()
          .eq('request_id', requestId)
          .maybeSingle();

      if (response == null) return null;
      
      return Rating.fromJson(response);
    } catch (e) {
      throw Exception('Değerlendirme alınamadı: $e');
    }
  }

  /// Get all ratings for a specific provider
  Future<List<Rating>> getProviderRatings(String providerId) async {
    try {
      final response = await _client
          .from('ratings')
          .select()
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Rating.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Değerlendirmeler alınamadı: $e');
    }
  }

  /// Get all ratings by a specific customer
  Future<List<Rating>> getCustomerRatings(String customerId) async {
    try {
      final response = await _client
          .from('ratings')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Rating.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Değerlendirmeler alınamadı: $e');
    }
  }

  /// Check if a request has been rated
  Future<bool> isRequestRated(String requestId) async {
    try {
      final response = await _client
          .from('ratings')
          .select('id')
          .eq('request_id', requestId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
