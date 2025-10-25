
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/location_provider.dart';
import '../../providers/service_request_provider.dart';

/// Service Selection Screen
/// Allows customer to select service type and creates a service request
class ServiceSelectScreen extends ConsumerStatefulWidget {
  const ServiceSelectScreen({super.key});

  @override
  ConsumerState<ServiceSelectScreen> createState() => _ServiceSelectScreenState();
}

class _ServiceSelectScreenState extends ConsumerState<ServiceSelectScreen> {
  bool _isCreatingRequest = false;

  // Service types with prices
  final List<ServiceTypeOption> _serviceTypes = [
    ServiceTypeOption(
      type: 'Çekici',
      icon: Icons.local_shipping,
      description: 'Araç çekici hizmeti',
      color: Colors.blue,
      price: 500.0,
    ),
    ServiceTypeOption(
      type: 'Akü',
      icon: Icons.battery_charging_full,
      description: 'Akü takviye hizmeti',
      color: Colors.green,
      price: 300.0,
    ),
    ServiceTypeOption(
      type: 'Lastik',
      icon: Icons.tire_repair,
      description: 'Lastik değişim hizmeti',
      color: Colors.orange,
      price: 250.0,
    ),
    ServiceTypeOption(
      type: 'Yakıt',
      icon: Icons.local_gas_station,
      description: 'Yakıt ikmali hizmeti',
      color: Colors.red,
      price: 200.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Request location permission on screen load
    _requestLocationPermission();
  }

  /// Request location permission
  Future<void> _requestLocationPermission() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      await locationService.requestPermission();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konum izni alınamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle service type selection
  Future<void> _onServiceTypeSelected(ServiceTypeOption serviceOption) async {
    if (_isCreatingRequest) return;

    setState(() {
      _isCreatingRequest = true;
    });

    try {
      // Create service request with quoted price
      final requestId = await ref
          .read(serviceRequestProvider.notifier)
          .createServiceRequest(
            serviceOption.type,
            quotedPrice: serviceOption.price,
          );

      if (mounted) {
        // Navigate to payment screen
        context.go('/customer/payment/$requestId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İstek oluşturulamadı: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        setState(() {
          _isCreatingRequest = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch location permission status
    final locationAsync = ref.watch(currentPositionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hizmet Seçin'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isCreatingRequest
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 24),
                    Text(
                      'İstek oluşturuluyor...',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            : locationAsync.when(
                data: (_) => _buildServiceSelection(),
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 24),
                      Text(
                        'Konum alınıyor...',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Konum Alınamadı',
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
                            ref.invalidate(currentPositionProvider);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Hangi hizmete ihtiyacınız var?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bir hizmet seçin ve size en yakın yardım ekibini gönderelim.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Service Type Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemCount: _serviceTypes.length,
              itemBuilder: (context, index) {
                final service = _serviceTypes[index];
                return _ServiceTypeCard(
                  service: service,
                  onTap: () => _onServiceTypeSelected(service),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Service Type Option Model
class ServiceTypeOption {
  final String type;
  final IconData icon;
  final String description;
  final Color color;
  final double price;

  ServiceTypeOption({
    required this.type,
    required this.icon,
    required this.description,
    required this.color,
    required this.price,
  });
}

/// Service Type Card Widget
class _ServiceTypeCard extends StatelessWidget {
  final ServiceTypeOption service;
  final VoidCallback onTap;

  const _ServiceTypeCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                service.color.withOpacity(0.1),
                service.color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: service.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  service.icon,
                  size: 40,
                  color: service.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                service.type,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: service.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                service.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: service.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${service.price.toStringAsFixed(0)} ₺',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: service.color,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

