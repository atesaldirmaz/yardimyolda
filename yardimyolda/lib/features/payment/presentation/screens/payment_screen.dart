import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../customer/providers/service_request_provider.dart';
import '../../../customer/data/repositories/service_request_repository.dart';

/// Payment Screen
/// Displays service request details and mock payment form
class PaymentScreen extends ConsumerStatefulWidget {
  final String requestId;

  const PaymentScreen({
    super.key,
    required this.requestId,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Load service request details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceRequestProvider.notifier).loadServiceRequest(widget.requestId);
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  /// Format card number as user types (XXXX XXXX XXXX XXXX)
  String _formatCardNumber(String value) {
    // Remove all spaces
    final cleanValue = value.replaceAll(' ', '');
    
    // Add space every 4 digits
    final buffer = StringBuffer();
    for (int i = 0; i < cleanValue.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanValue[i]);
    }
    
    return buffer.toString();
  }

  /// Format expiry date as user types (MM/YY)
  String _formatExpiryDate(String value) {
    // Remove all slashes
    final cleanValue = value.replaceAll('/', '');
    
    // Add slash after 2 digits
    if (cleanValue.length > 2) {
      return '${cleanValue.substring(0, 2)}/${cleanValue.substring(2)}';
    }
    
    return cleanValue;
  }

  /// Validate card number (simple check for 16 digits)
  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kart numarası gereklidir';
    }
    
    final cleanValue = value.replaceAll(' ', '');
    if (cleanValue.length != 16) {
      return 'Kart numarası 16 haneli olmalıdır';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(cleanValue)) {
      return 'Sadece rakam giriniz';
    }
    
    return null;
  }

  /// Validate expiry date (MM/YY format)
  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Son kullanma tarihi gereklidir';
    }
    
    final cleanValue = value.replaceAll('/', '');
    if (cleanValue.length != 4) {
      return 'Geçerli bir tarih giriniz (AA/YY)';
    }
    
    final month = int.tryParse(cleanValue.substring(0, 2));
    final year = int.tryParse(cleanValue.substring(2, 4));
    
    if (month == null || year == null) {
      return 'Geçerli bir tarih giriniz';
    }
    
    if (month < 1 || month > 12) {
      return 'Geçersiz ay (01-12)';
    }
    
    // Check if date is in the future
    final now = DateTime.now();
    final currentYear = now.year % 100; // Get last 2 digits
    final currentMonth = now.month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Kartın süresi dolmuş';
    }
    
    return null;
  }

  /// Validate CVV (3 digits)
  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV gereklidir';
    }
    
    if (value.length != 3) {
      return 'CVV 3 haneli olmalıdır';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Sadece rakam giriniz';
    }
    
    return null;
  }

  /// Handle payment completion
  Future<void> _handlePayment() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));

      // Update service request status to completed
      final repository = ref.read(serviceRequestRepositoryProvider);
      await repository.completePayment(widget.requestId);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Talebiniz tamamlandı.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a bit for the user to see the message
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to history
        if (mounted) {
          context.go('/customer/history');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme işlemi başarısız: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Get service type display name
  String _getServiceTypeDisplayName(String serviceType) {
    // Handle both Turkish and English service types
    final lowercaseType = serviceType.toLowerCase();
    
    switch (lowercaseType) {
      case 'çekici':
      case 'towing':
        return 'Çekici';
      case 'akü':
      case 'battery_jump':
        return 'Akü';
      case 'lastik':
      case 'tire_change':
        return 'Lastik';
      case 'yakıt':
      case 'fuel_delivery':
        return 'Yakıt';
      default:
        return serviceType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceRequestAsync = ref.watch(serviceRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: serviceRequestAsync.when(
        data: (serviceRequest) {
          if (serviceRequest == null) {
            return const Center(
              child: Text('Servis isteği bulunamadı'),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Service Details Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hizmet Detayları',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hizmet Türü:',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _getServiceTypeDisplayName(serviceRequest.serviceType),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fiyat:',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${serviceRequest.quotedPrice?.toStringAsFixed(0) ?? "0"} ₺',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Payment Form
                  Text(
                    'Ödeme Bilgileri',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Card Number Field
                        TextFormField(
                          controller: _cardNumberController,
                          decoration: InputDecoration(
                            labelText: 'Kart Numarası',
                            hintText: '1234 5678 9012 3456',
                            prefixIcon: const Icon(Icons.credit_card),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                          ],
                          onChanged: (value) {
                            final formatted = _formatCardNumber(value);
                            if (formatted != value) {
                              _cardNumberController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                  offset: formatted.length,
                                ),
                              );
                            }
                          },
                          validator: _validateCardNumber,
                        ),
                        const SizedBox(height: 16),

                        // Expiry Date and CVV Row
                        Row(
                          children: [
                            // Expiry Date Field
                            Expanded(
                              child: TextFormField(
                                controller: _expiryController,
                                decoration: InputDecoration(
                                  labelText: 'Son Kullanma Tarihi',
                                  hintText: 'AA/YY',
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                onChanged: (value) {
                                  final formatted = _formatExpiryDate(value);
                                  if (formatted != value) {
                                    _expiryController.value = TextEditingValue(
                                      text: formatted,
                                      selection: TextSelection.collapsed(
                                        offset: formatted.length,
                                      ),
                                    );
                                  }
                                },
                                validator: _validateExpiryDate,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // CVV Field
                            Expanded(
                              child: TextFormField(
                                controller: _cvvController,
                                decoration: InputDecoration(
                                  labelText: 'CVV',
                                  hintText: '123',
                                  prefixIcon: const Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                                validator: _validateCvv,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Payment Button
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _handlePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Ödemeyi Tamamla',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Test Card Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Test Ödeme Bilgisi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bu bir test ödeme ekranıdır. Herhangi bir 16 haneli kart numarası, gelecekteki bir tarih ve 3 haneli CVV kullanabilirsiniz.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hata Oluştu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/customer/dashboard'),
                  icon: const Icon(Icons.home),
                  label: const Text('Ana Sayfaya Dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
