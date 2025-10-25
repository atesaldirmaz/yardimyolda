import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/service_request.dart';
import '../../providers/service_request_provider.dart';

/// Request Tracking Screen
/// Shows real-time tracking of service request with Google Maps
class RequestTrackingScreen extends ConsumerStatefulWidget {
  final String requestId;

  const RequestTrackingScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<RequestTrackingScreen> createState() => _RequestTrackingScreenState();
}

class _RequestTrackingScreenState extends ConsumerState<RequestTrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Load service request
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceRequestProvider.notifier).loadServiceRequest(widget.requestId);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// Update map markers based on service request state
  void _updateMarkers(ServiceRequest request, MockProvider? provider) {
    _markers.clear();

    // Add customer marker
    _markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: LatLng(request.customerLat, request.customerLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'Konumunuz',
          snippet: 'Yardım istediğiniz konum',
        ),
      ),
    );

    // Add provider marker if matched
    if (request.isMatched && provider != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('provider'),
          position: LatLng(provider.lat, provider.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: provider.name,
            snippet: 'Servis sağlayıcı',
          ),
        ),
      );

      // Animate camera to show both markers
      _animateCameraToShowBothMarkers(
        request.customerLat,
        request.customerLng,
        provider.lat,
        provider.lng,
      );
    } else {
      // Center on customer location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(request.customerLat, request.customerLng),
          15,
        ),
      );
    }
  }

  /// Animate camera to show both customer and provider markers
  void _animateCameraToShowBothMarkers(
    double customerLat,
    double customerLng,
    double providerLat,
    double providerLng,
  ) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        customerLat < providerLat ? customerLat : providerLat,
        customerLng < providerLng ? customerLng : providerLng,
      ),
      northeast: LatLng(
        customerLat > providerLat ? customerLat : providerLat,
        customerLng > providerLng ? customerLng : providerLng,
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  /// Get status text based on service request status
  String _getStatusText(String status) {
    switch (status) {
      case 'searching':
        return 'Eşleştiriliyor...';
      case 'matched':
        return 'Aracınız yola çıktı';
      case 'in_progress':
        return 'Servis devam ediyor';
      case 'completed':
        return 'Servis tamamlandı';
      case 'cancelled':
        return 'Servis iptal edildi';
      default:
        return 'Durum belirsiz';
    }
  }

  /// Get status color based on service request status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'searching':
        return Colors.orange;
      case 'matched':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(serviceRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Servis Takibi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Servisi İptal Et'),
                  content: const Text('Servis isteğinizi iptal etmek istediğinize emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hayır'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await ref.read(serviceRequestProvider.notifier).cancelServiceRequest();
                          if (context.mounted) {
                            context.go('/customer/dashboard');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('İptal edilemedi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Evet'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: requestAsync.when(
        data: (request) {
          if (request == null) {
            return const Center(
              child: Text('Servis isteği bulunamadı'),
            );
          }

          // Fetch provider data if matched
          final providerAsync = request.isMatched && request.providerId != null
              ? ref.watch(mockProviderProvider(request.providerId!))
              : null;

          // Update markers whenever request or provider changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (providerAsync != null) {
              providerAsync.whenData((provider) {
                _updateMarkers(request, provider);
              });
            } else {
              _updateMarkers(request, null);
            }
          });

          return Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(request.customerLat, request.customerLng),
                  zoom: 15,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  _updateMarkers(request, null);
                },
              ),

              // Status Card at the top
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(request.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (request.isSearching)
                                    const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  if (request.isSearching) const SizedBox(width: 8),
                                  Text(
                                    _getStatusText(request.status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              _getServiceIcon(request.serviceType),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),

                        // Service type
                        Text(
                          request.serviceType,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Additional info
                        Text(
                          request.isMatched
                              ? 'Servis sağlayıcı yola çıktı'
                              : 'Size en yakın yardım ekibi aranıyor...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),

                        // Provider info if matched
                        if (request.isMatched && providerAsync != null)
                          providerAsync.when(
                            data: (provider) {
                              if (provider == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      child: const Icon(Icons.person, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          provider.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Servis Sağlayıcı',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 24),
                Text(
                  'Hata Oluştu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(serviceRequestProvider.notifier).loadServiceRequest(widget.requestId);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get icon for service type
  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'Çekici':
        return Icons.local_shipping;
      case 'Akü':
        return Icons.battery_charging_full;
      case 'Lastik':
        return Icons.tire_repair;
      case 'Yakıt':
        return Icons.local_gas_station;
      default:
        return Icons.car_repair;
    }
  }
}
