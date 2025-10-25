# App Icon Klasörü

Bu klasör, uygulamanın launcher icon'unu (ana ekrandaki uygulama simgesi) içerir.

## 📋 Gereksinimler

Uygulama ikonu için aşağıdaki özelliklere sahip bir görsel dosyası gereklidir:

- **Dosya Adı:** `app_icon.png`
- **Boyut:** 1024x1024 piksel (önerilen)
- **Format:** PNG (24-bit veya 32-bit)
- **Şeffaflık:** Olmamalı (solid/opak background)
- **Renk Profili:** sRGB
- **Tasarım Önerileri:**
  - Merkezi tasarım kullanın
  - Her köşeye 16-32px padding bırakın (iOS'ta köşeler yuvarlatılır)
  - Basit ve tanınabilir bir tasarım yapın
  - Küçük boyutlarda da okunabilir olmasına dikkat edin

## 🎨 Icon Oluşturma Adımları

### 1. Icon Dosyasını Hazırlayın

Bir tasarım aracı (Figma, Adobe Illustrator, Photoshop, vb.) kullanarak 1024x1024 boyutunda bir icon tasarlayın veya hazır bir icon kullanın.

**Ücretsiz Icon Araçları:**
- 🎨 [Figma](https://www.figma.com) - Ücretsiz tasarım aracı
- 🖼️ [Canva](https://www.canva.com) - Kolay icon tasarım şablonları
- 📱 [App Icon Generator](https://appicon.co/) - Online icon generator
- 🎭 [Flaticon](https://www.flaticon.com) - Ücretsiz icon kütüphanesi

### 2. Icon Dosyasını Bu Klasöre Ekleyin

Hazırladığınız icon dosyasını bu klasöre kopyalayın:

```bash
# Icon dosyasını kopyalama örneği
cp /yol/to/your/icon.png assets/icon/app_icon.png
```

Veya dosya yöneticisi ile dosyayı sürükle-bırak yapabilirsiniz.

### 3. flutter_launcher_icons Paketini Çalıştırın

Icon'u tüm gerekli boyutlarda oluşturmak için:

```bash
# Önce package'ı yükleyin (ilk kez için)
flutter pub get

# Icon'ları oluşturun
flutter pub run flutter_launcher_icons

# Veya Dart 2.17+ için
dart run flutter_launcher_icons
```

Bu komut otomatik olarak:
- ✅ Android için tüm çözünürlüklerde icon'lar oluşturur (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ Android 8.0+ için adaptive icon'lar oluşturur
- ✅ iOS için tüm gerekli icon boyutlarını oluşturur
- ✅ Icon'ları ilgili klasörlere yerleştirir

### 4. Uygulamayı Çalıştırın ve Kontrol Edin

```bash
# Uygulamayı çalıştır
flutter run

# Ana ekranda yeni icon'u göreceksiniz
```

**Not:** iOS simülatörde icon değişiklikleri bazen gecikebilir. Uygulamayı tamamen kapatıp yeniden başlatın veya simülatörü restart edin.

## 📁 Icon Dosya Yapısı

Icon oluşturulduktan sonra aşağıdaki dosyalar otomatik olarak oluşturulur:

### Android
```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png (48x48)
├── mipmap-hdpi/ic_launcher.png (72x72)
├── mipmap-xhdpi/ic_launcher.png (96x96)
├── mipmap-xxhdpi/ic_launcher.png (144x144)
├── mipmap-xxxhdpi/ic_launcher.png (192x192)
├── mipmap-anydpi-v26/ic_launcher.xml (Adaptive icon - API 26+)
└── drawable-v21/
    └── background.xml (Adaptive icon background)
```

### iOS
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Icon-App-20x20@1x.png (20x20)
├── Icon-App-20x20@2x.png (40x40)
├── Icon-App-20x20@3x.png (60x60)
├── Icon-App-29x29@1x.png (29x29)
├── Icon-App-29x29@2x.png (58x58)
├── Icon-App-29x29@3x.png (87x87)
├── Icon-App-40x40@1x.png (40x40)
├── Icon-App-40x40@2x.png (80x80)
├── Icon-App-40x40@3x.png (120x120)
├── Icon-App-60x60@2x.png (120x120)
├── Icon-App-60x60@3x.png (180x180)
├── Icon-App-76x76@1x.png (76x76)
├── Icon-App-76x76@2x.png (152x152)
├── Icon-App-83.5x83.5@2x.png (167x167)
└── Icon-App-1024x1024@1x.png (1024x1024)
```

## 🎨 Tasarım İpuçları

### ✅ İyi Uygulamalar
- **Basitlik:** Karmaşık detaylardan kaçının, küçük boyutlarda da tanınabilir olsun
- **Kontrast:** Yüksek kontrast kullanarak okunabilirliği artırın
- **Marka Kimliği:** Uygulamanızın amacını yansıtan bir tasarım yapın
- **Renk Paleti:** Uygulamanızın ana renklerini kullanın
- **Test:** Farklı arka planlarda (açık/koyu) nasıl göründüğünü test edin

### ❌ Kaçınılması Gerekenler
- Çok fazla metin kullanmayın (küçük boyutta okunamaz)
- Çok ince çizgiler kullanmayın
- Fotoğraf veya karmaşık gradyanlardan kaçının
- Platform logoları veya markaları kullanmayın (telif hakkı)
- Çok fazla renk kullanmayın (3-4 renk yeterli)

## 🔄 Icon'u Değiştirme

Icon'u değiştirmek için:

1. Yeni icon dosyanızı `app_icon.png` olarak bu klasöre ekleyin (eskisinin üzerine yazın)
2. `flutter pub run flutter_launcher_icons` komutunu tekrar çalıştırın
3. Uygulamayı yeniden derleyin: `flutter clean && flutter run`

## 🌐 Adaptive Icon (Android 8.0+)

Android 8.0 (API level 26) ve üzeri için adaptive icon desteği mevcuttur. Adaptive icon'lar:
- Farklı cihazlarda farklı şekillerde görüntülenebilir (yuvarlak, kare, squircle)
- Foreground ve background katmanlarından oluşur
- Animasyon ve efekt destekler

Mevcut yapılandırmada:
- **Foreground:** Ana icon görseliniz (`app_icon.png`)
- **Background:** Beyaz renk (`#FFFFFF`)

Background rengini değiştirmek için `pubspec.yaml` dosyasındaki `adaptive_icon_background` değerini düzenleyin.

## 📱 Test Etme

### Android
```bash
# Android emulator veya cihazda test
flutter run

# Release build ile test
flutter build apk --release
flutter install
```

### iOS
```bash
# iOS simulator veya cihazda test
flutter run -d ios

# Release build ile test
flutter build ios --release
```

### Icon'u Görüntüleme
- **Android:** Ana ekranda uygulamayı bulun
- **iOS:** Home screen'de uygulamayı bulun
- **Settings:** Uygulama ayarlarında da icon görünür

## 🆘 Sorun Giderme

### Icon Görünmüyor
1. `flutter clean` komutunu çalıştırın
2. `flutter pub get` ile paketleri yeniden yükleyin
3. `flutter pub run flutter_launcher_icons` komutunu tekrar çalıştırın
4. Uygulamayı tamamen silin ve yeniden yükleyin

### iOS'ta Icon Güncellenmiyor
1. Simulator'ü tamamen kapatın
2. Derived Data'yı temizleyin: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. `flutter clean` çalıştırın
4. Uygulamayı yeniden build edin

### Android'de Icon Görünmüyor
1. `android/app/src/main/res/mipmap-*` klasörlerini kontrol edin
2. `ic_launcher.png` dosyalarının var olduğundan emin olun
3. Uygulamayı device'dan silin ve yeniden yükleyin

### Build Hatası
```
Error: Unable to find icon file at path "assets/icon/app_icon.png"
```
**Çözüm:** `app_icon.png` dosyasının bu klasörde olduğundan emin olun.

## 📚 Ek Kaynaklar

- [Flutter Launcher Icons Package](https://pub.dev/packages/flutter_launcher_icons)
- [Android Icon Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design_launcher)
- [iOS Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Material Design Icon Guidelines](https://material.io/design/iconography/product-icons.html)
- [App Icon Template (Figma)](https://i.pinimg.com/736x/3d/d4/82/3dd4828b5204514f976a4cefe4b112ec.jpg)

## 📝 Örnek Icon Boyutları

Eğer manuel olarak farklı boyutlarda icon'lar oluşturmak isterseniz:

### Android (px)
- LDPI: 36x36
- MDPI: 48x48
- HDPI: 72x72
- XHDPI: 96x96
- XXHDPI: 144x144
- XXXHDPI: 192x192

### iOS (pt)
- iPhone: 60pt (180px @3x)
- iPad: 76pt (152px @2x)
- App Store: 1024pt (1024px @1x)

---

**Not:** Bu klasördeki `app_icon.png` dosyası placeholder'dır. Gerçek uygulamanız için kendi tasarımınızı eklemeyi unutmayın!
