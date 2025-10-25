
/// Application-wide constants
class AppConstants {
  // App info
  static const String appName = 'Yardım Yolda';
  static const String appVersion = '1.0.0';
  
  // API & Network
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Map settings
  static const double defaultZoom = 15.0;
  static const double defaultMapPadding = 50.0;
  
  // Location settings
  static const double locationUpdateDistance = 50.0; // meters
  static const Duration locationUpdateInterval = Duration(seconds: 10);
  
  // Service request settings
  static const Duration requestTimeout = Duration(minutes: 30);
  static const double maxSearchRadius = 50.0; // kilometers
  
  // Rating settings
  static const int minStars = 1;
  static const int maxStars = 5;
  static const int maxCommentLength = 500;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minPhoneLength = 10;
  
  // Turkish locale
  static const String defaultLocale = 'tr_TR';
  static const String defaultLanguageCode = 'tr';
  static const String defaultCountryCode = 'TR';
}

/// Service types enum
enum ServiceType {
  towing('towing', 'Çekici', '🚚'),
  batteryJump('battery_jump', 'Akü Takviyesi', '🔋'),
  tireChange('tire_change', 'Lastik Değişimi', '🛞'),
  fuelDelivery('fuel_delivery', 'Yakıt İkmali', '⛽'),
  lockout('lockout', 'Kapı Açma', '🔑'),
  mechanicalRepair('mechanical_repair', 'Mekanik Onarım', '🔧');

  const ServiceType(this.value, this.label, this.emoji);

  final String value;
  final String label;
  final String emoji;
}

/// Service request status enum
enum RequestStatus {
  pending('pending', 'Beklemede', '⏳'),
  quoted('quoted', 'Teklif Verildi', '💰'),
  accepted('accepted', 'Kabul Edildi', '✅'),
  inProgress('in_progress', 'Devam Ediyor', '🚗'),
  completed('completed', 'Tamamlandı', '✅'),
  cancelled('cancelled', 'İptal Edildi', '❌'),
  rejected('rejected', 'Reddedildi', '❌');

  const RequestStatus(this.value, this.label, this.emoji);

  final String value;
  final String label;
  final String emoji;
}

/// Vehicle types enum
enum VehicleType {
  towTruck('tow_truck', 'Çekici'),
  mobileMechanic('mobile_mechanic', 'Mobil Tamirci'),
  fuelDelivery('fuel_delivery', 'Yakıt İkmal Aracı'),
  tireService('tire_service', 'Lastik Servisi');

  const VehicleType(this.value, this.label);

  final String value;
  final String label;
}

/// User roles enum
enum UserRole {
  customer('customer', 'Müşteri'),
  provider('provider', 'Hizmet Sağlayıcı'),
  admin('admin', 'Yönetici');

  const UserRole(this.value, this.label);

  final String value;
  final String label;
}
