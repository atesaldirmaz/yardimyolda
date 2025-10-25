
import 'package:flutter/foundation.dart';

/// Rating Model
/// Represents a rating from the ratings table
@immutable
class Rating {
  final String id;
  final String requestId;
  final String customerId;
  final String providerId;
  final int stars; // 1-5
  final String? comment;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.providerId,
    required this.stars,
    this.comment,
    required this.createdAt,
  });

  /// Create from JSON
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      stars: json['stars'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'customer_id': customerId,
      'provider_id': providerId,
      'stars': stars,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Copy with
  Rating copyWith({
    String? id,
    String? requestId,
    String? customerId,
    String? providerId,
    int? stars,
    String? comment,
    DateTime? createdAt,
  }) {
    return Rating(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      stars: stars ?? this.stars,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
