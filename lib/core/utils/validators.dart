
/// Form validation utilities
class Validators {
  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  /// Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    
    if (value.length > 50) {
      return 'Şifre en fazla 50 karakter olabilir';
    }
    
    return null;
  }

  /// Phone validation (Turkish format)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }
    
    // Remove spaces, dashes, and parentheses
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check for Turkish phone format
    final phoneRegex = RegExp(r'^(\+90|0)?5\d{9}$');
    
    if (!phoneRegex.hasMatch(cleanedPhone)) {
      return 'Geçerli bir telefon numarası girin (örn: 05XX XXX XX XX)';
    }
    
    return null;
  }

  /// Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad soyad gerekli';
    }
    
    if (value.length < 2) {
      return 'Ad soyad en az 2 karakter olmalı';
    }
    
    if (value.length > 100) {
      return 'Ad soyad en fazla 100 karakter olabilir';
    }
    
    return null;
  }

  /// Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }

  /// Number validation
  static String? validateNumber(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Sayı değeri gerekli';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Geçerli bir sayı girin';
    }
    
    if (min != null && number < min) {
      return 'Değer en az $min olmalı';
    }
    
    if (max != null && number > max) {
      return 'Değer en fazla $max olabilir';
    }
    
    return null;
  }

  /// License plate validation (Turkish format)
  static String? validateLicensePlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Plaka gerekli';
    }
    
    // Turkish license plate format: 34 ABC 123 or 34 ABC 1234
    final plateRegex = RegExp(r'^\d{2}\s?[A-Z]{1,3}\s?\d{2,4}$', caseSensitive: false);
    
    if (!plateRegex.hasMatch(value)) {
      return 'Geçerli bir plaka girin (örn: 34 ABC 123)';
    }
    
    return null;
  }

  /// Rating validation
  static String? validateRating(int? value) {
    if (value == null) {
      return 'Puan gerekli';
    }
    
    if (value < 1 || value > 5) {
      return 'Puan 1-5 arasında olmalı';
    }
    
    return null;
  }

  /// Comment length validation
  static String? validateComment(String? value, {int maxLength = 500}) {
    if (value == null || value.isEmpty) {
      return null; // Comment is optional
    }
    
    if (value.length > maxLength) {
      return 'Yorum en fazla $maxLength karakter olabilir';
    }
    
    return null;
  }
}
