
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_state_provider.dart';
import '../data/repositories/service_request_repository.dart';
import '../domain/models/service_request.dart';
import 'location_provider.dart';

/// Service Request Repository Provider
final serviceRequestRepositoryProvider = Provider<ServiceRequestRepository>((ref) {
  return ServiceRequestRepository();
});

/// Service Request Notifier
/// Manages service request creation and state
class ServiceRequestNotifier extends StateNotifier<AsyncValue<ServiceRequest?>> {
  final ServiceRequestRepository _repository;
  final Ref _ref;
  StreamSubscription<ServiceRequest>? _subscription;

  ServiceRequestNotifier(this._repository, this._ref) 
      : super(const AsyncValue.data(null));

  /// Create a new service request
  Future<String> createServiceRequest(String serviceType, {double? quotedPrice}) async {
    try {
      state = const AsyncValue.loading();

      // Get current user
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      // Get current location
      final position = await _ref.read(currentPositionProvider.future);

      // Create service request
      final request = await _repository.createServiceRequest(
        customerId: user.id,
        serviceType: serviceType,
        customerLat: position.latitude,
        customerLng: position.longitude,
        quotedPrice: quotedPrice,
      );

      state = AsyncValue.data(request);
      
      // Start listening to updates
      _listenToUpdates(request.id);

      return request.id;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  /// Listen to service request updates via realtime subscription
  void _listenToUpdates(String requestId) {
    _subscription?.cancel();
    
    _subscription = _repository.subscribeToServiceRequest(requestId).listen(
      (request) {
        state = AsyncValue.data(request);
      },
      onError: (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      },
    );
  }

  /// Load a specific service request and listen to updates
  Future<void> loadServiceRequest(String requestId) async {
    try {
      state = const AsyncValue.loading();
      
      final request = await _repository.getServiceRequest(requestId);
      
      if (request == null) {
        throw Exception('Servis isteği bulunamadı');
      }

      state = AsyncValue.data(request);
      
      // Start listening to updates
      _listenToUpdates(requestId);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Cancel current service request
  Future<void> cancelServiceRequest() async {
    final currentRequest = state.value;
    if (currentRequest == null) return;

    try {
      await _repository.cancelServiceRequest(currentRequest.id);
      state = const AsyncValue.data(null);
      _subscription?.cancel();
    } catch (e) {
      // Error handling - you might want to show a snackbar
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Service Request Provider
/// Main provider for service request state
final serviceRequestProvider = StateNotifierProvider<ServiceRequestNotifier, AsyncValue<ServiceRequest?>>((ref) {
  return ServiceRequestNotifier(
    ref.watch(serviceRequestRepositoryProvider),
    ref,
  );
});

/// Mock Provider Data Provider
/// Fetches mock provider data when needed
final mockProviderProvider = FutureProvider.family<MockProvider?, String>((ref, providerId) async {
  final repository = ref.watch(serviceRequestRepositoryProvider);
  return await repository.getMockProvider(providerId);
});

