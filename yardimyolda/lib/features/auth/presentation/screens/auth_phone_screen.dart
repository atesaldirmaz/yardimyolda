import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_state_provider.dart';

/// Phone Authentication Screen
/// First step in phone verification flow
/// User enters their phone number to receive SMS OTP
class AuthPhoneScreen extends ConsumerStatefulWidget {
  const AuthPhoneScreen({super.key});

  @override
  ConsumerState<AuthPhoneScreen> createState() => _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends ConsumerState<AuthPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Format phone number with Turkish format
  String _formatPhoneNumber(String phone) {
    // Remove all non-numeric characters
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Ensure it starts with +90 for Turkey
    if (!phone.startsWith('+90')) {
      if (phone.startsWith('90')) {
        phone = '+$phone';
      } else if (phone.startsWith('0')) {
        phone = '+9${phone}';
      } else {
        phone = '+90$phone';
      }
    }
    
    return phone;
  }

  /// Validate Turkish phone number
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }

    // Remove spaces and special characters for validation
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Turkish phone (should be 11 digits: 0 + 10 digits)
    if (cleaned.length == 11 && cleaned.startsWith('0')) {
      return null;
    } else if (cleaned.length == 10) {
      return null;
    } else if (cleaned.length == 12 && cleaned.startsWith('90')) {
      return null;
    }

    return 'Geçerli bir telefon numarası girin (örn: 05XX XXX XX XX)';
  }

  /// Send OTP to phone number
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Format phone number
      final formattedPhone = _formatPhoneNumber(_phoneController.text);

      // Send OTP via auth provider
      await ref.read(authStateProvider.notifier).sendOTP(formattedPhone);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doğrulama kodu gönderildi'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to OTP verification screen
      context.push('/auth/verify', extra: formattedPhone);
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo
                  Icon(
                    Icons.car_repair,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Yardım Yolda',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yol yardım hizmeti',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Instruction text
                  Text(
                    'Telefon numaranı gir',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Size SMS ile bir doğrulama kodu göndereceğiz',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Phone number input
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    autofocus: true,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Telefon Numarası',
                      hintText: '05XX XXX XX XX',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      prefixText: '+90 ',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                      _PhoneNumberFormatter(),
                    ],
                    validator: _validatePhone,
                    onFieldSubmitted: (_) => _sendOTP(),
                  ),
                  const SizedBox(height: 32),

                  // Send OTP button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Doğrulama Kodu Gönder',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Privacy notice
                  Text(
                    'Devam ederek Gizlilik Politikası ve Kullanım Koşullarını kabul etmiş olursunuz',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Phone Number Formatter
/// Formats phone number as user types (5XX XXX XX XX)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      
      // Add space after 3rd, 6th, and 8th digits
      if ((i == 2 || i == 5 || i == 7) && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
