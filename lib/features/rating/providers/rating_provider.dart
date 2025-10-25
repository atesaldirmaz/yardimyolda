
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_state_provider.dart';
import '../../customer/data/repositories/service_request_repository.dart';
import '../../customer/providers/service_request_provider.dart';
import '../data/repositories/rating_repository.dart';
import '../domain/models/rating.dart';

/// Rating Repository Provider
final ratingRepositoryProvider = Provider<RatingRepository>((ref) {
  return RatingRepository();
});

/// Rating Submission State
class RatingSubmissionState {
  final bool isLoading;
  final String? error;
  final Rating? rating;

  const RatingSubmissionState({
    this.isLoading = false,
    this.error,
    this.rating,
  });

  RatingSubmissionState copyWith({
    bool? isLoading,
    String? error,
    Rating? rating,
  }) {
    return RatingSubmissionState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      rating: rating ?? this.rating,
    );
  }
}

/// Rating Submission Notifier
/// Manages rating submission state
class RatingSubmissionNotifier extends StateNotifier<RatingSubmissionState> {
  final RatingRepository _ratingRepository;
  final ServiceRequestRepository _serviceRequestRepository;
  final Ref _ref;

  RatingSubmissionNotifier(
    this._ratingRepository,
    this._serviceRequestRepository,
    this._ref,
  ) : super(const RatingSubmissionState());

  /// Submit a rating for a service request
  Future<bool> submitRating({
    required String requestId,
    required int rating,
    String? comment,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get current user
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      // Get service request to get provider_id
      final serviceRequest = await _serviceRequestRepository.getServiceRequest(requestId);
      if (serviceRequest == null) {
        throw Exception('Servis isteği bulunamadı');
      }

      if (serviceRequest.providerId == null) {
        throw Exception('Bu talep için sağlayıcı bulunamadı');
      }

      // Submit rating
      final submittedRating = await _ratingRepository.submitRating(
        requestId: requestId,
        customerId: user.id,
        providerId: serviceRequest.providerId!,
        rating: rating,
        comment: comment,
      );

      state = state.copyWith(
        isLoading: false,
        rating: submittedRating,
        error: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Reset state
  void reset() {
    state = const RatingSubmissionState();
  }
}

/// Rating Submission Provider
/// Main provider for rating submission
final ratingSubmissionProvider = StateNotifierProvider.autoDispose<RatingSubmissionNotifier, RatingSubmissionState>((ref) {
  return RatingSubmissionNotifier(
    ref.watch(ratingRepositoryProvider),
    ref.watch(serviceRequestRepositoryProvider),
    ref,
  );
});

/// Provider to check if a request has been rated
final isRequestRatedProvider = FutureProvider.family.autoDispose<bool, String>((ref, requestId) async {
  final repository = ref.watch(ratingRepositoryProvider);
  return await repository.isRequestRated(requestId);
});

/// Provider to get rating for a specific request
final requestRatingProvider = FutureProvider.family.autoDispose<Rating?, String>((ref, requestId) async {
  final repository = ref.watch(ratingRepositoryProvider);
  return await repository.getRatingForRequest(requestId);
});
