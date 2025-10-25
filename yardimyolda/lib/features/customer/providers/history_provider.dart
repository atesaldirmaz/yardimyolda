
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_state_provider.dart';
import '../data/repositories/service_request_repository.dart';
import '../domain/models/service_request.dart';
import 'service_request_provider.dart';

/// Service Request History Provider
/// Fetches and manages customer's service request history
final serviceRequestHistoryProvider = FutureProvider.autoDispose<List<ServiceRequest>>((ref) async {
  // Get current user
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('Kullanıcı bulunamadı');
  }

  // Get repository
  final repository = ref.watch(serviceRequestRepositoryProvider);

  // Fetch service requests for the current user
  return await repository.getCustomerServiceRequests(user.id);
});

/// Provider to manually refresh history
final refreshHistoryProvider = StateProvider<int>((ref) => 0);

/// History Provider with manual refresh capability
final serviceRequestHistoryWithRefreshProvider = FutureProvider.autoDispose<List<ServiceRequest>>((ref) async {
  // Watch refresh trigger
  ref.watch(refreshHistoryProvider);
  
  // Get current user
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw Exception('Kullanıcı bulunamadı');
  }

  // Get repository
  final repository = ref.watch(serviceRequestRepositoryProvider);

  // Fetch service requests for the current user
  return await repository.getCustomerServiceRequests(user.id);
});
