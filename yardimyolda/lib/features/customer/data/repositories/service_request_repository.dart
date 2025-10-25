
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../main.dart';
import '../../domain/models/service_request.dart';

/// Service Request Repository
/// Handles all service request related operations with Supabase
class ServiceRequestRepository {
  final SupabaseClient _client;

  ServiceRequestRepository({SupabaseClient? client}) 
      : _client = client ?? supabase;

  /// Create a new service request
  Future<ServiceRequest> createServiceRequest({
    required String customerId,
    required String serviceType,
    required double customerLat,
    required double customerLng,
    double? quotedPrice,
  }) async {
    try {
      final response = await _client
          .from('service_requests')
          .insert({
            'customer_id': customerId,
            'service_type': serviceType,
            'status': 'searching',
            'customer_lat': customerLat,
            'customer_lng': customerLng,
            'quoted_price': quotedPrice,
          })
          .select()
          .single();

      return ServiceRequest.fromJson(response);
    } catch (e) {
      throw Exception('Servis isteği oluşturulamadı: $e');
    }
  }

  /// Get a service request by ID
  Future<ServiceRequest?> getServiceRequest(String requestId) async {
    try {
      final response = await _client
          .from('service_requests')
          .select()
          .eq('id', requestId)
          .maybeSingle();

      if (response == null) return null;
      
      return ServiceRequest.fromJson(response);
    } catch (e) {
      throw Exception('Servis isteği alınamadı: $e');
    }
  }

  /// Get all service requests for a customer
  Future<List<ServiceRequest>> getCustomerServiceRequests(String customerId) async {
    try {
      final response = await _client
          .from('service_requests')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ServiceRequest.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Servis istekleri alınamadı: $e');
    }
  }

  /// Subscribe to service request updates
  /// Returns a stream of service request updates
  Stream<ServiceRequest> subscribeToServiceRequest(String requestId) {
    return _client
        .from('service_requests')
        .stream(primaryKey: ['id'])
        .eq('id', requestId)
        .map((data) {
          if (data.isEmpty) {
            throw Exception('Servis isteği bulunamadı');
          }
          return ServiceRequest.fromJson(data.first);
        });
  }

  /// Get mock provider by ID
  Future<MockProvider?> getMockProvider(String providerId) async {
    try {
      final response = await _client
          .from('mock_providers')
          .select()
          .eq('id', providerId)
          .maybeSingle();

      if (response == null) return null;
      
      return MockProvider.fromJson(response);
    } catch (e) {
      throw Exception('Servis sağlayıcı bilgisi alınamadı: $e');
    }
  }

  /// Cancel a service request
  Future<void> cancelServiceRequest(String requestId) async {
    try {
      await _client
          .from('service_requests')
          .update({'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', requestId);
    } catch (e) {
      throw Exception('Servis isteği iptal edilemedi: $e');
    }
  }

  /// Complete payment for a service request
  Future<void> completePayment(String requestId) async {
    try {
      await _client
          .from('service_requests')
          .update({
            'status': 'completed',
            'updated_at': DateTime.now().toIso8601String(),
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);
    } catch (e) {
      throw Exception('Ödeme tamamlanamadı: $e');
    }
  }
}

