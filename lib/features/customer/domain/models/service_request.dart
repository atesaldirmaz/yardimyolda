
import 'package:flutter/foundation.dart';

/// Service Request Model
/// Represents a service request from the service_requests table
@immutable
class ServiceRequest {
  final String id;
  final String customerId;
  final String? providerId;
  final String serviceType; // 'Çekici', 'Akü', 'Lastik', 'Yakıt'
  final String status; // 'searching', 'matched', 'in_progress', 'completed', 'cancelled'
  final double customerLat;
  final double customerLng;
  final double? providerLat;
  final double? providerLng;
  final double? quotedPrice; // Price for the service
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceRequest({
    required this.id,
    required this.customerId,
    this.providerId,
    required this.serviceType,
    required this.status,
    required this.customerLat,
    required this.customerLng,
    this.providerLat,
    this.providerLng,
    this.quotedPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String?,
      serviceType: json['service_type'] as String,
      status: json['status'] as String,
      customerLat: (json['customer_lat'] as num).toDouble(),
      customerLng: (json['customer_lng'] as num).toDouble(),
      providerLat: json['provider_lat'] != null 
          ? (json['provider_lat'] as num).toDouble() 
          : null,
      providerLng: json['provider_lng'] != null 
          ? (json['provider_lng'] as num).toDouble() 
          : null,
      quotedPrice: json['quoted_price'] != null
          ? (json['quoted_price'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'provider_id': providerId,
      'service_type': serviceType,
      'status': status,
      'customer_lat': customerLat,
      'customer_lng': customerLng,
      'provider_lat': providerLat,
      'provider_lng': providerLng,
      'quoted_price': quotedPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Copy with
  ServiceRequest copyWith({
    String? id,
    String? customerId,
    String? providerId,
    String? serviceType,
    String? status,
    double? customerLat,
    double? customerLng,
    double? providerLat,
    double? providerLng,
    double? quotedPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      customerLat: customerLat ?? this.customerLat,
      customerLng: customerLng ?? this.customerLng,
      providerLat: providerLat ?? this.providerLat,
      providerLng: providerLng ?? this.providerLng,
      quotedPrice: quotedPrice ?? this.quotedPrice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if service is matched with a provider
  bool get isMatched => status == 'matched' && providerId != null;

  /// Check if service is still searching
  bool get isSearching => status == 'searching';
}

/// Mock Provider Model
/// Represents a mock provider from the mock_providers table
@immutable
class MockProvider {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final DateTime createdAt;

  const MockProvider({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });

  /// Create from JSON
  factory MockProvider.fromJson(Map<String, dynamic> json) {
    return MockProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

