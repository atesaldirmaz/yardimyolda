Here's the result of running `cat -n` on /home/ubuntu/code_artifacts/yardimyolda/README.md:
     1	# Yardım Yolda 🚗
     2	
     3	Yol yardım ve çekici hizmeti mobil uygulaması. Müşteriler yol yardımı talep edebilir, hizmet sağlayıcılar da bu taleplere yanıt verebilir.
     4	
     5	## 📱 Özellikler
     6	
     7	### Müşteri Özellikleri
     8	- 🔐 Güvenli kayıt ve giriş sistemi
     9	- 📍 Konum tabanlı hizmet talebi oluşturma
    10	- 🗺️ Gerçek zamanlı harita görünümü
    11	- 💰 Fiyat teklifi alma ve onaylama
    12	- ⭐ Hizmet sağlayıcıları değerlendirme
    13	- 📜 Geçmiş talepleri görüntüleme
    14	
    15	### Hizmet Sağlayıcı Özellikleri
    16	- 🚚 Çekici, mobil tamirci, yakıt ikmali gibi hizmet türleri
    17	- 📋 Yakındaki talepleri görüntüleme
    18	- 💵 Fiyat teklifi verme
    19	- ✅ Admin onayı ile sisteme katılım
    20	- 📊 Müşteri değerlendirmeleri
    21	- 🔔 Anlık bildirimler (FCM entegrasyon noktaları mevcut)
    22	
    23	## 🛠️ Teknolojiler
    24	
    25	### Flutter & Dart
    26	- **Flutter SDK:** `>=3.16.0`
    27	- **Dart SDK:** `>=3.2.0 <4.0.0`
    28	
    29	### Kullanılan Paketler
    30	- `flutter_riverpod` - State management
    31	- `go_router` - Navigation
    32	- `dio` - HTTP client
    33	- `freezed` & `json_serializable` - Code generation
    34	- `supabase_flutter` - Backend (Auth, Database, Storage)
    35	- `google_maps_flutter` - Harita entegrasyonu
    36	- `geolocator` - Konum servisleri
    37	- `flutter_dotenv` - Environment configuration
    38	
    39	## 📋 Gereksinimler
    40	
    41	### Geliştirme Ortamı
    42	- Flutter SDK 3.16.0 veya üzeri
    43	- Dart SDK 3.2.0 veya üzeri
    44	- Android Studio / VS Code (Flutter eklentileri ile)
    45	- Xcode (iOS geliştirme için, sadece macOS)
    46	
    47	### Backend Servisleri
    48	- Supabase hesabı ve projesi
    49	- Google Maps API Key (Android ve iOS için)
    50	- Firebase projesi (FCM için - opsiyonel)
    51	
    52	## 🚀 Kurulum
    53	
    54	### 1. Depoyu Klonlayın
    55	```bash
    56	git clone https://github.com/your-username/yardimyolda.git
    57	cd yardimyolda
    58	```
    59	
    60	### 2. Bağımlılıkları Yükleyin
    61	```bash
    62	flutter pub get
    63	```
    64	
    65	### 3. Environment Değişkenlerini Ayarlayın
    66	
    67	`.env.example` dosyasını `.env` olarak kopyalayın:
    68	```bash
    69	cp .env.example .env
    70	```
    71	
    72	`.env` dosyasını düzenleyin ve gerçek değerlerinizi ekleyin:
    73	```env
    74	SUPABASE_URL=https://your-project.supabase.co
    75	SUPABASE_ANON_KEY=your-anon-key-here
    76	GOOGLE_MAPS_API_KEY=your-google-maps-api-key
    77	```
    78	
    79	### 4. Code Generation
    80	
    81	Freezed ve JSON Serializable için kod üretimi:
    82	```bash
    83	# Tek seferlik build
    84	flutter pub run build_runner build --delete-conflicting-outputs
    85	
    86	# Değişiklikleri izleyerek otomatik build (geliştirme sırasında önerilir)
    87	flutter pub run build_runner watch --delete-conflicting-outputs
    88	```
    89	
    90	### 5. Supabase Database Setup
    91	
    92	Veritabanı şemasını oluşturmak için migration dosyalarını uygulamanız gerekmektedir.
    93	
    94	#### Seçenek A: Supabase Dashboard Kullanarak
    95	1. [Supabase Dashboard](https://app.supabase.com) üzerinden projenizi açın
    96	2. Sol menüden **SQL Editor** sekmesine gidin
    97	3. `supabase/migrations/` klasöründeki dosyaları sırayla kopyalayıp yapıştırın:
    98	   - `0001_init.sql` (Temel tablo yapısı)
    99	   - `0002_mock_match.sql` (Mock data ve fonksiyonlar)
   100	4. Her dosya için **RUN** butonuna tıklayın
   101	
   102	#### Seçenek B: Supabase CLI Kullanarak (Önerilen)
   103	
   104	##### 5.1. Supabase CLI Kurulumu
   105	```bash
   106	# npm ile kurulum
   107	npm install -g supabase
   108	
   109	# Ya da Homebrew ile (macOS)
   110	brew install supabase/tap/supabase
   111	
   112	# Ya da Scoop ile (Windows)
   113	scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
   114	scoop install supabase
   115	```
   116	
   117	##### 5.2. Projeyi Başlatma ve Bağlama
   118	```bash
   119	# Supabase'e giriş yapın
   120	supabase login
   121	
   122	# Proje klasörüne gidin
   123	cd yardimyolda
   124	
   125	# Supabase projesini başlatın (ilk kez için)
   126	supabase init
   127	
   128	# Uzak Supabase projenizi bağlayın
   129	supabase link --project-ref your-project-ref
   130	```
   131	
   132	**Not:** `your-project-ref` değerini Supabase Dashboard'unuzdan alabilirsiniz. 
   133	Project Settings > General > Reference ID bölümünde bulunur.
   134	
   135	##### 5.3. Migration'ları Uygulama
   136	
   137	**Yöntem 1: Tüm migration'ları sıfırdan uygula**
   138	```bash
   139	# Tüm veritabanını sıfırlayıp migration'ları uygula
   140	supabase db reset
   141	```
   142	⚠️ **Dikkat:** Bu komut mevcut veritabanınızdaki tüm verileri siler!
   143	
   144	**Yöntem 2: Sadece yeni migration'ları uygula (Önerilen)**
   145	```bash
   146	# Sadece henüz uygulanmamış migration'ları çalıştır
   147	supabase db push
   148	```
   149	
   150	**Yöntem 3: Migration durumunu kontrol et**
   151	```bash
   152	# Hangi migration'ların uygulandığını görüntüle
   153	supabase migration list
   154	
   155	# Migration'ları manuel olarak uygula
   156	supabase migration up
   157	```
   158	
   159	##### 5.4. Veritabanı Bağlantısını Test Etme
   160	```bash
   161	# Veritabanı bağlantısını test et
   162	supabase db ping
   163	
   164	# SQL sorgusu çalıştır
   165	supabase db query "SELECT version();"
   166	```
   167	
   168	**Faydalı CLI Komutları:**
   169	- `supabase status` - Proje durumunu görüntüle
   170	- `supabase migration new <name>` - Yeni migration oluştur
   171	- `supabase db diff` - Yerel ve uzak veritabanı arasındaki farkları göster
   172	- `supabase db pull` - Uzak veritabından şemayı çek
   173	
   174	**Not:** Supabase CLI kullanımı için [Supabase CLI Dokümantasyonu](https://supabase.com/docs/guides/cli) incelenebilir.
   175	
   176	### 6. Google Maps Konfigürasyonu
   177	
   178	#### Android için:
   179	`android/app/src/main/AndroidManifest.xml` dosyasına API key ekleyin:
   180	```xml
   181	<application>
   182	    <!-- Google Maps API Key -->
   183	    <meta-data
   184	        android:name="com.google.android.geo.API_KEY"
   185	        android:value="${GOOGLE_MAPS_API_KEY}" />
   186	</application>
   187	```
   188	
   189	#### iOS için:
   190	`ios/Runner/AppDelegate.swift` dosyasına API key ekleyin:
   191	```swift
   192	import GoogleMaps
   193	
   194	GMSServices.provideAPIKey("YOUR_API_KEY")
   195	```
   196	
   197	### 7. Uygulamayı Çalıştırın
   198	```bash
   199	# Android Emulator veya cihazda
   200	flutter run
   201	
   202	# iOS Simulator veya cihazda (sadece macOS)
   203	flutter run -d ios
   204	
   205	# Debug bilgisi ile
   206	flutter run --verbose
   207	```
## 🏗️ Build ve Release Hazırlığı

Bu bölüm, uygulamanızı production (üretim) ortamı için hazırlama ve build alma adımlarını içerir.

### Build Öncesi Kontrol Listesi

Uygulamayı build etmeden önce aşağıdaki kontrolleri yapın:

- [ ] ✅ **Bağımlılıklar yüklendi** - `flutter pub get` komutu çalıştırıldı
- [ ] ✅ **Environment değişkenleri ayarlandı** - `.env` dosyası oluşturuldu ve dolduruldu
- [ ] ✅ **Code generation tamamlandı** - `flutter pub run build_runner build` çalıştırıldı
- [ ] ✅ **Firebase yapılandırması** - Gerçek `google-services.json` ve `GoogleService-Info.plist` dosyaları eklendi
- [ ] ✅ **Google Maps API key** - AndroidManifest.xml ve Info.plist dosyalarında gerçek API key kullanıldı
- [ ] ✅ **App icon oluşturuldu** - `flutter pub run flutter_launcher_icons` komutu çalıştırıldı
- [ ] ✅ **Signing yapılandırıldı** - Android keystore ve iOS provisioning profile ayarlandı
- [ ] ✅ **Testler başarılı** - `flutter test` komutu çalıştırıldı ve geçti

### Environment Değişkenleri Kurulumu

#### 1. .env Dosyası Oluşturma
```bash
# .env.example dosyasını .env olarak kopyalayın
cp .env.example .env
```

#### 2. Gerçek Değerleri Doldurun
`.env` dosyasını bir text editör ile açın ve aşağıdaki değerleri doldurun:

```env
# Supabase Configuration
# Supabase Dashboard > Settings > API bölümünden alın
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Google Maps Configuration
# Google Cloud Console > APIs & Services > Credentials bölümünden alın
GOOGLE_MAPS_API_KEY=AIzaSyD...

# Firebase Cloud Messaging (FCM) - Opsiyonel
FCM_SERVER_KEY=your_fcm_server_key_here
```

**Önemli Notlar:**
- 🚫 `.env` dosyasını **asla** Git'e commit etmeyin
- ✅ `.env.example` dosyası Git'te kalmalı (şablon olarak)
- 🔐 API key'lerinizi güvenli tutun ve paylaşmayın

### Android Build

#### 1. Keystore Oluşturma (İlk Kez)

Release build için bir keystore dosyası oluşturmanız gerekir:

```bash
# Keystore oluşturma
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Komut size şunları soracaktır:
# - Keystore şifresi
# - İsim, organizasyon, şehir vb. bilgiler
# - Key şifresi
```

**⚠️ ÖNEMLİ:** 
- Keystore dosyasını ve şifreleri güvenli bir yerde saklayın
- Bu bilgileri kaybederseniz uygulamanızı güncelleyemezsiniz!

#### 2. Key Properties Dosyası Oluşturma

`android/key.properties` dosyasını oluşturun:

```bash
# Dosyayı oluştur
touch android/key.properties
```

İçeriğini şu şekilde doldurun:
```properties
storePassword=<keystore-şifreniz>
keyPassword=<key-şifreniz>
keyAlias=upload
storeFile=<keystore-dosya-yolunuz>
# Örnek: /Users/kullanici/upload-keystore.jks veya ~/upload-keystore.jks
```

**Not:** `android/key.properties` dosyası `.gitignore`'da olmalıdır (zaten ekli).

#### 3. build.gradle Yapılandırması (Zaten Yapılandırılmış Olmalı)

`android/app/build.gradle` dosyasında signing config'in doğru olduğundan emin olun:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### 4. Android Build Komutları

##### Debug APK (Test için)
```bash
flutter build apk --debug

# Çıktı: build/app/outputs/flutter-apk/app-debug.apk
```

##### Release APK (Dağıtım için)
```bash
flutter build apk --release

# Çıktı: build/app/outputs/flutter-apk/app-release.apk
```

##### Release App Bundle (Google Play için - Önerilen)
```bash
flutter build appbundle --release

# Çıktı: build/app/outputs/bundle/release/app-release.aab
```

**Not:** Google Play Store için App Bundle (.aab) formatı önerilir çünkü daha küçük indirme boyutları sağlar.

#### 5. APK/AAB Boyutunu Analiz Etme

```bash
# APK boyutunu analiz et
flutter build apk --release --analyze-size

# App Bundle boyutunu analiz et
flutter build appbundle --release --analyze-size
```

### iOS Build

#### 1. Apple Developer Gereksinimleri

iOS için build almak üzere aşağıdakilere ihtiyacınız var:

- 🍎 **macOS** işletim sistemi
- 💻 **Xcode** (App Store'dan ücretsiz indirin)
- 👤 **Apple Developer hesabı** ($99/yıl - App Store'da yayınlamak için)
- 📱 **Test cihazı veya simülatör**

#### 2. Xcode'da Projeyi Açma

```bash
# iOS projesini Xcode'da aç
open ios/Runner.xcworkspace
```

**⚠️ Dikkat:** `Runner.xcodeproj` değil, `Runner.xcworkspace` dosyasını açın!

#### 3. Signing & Capabilities Yapılandırması

Xcode'da:

1. **Runner** projesini seçin (sol panel)
2. **Signing & Capabilities** sekmesine gidin
3. **Team** dropdown'ından Apple Developer hesabınızı seçin
4. **Bundle Identifier** değerini benzersiz yapın (örn: `com.yourcompany.yardimyolda`)
5. Xcode otomatik olarak provisioning profile oluşturacaktır

**Gerekli Capabilities (Yetenek) Listesi:**
- ✅ **Location** (Background modes)
  - Location updates aktif olmalı
- ✅ **Push Notifications**
- ✅ **Background Modes**
  - Background fetch
  - Remote notifications

#### 4. iOS Build Komutları

##### Debug Build (Simulator için)
```bash
# Simulator için build
flutter build ios --debug --simulator

# Çalıştır
flutter run -d "iPhone 15 Pro"
```

##### Release Build (Gerçek Cihaz için)
```bash
# Release build
flutter build ios --release
```

##### Archive ve Distribution (App Store için)

**Komut Satırı ile:**
```bash
# iOS build al
flutter build ios --release

# Xcode'da archive işlemini yap
cd ios
xcodebuild -workspace Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -archivePath build/Runner.xcarchive \
           archive

# Export IPA (App Store için)
xcodebuild -exportArchive \
           -archivePath build/Runner.xcarchive \
           -exportPath build \
           -exportOptionsPlist ExportOptions.plist
```

**Xcode GUI ile (Önerilen):**

1. Xcode'da projeyi açın: `open ios/Runner.xcworkspace`
2. Menüden **Product > Archive** seçin
3. Archive tamamlandığında **Organizer** penceresi açılır
4. **Distribute App** butonuna tıklayın
5. Dağıtım yöntemini seçin:
   - **App Store Connect** - App Store'da yayınlamak için
   - **Ad Hoc** - Test cihazlarına dağıtmak için
   - **Enterprise** - Kurumsal dağıtım için
   - **Development** - Geliştirici cihazlarına yüklemek için
6. Yönergeleri takip edin ve **Export** edin

#### 5. Provisioning Profile Türleri

- **Development:** Geliştirme sırasında test için
- **Ad Hoc:** Belirli cihazlarda test için (maksimum 100 cihaz)
- **App Store:** App Store'da yayınlamak için
- **Enterprise:** Kurumsal dağıtım için (Apple Developer Enterprise hesabı gerekir)

### App Icon Yapılandırması

#### 1. Icon Hazırlama

Uygulama ikonu için:
- **Boyut:** 1024x1024 piksel (PNG formatı)
- **Şeffaflık:** Olmamalı (opak/solid)
- **Format:** PNG (24-bit)
- **Tasarım:** Her köşeye 16px padding ile merkezi tasarım (iOS'ta köşeler yuvarlatılır)

#### 2. Icon Dosyasını Ekleyin

Icon dosyanızı şu konuma yerleştirin:
```
assets/icon/app_icon.png
```

#### 3. flutter_launcher_icons Paketini Kullanma

`pubspec.yaml` dosyasında zaten yapılandırılmıştır:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  # min_sdk_android: 21 # Android min SDK (opsiyonel)
  
  # Adaptive icon (Android 8.0+)
  adaptive_icon_foreground: "assets/icon/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
```

#### 4. Icon Oluşturma

```bash
# Icon'ları oluştur
flutter pub run flutter_launcher_icons

# Veya
dart run flutter_launcher_icons
```

Bu komut otomatik olarak:
- Android için tüm çözünürlüklerde (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi) icon'lar oluşturur
- iOS için tüm gerekli icon boyutlarını oluşturur
- Adaptive icon için Android 8.0+ özel icon'lar oluşturur

#### 5. Icon'u Doğrulama

```bash
# Android için
flutter run
# Ana ekranda app icon'u kontrol edin

# iOS için
open ios/Runner/Assets.xcassets/AppIcon.appiconset/
# Icon dosyalarını görüntüleyin
```

### Build Hata Giderme

#### Yaygın Android Build Hataları

**1. "Keystore not found" Hatası**
```bash
# key.properties dosyasındaki yolun doğru olduğundan emin olun
storeFile=/tam/yol/upload-keystore.jks
```

**2. "Signing config is not specified" Hatası**
```bash
# build.gradle dosyasında signingConfigs yapılandırmasını kontrol edin
```

**3. "GOOGLE_MAPS_API_KEY not found" Hatası**
```bash
# .env dosyasında GOOGLE_MAPS_API_KEY'in tanımlı olduğundan emin olun
# AndroidManifest.xml'de doğru şekilde referans edildiğinden emin olun
```

**4. Gradle Build Hatası**
```bash
# Gradle cache'i temizle
cd android
./gradlew clean
cd ..

# Yeniden build et
flutter clean
flutter pub get
flutter build apk --release
```

#### Yaygın iOS Build Hataları

**1. "No valid code signing" Hatası**
- Xcode'da Signing & Capabilities sekmesine gidin
- Team seçimini yapın
- Provisioning profile'ın otomatik oluşturulmasını bekleyin

**2. "Google Maps API Key not found" Hatası**
```bash
# Info.plist dosyasında GMSServicesAPIKey'in tanımlı olduğundan emir olun
# AppDelegate.swift'te GMSServices.provideAPIKey() çağrısı yapıldığından emin olun
```

**3. "CocoaPods out of date" Hatası**
```bash
# CocoaPods'u güncelleyin
sudo gem install cocoapods

# Pod'ları yeniden yükleyin
cd ios
pod deintegrate
pod install
cd ..
```

**4. Archive Hatası**
```bash
# Clean build folder
# Xcode > Product > Clean Build Folder (Shift+Cmd+K)

# Derived data'yı temizle
rm -rf ~/Library/Developer/Xcode/DerivedData

# Yeniden archive et
```

### Build Boyutunu Optimize Etme

#### Android için

**1. ProGuard/R8 Kullanımı (Zaten Aktif)**

`android/app/build.gradle` dosyasında:
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

**2. Split APK Oluşturma**
```bash
# ABI'ye göre ayrı APK'lar oluştur
flutter build apk --release --split-per-abi

# Çıktılar:
# - app-armeabi-v7a-release.apk
# - app-arm64-v8a-release.apk
# - app-x86_64-release.apk
```

#### iOS için

**1. Bitcode Kullanımı**
- Xcode'da **Build Settings** > **Enable Bitcode** = YES

**2. App Thinning**
- App Store otomatik olarak cihaza göre optimize edilmiş sürüm indirir

### Sürüm Numarası Güncelleme

#### pubspec.yaml
```yaml
version: 1.0.0+1
#        ↑     ↑
#        |     └─ Build number (Android: versionCode, iOS: CFBundleVersion)
#        └─────── Version name (Android: versionName, iOS: CFBundleShortVersionString)
```

#### Güncelleme Örnekleri
```yaml
# İlk release
version: 1.0.0+1

# Minor update (bug fixes)
version: 1.0.1+2

# Minor feature
version: 1.1.0+3

# Major release
version: 2.0.0+4
```

#### Komut satırından build number ile build
```bash
# Belirli version ve build number ile
flutter build apk --release --build-name=1.2.3 --build-number=10
```

### Store'lara Yükleme

#### Google Play Store

1. **Google Play Console**'a gidin: https://play.google.com/console
2. Yeni uygulama oluşturun
3. **Release > Production** sekmesine gidin
4. **Create new release** butonuna tıklayın
5. AAB dosyasını yükleyin (`build/app/outputs/bundle/release/app-release.aab`)
6. Release notes ekleyin
7. Review ve publish edin

**Gerekli Belgeler:**
- 📱 App icon (512x512 PNG)
- 📸 Screenshots (telefon, 7" tablet, 10" tablet için)
- 🎬 Feature graphic (1024x500 PNG)
- 📝 App açıklaması (kısa ve uzun)
- 🔞 İçerik derecelendirmesi anketi
- 🏷️ Kategori ve tag'ler

#### Apple App Store

1. **App Store Connect**'e gidin: https://appstoreconnect.apple.com
2. **My Apps** > **+ (Plus)** > **New App**
3. App bilgilerini doldurun (Bundle ID, Name, vb.)
4. Xcode'dan Archive'i upload edin (Organizer üzerinden)
5. Veya Application Loader kullanın
6. App Store Connect'te build'i seçin
7. Screenshots, açıklama vb. ekleyin
8. **Submit for Review** butonuna tıklayın

**Gerekli Belgeler:**
- 📱 App icon (1024x1024 PNG)
- 📸 Screenshots (iPhone, iPad için farklı boyutlar)
- 📝 App açıklaması ve anahtar kelimeler
- 🔞 İçerik derecelendirmesi
- 🏷️ Kategori ve sub-kategori
- 🔗 Privacy policy URL'i
- 🔗 Support URL'i

### Test ve Quality Assurance

#### Pre-Release Test Checklist

- [ ] 📱 **Farklı cihazlarda test** (düşük, orta, yüksek performanslı)
- [ ] 📐 **Farklı ekran boyutları** (küçük, orta, büyük, tablet)
- [ ] 🌐 **Ağ koşulları** (WiFi, 4G, yavaş bağlantı, offline)
- [ ] 🔋 **Pil tüketimi** test edildi
- [ ] 💾 **Bellek kullanımı** optimize edildi
- [ ] 🔐 **Güvenlik** kontrolleri yapıldı (API keys, tokens)
- [ ] ⚡ **Performans** testleri (FPS, load times)
- [ ] 🐛 **Crash reporting** entegre edildi (Firebase Crashlytics vb.)
- [ ] 📊 **Analytics** entegre edildi (Google Analytics, Firebase Analytics)

#### Beta Testing

**Android (Google Play Internal Testing):**
1. Play Console > Release > Testing > Internal testing
2. AAB'yi yükleyin
3. Test kullanıcıları ekleyin
4. Feedback toplayın

**iOS (TestFlight):**
1. Xcode'dan build'i upload edin
2. App Store Connect > TestFlight sekmesi
3. Internal/External testers ekleyin
4. Test daveti gönderin
5. Feedback toplayın

### CI/CD ile Otomatik Build

#### GitHub Actions Örneği

`.github/workflows/build.yml` dosyası oluşturun:

```yaml
name: Build and Release

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '11'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
```

### Faydalı Komutlar

```bash
# Flutter doctor - sistem kontrolü
flutter doctor -v

# Bağlı cihazları listele
flutter devices

# Belirli bir cihazda çalıştır
flutter run -d <device-id>

# Build cache'i temizle
flutter clean

# Pub cache'i temizle
flutter pub cache repair

# Tüm paketleri güncelle
flutter pub upgrade

# Outdated paketleri kontrol et
flutter pub outdated
```

---

   208	
   209	## 📁 Proje Yapısı
   210	
   211	```
   212	lib/
   213	├── app.dart                          # Ana uygulama widget'ı
   214	├── main.dart                         # Uygulama giriş noktası
   215	├── routes/
   216	│   └── app_router.dart               # Go Router yapılandırması
   217	├── features/
   218	│   ├── auth/                         # Kimlik doğrulama özelliği
   219	│   │   ├── data/                     # Veri katmanı (repositories)
   220	│   │   ├── presentation/             # Sunum katmanı
   221	│   │   │   ├── pages/                # Sayfalar (login, register)
   222	│   │   │   └── widgets/              # Özel widget'lar
   223	│   │   └── providers/                # Riverpod providers
   224	│   ├── customer/                     # Müşteri özellikleri
   225	│   │   ├── data/
   226	│   │   ├── domain/
   227	│   │   ├── presentation/
   228	│   │   └── providers/
   229	│   ├── dashboard/                    # Ana panel özelliği
   230	│   │   ├── data/
   231	│   │   ├── presentation/
   232	│   │   └── providers/
   233	│   ├── payment/                      # Ödeme özelliği (Mock)
   234	│   │   └── presentation/
   235	│   │       └── screens/
   236	│   │           └── payment_screen.dart
   237	│   └── rating/                       # Değerlendirme özelliği
   238	│       ├── data/
   239	│       ├── presentation/
   240	│       └── providers/
   241	├── core/
   242	│   ├── theme/
   243	│   │   └── app_theme.dart            # Material 3 tema yapılandırması
   244	│   ├── widgets/                      # Paylaşılan widget'lar
   245	│   ├── utils/                        # Yardımcı fonksiyonlar
   246	│   └── constants/                    # Sabitler
   247	├── data/
   248	│   ├── models/                       # Veri modelleri (Freezed)
   249	│   └── repositories/                 # Veri depoları
   250	supabase/
   251	└── migrations/
   252	    └── 0001_init.sql                 # Veritabanı şeması
   253	assets/
   254	└── images/                           # Resim dosyaları
   255	```
   256	
   257	## 🗄️ Veritabanı Şeması
   258	
   259	### Tablolar
   260	
   261	#### `user_profiles`
   262	Kullanıcı profil bilgileri
   263	- `id` (UUID, FK to auth.users)
   264	- `role` ('customer', 'provider', 'admin')
   265	- `name`, `phone`, `email`
   266	- `vehicle_type`, `license_plate` (Hizmet sağlayıcılar için)
   267	- `is_approved`, `is_available` (Hizmet sağlayıcı durumu)
   268	- `last_known_lat`, `last_known_lng` (Konum)
   269	
   270	#### `service_requests`
   271	Hizmet talepleri
   272	- `id` (UUID)
   273	- `customer_id`, `provider_id` (UUID, FK)
   274	- `status` ('pending', 'quoted', 'accepted', 'in_progress', 'completed', 'cancelled', 'rejected')
   275	- `service_type` ('towing', 'battery_jump', 'tire_change', 'fuel_delivery', 'lockout', 'mechanical_repair')
   276	- `customer_lat`, `customer_lng` (Müşteri konumu)
   277	- `destination_lat`, `destination_lng` (Varış noktası)
   278	- `quoted_price`, `final_price`
   279	
   280	#### `ratings`
   281	Değerlendirmeler
   282	- `id` (UUID)
   283	- `request_id`, `customer_id`, `provider_id` (UUID, FK)
   284	- `stars` (1-5)
   285	- `comment`
   286	
   287	### Row Level Security (RLS)
   288	Tüm tablolarda RLS etkin. Her kullanıcı sadece kendi verilerine erişebilir. Detaylar için `0001_init.sql` dosyasına bakın.
   289	
   290	## 🎨 Tema ve Tasarım
   291	
   292	- **Material 3** tasarım sistemi kullanılmıştır
   293	- Açık (Light) ve koyu (Dark) tema desteği
   294	- Renk paleti:
   295	  - Primary: Mavi (#2563EB)
   296	  - Secondary: Yeşil (#10B981)
   297	  - Error: Kırmızı (#EF4444)
   298	  - Warning: Turuncu (#F59E0B)
   299	
   300	## 🔐 Kimlik Doğrulama
   301	
   302	Supabase Auth kullanılarak:
   303	- E-posta ve şifre ile kayıt
   304	- E-posta doğrulama
   305	- Şifre sıfırlama
   306	- PKCE akışı ile güvenli auth
   307	
   308	## 🗺️ Harita ve Konum
   309	
   310	- Google Maps entegrasyonu
   311	- Gerçek zamanlı konum takibi
   312	- Geocoding ve reverse geocoding
   313	- Mesafe hesaplama
   314	
   315	## 💳 Ödeme Akışı
   316	
   317	Uygulama, hizmet ödemelerini kolaylaştırmak için bir **mock ödeme sistemi** kullanır. Bu özellik gerçek bir ödeme entegrasyonu olmadan ödeme akışını test etmenizi sağlar.
   318	
   319	### Ödeme Akışı Adımları
   320	
   321	1. **Hizmet Seçimi** (`/customer/service-select`)
   322	   - Müşteri, ihtiyaç duyduğu hizmet türünü seçer (Çekici, Akü, Lastik, Yakıt)
   323	   - Her hizmet türü için sabit fiyatlar belirlenir:
   324	     - 🚚 **Çekici:** 500 ₺
   325	     - 🔋 **Akü:** 300 ₺
   326	     - 🛞 **Lastik:** 250 ₺
   327	     - ⛽ **Yakıt:** 200 ₺
   328	
   329	2. **Servis Talebi Oluşturma**
   330	   - Hizmet seçildikten sonra, sistem otomatik olarak:
   331	     - Müşterinin konumunu alır
   332	     - Seçilen hizmet türü için bir servis talebi oluşturur
   333	     - Fiyat bilgisini (`quoted_price`) talebe ekler
   334	     - Müşteriyi ödeme ekranına yönlendirir
   335	
   336	3. **Ödeme Ekranı** (`/customer/payment/:requestId`)
   337	   - Servis detayları görüntülenir (hizmet türü, fiyat)
   338	   - Mock kredi kartı formu doldurulur:
   339	     - **Kart Numarası:** 16 haneli (herhangi bir numara)
   340	     - **Son Kullanma Tarihi:** AA/YY formatında gelecek bir tarih
   341	     - **CVV:** 3 haneli (herhangi bir numara)
   342	   - Form validasyonu yapılır
   343	
   344	4. **Ödeme İşleme** (Mock)
   345	   - "Ödemeyi Tamamla" butonuna tıklandığında:
   346	     - 3 saniyelik bir simülasyon çalışır (gerçek ödeme işlemini taklit eder)
   347	     - Servis talebinin durumu `completed` olarak güncellenir
   348	     - Başarı mesajı gösterilir: "Talebiniz tamamlandı."
   349	     - Müşteri, geçmiş talepler sayfasına (`/customer/history`) yönlendirilir
   350	
   351	### Test Kartı Bilgileri
   352	
   353	Bu bir **mock ödeme sistemi** olduğu için, aşağıdaki test bilgilerini kullanabilirsiniz:
   354	
   355	- **Kart Numarası:** Herhangi bir 16 haneli sayı (örn: `4242 4242 4242 4242`)
   356	- **Son Kullanma Tarihi:** Gelecekteki herhangi bir tarih (örn: `12/25`)
   357	- **CVV:** Herhangi bir 3 haneli sayı (örn: `123`)
   358	
   359	> ⚠️ **Önemli:** Bu mock sistemde gerçek bir ödeme işlemi gerçekleştirilmez. Hiçbir gerçek kredi kartı bilgisi kullanılmamalıdır.
   360	
   361	### Teknik Detaylar
   362	
   363	- **Veritabanı:** `service_requests` tablosuna `quoted_price` alanı eklendi
   364	- **Model:** `ServiceRequest` modeli fiyat bilgisini destekler
   365	- **Form Validasyonu:** Kart numarası, son kullanma tarihi ve CVV için validasyon kuralları uygulanır
   366	- **Durum Yönetimi:** Riverpod ile yönetilen ödeme durumu
   367	- **Hata Yönetimi:** Türkçe hata mesajları ve kullanıcı dostu geri bildirim
   368	
   369	### Gelecek Geliştirmeler
   370	
   371	Gerçek bir üretim ortamı için, aşağıdaki ödeme gateway'lerinden biri entegre edilebilir:
   372	- 💳 **İyzico** (Türkiye için popüler)
   373	- 💳 **Stripe**
   374	- 💳 **PayTR**
   375	- 💳 **Paypal**
   376	
   377	## 🔔 Firebase Cloud Messaging (FCM) Kurulumu
   378	
   379	Uygulama, servis taleplerinin durum değişikliklerinde kullanıcılara bildirim göndermek için Firebase Cloud Messaging (FCM) kullanır. Şu anda **placeholder (sahte) yapılandırma** ile gelir, gerçek bildirimler için gerçek Firebase projesi kurmanız gerekir.
   380	
   381	### Mevcut Placeholder Yapılandırma
   382	
   383	Proje, geliştirme ve test için placeholder Firebase yapılandırma dosyalarıyla gelir:
   384	- `android/app/google-services.json` (Placeholder)
   385	- `ios/Runner/GoogleService-Info.plist` (Placeholder)
   386	
   387	⚠️ **Önemli:** Bu dosyalar sadece projenin derlenmesini sağlar. Gerçek bildirimler göndermek için gerçek Firebase projesi yapılandırması gereklidir.
   388	
   389	### Gerçek Firebase Projesi Kurulumu (Üretim için)
   390	
   391	#### 1. Firebase Projesi Oluşturma
   392	
   393	1. [Firebase Console](https://console.firebase.google.com/) adresine gidin
   394	2. "Add project" butonuna tıklayın
   395	3. Proje adını girin (örn: "yardimyolda-prod")
   396	4. Google Analytics'i etkinleştirin (isteğe bağlı)
   397	5. Projeyi oluşturun
   398	
   399	#### 2. Android Uygulaması Ekleme
   400	
   401	1. Firebase Console'da projenize gidin
   402	2. Android simgesine tıklayın
   403	3. Android paket adını girin: `com.yardimyolda.app`
   404	4. Uygulama nickname'i girin (isteğe bağlı)
   405	5. Debug signing certificate SHA-1 ekleyin (isteğe bağlı, geliştirme için)
   406	6. "Register app" butonuna tıklayın
   407	7. **`google-services.json`** dosyasını indirin
   408	8. İndirilen dosyayı `android/app/` klasörüne kopyalayın (mevcut placeholder dosyasının üzerine yazın)
   409	
   410	**SHA-1 Fingerprint Alma (Geliştirme için):**
   411	```bash
   412	# Debug keystore için
   413	keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   414	
   415	# Üretim keystore için
   416	keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias
   417	```
   418	
   419	#### 3. iOS Uygulaması Ekleme
   420	
   421	1. Firebase Console'da projenize gidin
   422	2. iOS simgesine tıklayın
   423	3. iOS bundle ID'sini girin: `com.yardimyolda.app`
   424	4. App nickname'i girin (isteğe bağlı)
   425	5. "Register app" butonuna tıklayın
   426	6. **`GoogleService-Info.plist`** dosyasını indirin
   427	7. İndirilen dosyayı `ios/Runner/` klasörüne kopyalayın (mevcut placeholder dosyasının üzerine yazın)
   428	8. Xcode'da projeyi açın ve dosyayı Runner target'ına ekleyin
   429	
   430	#### 4. Firebase Yapılandırmasını Doğrulama
   431	
   432	```bash
   433	# Dependencies'leri yeniden yükle
   434	flutter pub get
   435	
   436	# Android için build
   437	flutter build apk
   438	
   439	# iOS için build (macOS)
   440	flutter build ios
   441	```
   442	
   443	### FCM Özellikleri
   444	
   445	Uygulama, FCM ile şu özellikleri destekler:
   446	
   447	#### 1. Otomatik Bildirim İzni İsteği
   448	- Kullanıcı OTP ile giriş yaptıktan hemen sonra bildirim izni istenir
   449	- İzin durumu gracefully (zarif şekilde) handle edilir
   450	- Reddedilse bile uygulama çalışmaya devam eder
   451	
   452	#### 2. FCM Token Yönetimi
   453	- Token otomatik olarak alınır ve Supabase'deki `user_profiles.device_token` alanına kaydedilir
   454	- Token yenilendiğinde otomatik güncellenir
   455	- Logout durumunda token temizlenir
   456	
   457	#### 3. Supabase Realtime Entegrasyonu
   458	- `service_requests` tablosundaki `status` değişiklikleri gerçek zamanlı dinlenir
   459	- Durum değişikliğinde otomatik olarak local notification gösterilir
   460	- Türkçe bildirim mesajları:
   461	  - **pending:** "Çekici talebiniz alındı. Sağlayıcı aranıyor..."
   462	  - **accepted:** "Çekici talebiniz kabul edildi!"
   463	  - **on_the_way:** "Sağlayıcı yola çıktı. Yakında yanınızda olacak."
   464	  - **in_progress:** "Çekici hizmeti başladı."
   465	  - **completed:** "Çekici hizmeti tamamlandı. Lütfen değerlendirin."
   466	  - **cancelled:** "Çekici talebiniz iptal edildi."
   467	
   468	#### 4. Bildirim Türleri
   469	- **Foreground Notifications:** Uygulama açıkken gösterilen bildirimler
   470	- **Background Notifications:** Uygulama arka planda iken gösterilen bildirimler
   471	- **Terminated Notifications:** Uygulama kapalıyken gösterilen bildirimler
   472	
   473	### Bildirim Sistemi Mimarisi
   474	
   475	```
   476	┌─────────────────────────────────────────────┐
   477	│          Supabase Database                  │
   478	│    (service_requests table)                 │
   479	└──────────────┬──────────────────────────────┘
   480	               │ Status Update
   481	               ▼
   482	┌──────────────────────────────────────────────┐
   483	│     Supabase Realtime                        │
   484	│     (PostgreSQL LISTEN/NOTIFY)               │
   485	└──────────────┬───────────────────────────────┘
   486	               │ Broadcast Change
   487	               ▼
   488	┌──────────────────────────────────────────────┐
   489	│   ServiceNotificationListener                │
   490	│   (lib/core/services/...)                    │
   491	└──────────────┬───────────────────────────────┘
   492	               │ Trigger Notification
   493	               ▼
   494	┌──────────────────────────────────────────────┐
   495	│   NotificationService                        │
   496	│   (Firebase + Local Notifications)           │
   497	└──────────────┬───────────────────────────────┘
   498	               │ Display
   499	               ▼
   500	┌──────────────────────────────────────────────┐
   501	│   User's Device                              │
   502	│   (Push Notification)                        │
   503	└──────────────────────────────────────────────┘
   504	```
   505	
   506	### Teknik Detaylar
   507	
   508	#### Kullanılan Paketler
   509	- `firebase_core: ^2.27.0` - Firebase temel işlevsellik
   510	- `firebase_messaging: ^14.7.19` - FCM push notifications
   511	- `flutter_local_notifications: ^17.0.0` - Local notifications
   512	
   513	#### Servis ve Provider'lar
   514	- **NotificationService** (`lib/core/services/notification_service.dart`)
   515	  - FCM başlatma ve yapılandırma
   516	  - Token yönetimi
   517	  - Local notification gösterme
   518	  - İzin yönetimi
   519	
   520	- **ServiceNotificationListener** (`lib/core/services/service_notification_listener.dart`)
   521	  - Supabase Realtime dinleyicisi
   522	  - Status değişikliği algılama
   523	  - Bildirim tetikleme
   524	
   525	- **NotificationProvider** (`lib/core/providers/notification_provider.dart`)
   526	  - Riverpod state management
   527	  - İzin durumu yönetimi
   528	  - Token durumu yönetimi
   529	
   530	#### Yapılandırma Dosyaları
   531	- `android/app/src/main/AndroidManifest.xml` - Android izinleri ve metadata
   532	- `android/app/build.gradle` - Firebase dependencies
   533	- `ios/Runner/Info.plist` - iOS izinleri
   534	- `ios/Runner/AppDelegate.swift` - iOS bildirim delegates
   535	
   536	### Hata Ayıklama
   537	
   538	#### Firebase Başlatma Hatası
   539	```
   540	⚠️ Firebase başlatma hatası (placeholder config kullanılıyor)
   541	```
   542	Bu hata placeholder config kullanıldığında normaldir. Gerçek Firebase config dosyalarını ekleyin.
   543	
   544	#### Token Alınamıyor
   545	```bash
   546	# Android için
   547	adb logcat | grep FCM
   548	
   549	# iOS için Xcode Console
   550	# Xcode -> Window -> Devices and Simulators -> View Device Logs
   551	```
   552	
   553	#### Bildirimler Görünmüyor
   554	1. Bildirim izinlerini kontrol edin
   555	2. FCM token'ın veritabanına kaydedildiğini doğrulayın
   556	3. Supabase Realtime bağlantısını kontrol edin
   557	4. Android için notification channel ayarlarını kontrol edin
   558	
   559	### Test Etme
   560	
   561	#### 1. Manuel Token Test
   562	```dart
   563	// Test için token'ı debug console'da görüntüleme
   564	final token = await NotificationService().getDeviceToken();
   565	print('FCM Token: $token');
   566	```
   567	
   568	#### 2. Supabase Realtime Test
   569	SQL Editor'de manuel status güncelleme:
   570	```sql
   571	UPDATE service_requests 
   572	SET status = 'accepted' 
   573	WHERE id = 'your-request-id';
   574	```
   575	
   576	#### 3. Local Notification Test
   577	```dart
   578	// Test bildirimi gösterme
   579	await NotificationService().showNotification(
   580	  title: 'Test Bildirimi',
   581	  body: 'Bu bir test bildirimidir',
   582	);
   583	```
   584	
   585	### Üretim İçin Kontrol Listesi
   586	
   587	- [ ] Gerçek Firebase projesi oluşturuldu
   588	- [ ] `google-services.json` dosyası gerçek config ile değiştirildi
   589	- [ ] `GoogleService-Info.plist` dosyası gerçek config ile değiştirildi
   590	- [ ] Firebase Console'da iOS APNs sertifikası yüklendi (iOS için)
   591	- [ ] Production keystore SHA-1 fingerprint Firebase'e eklendi (Android için)
   592	- [ ] Google Maps API keys gerçek değerlerle değiştirildi
   593	- [ ] Bildirim izinleri test edildi
   594	- [ ] Background/terminated notification handling test edildi
   595	- [ ] Supabase Realtime bağlantısı test edildi
   596	
   597	### İleri Seviye: FCM Server-Side Gönderimi (Opsiyonel)
   598	
   599	Şu anda bildirimler client-side (Supabase Realtime) ile çalışıyor. Server-side bildirim göndermek için:
   600	
   601	1. Firebase Admin SDK kurulumu (Backend'de)
   602	2. Supabase Edge Function oluşturma
   603	3. Database trigger ile otomatik bildirim gönderimi
   604	
   605	Detaylar için [Firebase Admin SDK Docs](https://firebase.google.com/docs/admin/setup) incelenebilir.
   606	
   607	## 📱 Platform Desteği
   608	
   609	- ✅ Android
   610	- ✅ iOS
   611	- ⏳ Web (Gelecek destek planlanıyor)
   612	
   613	## 🚧 Geliştirme Durumu
   614	
   615	### Tamamlanan ✅
   616	- Proje iskelet yapısı
   617	- Temel tema ve routing
   618	- Veritabanı şeması
   619	- Kimlik doğrulama akışı (Phone + OTP)
   620	- Onboarding ekranı
   621	- Dashboard layout
   622	- Hizmet seçimi ve talep oluşturma
   623	- Mock ödeme sistemi
   624	- Müşteri geçmiş talepleri
   625	- Değerlendirme sistemi
   626	- FCM push notifications (Placeholder config ile)
   627	
   628	### Devam Eden 🔄
   629	- Supabase entegrasyonu (auth, database) - Tamamlandı
   630	- Google Maps entegrasyonu - Devam ediyor
   631	- Gerçek zamanlı güncellemeler - Devam ediyor
   632	
   633	### Planlanan 📋
   634	- Gerçek ödeme gateway entegrasyonu
   635	- Hizmet sağlayıcı (Provider) özellikleri
   636	- Admin panel
   637	- Çoklu dil desteği (İngilizce)
   638	- Web desteği
   639	
   640	## 🧪 Test
   641	
   642	```bash
   643	# Tüm testleri çalıştır
   644	flutter test
   645	
   646	# Test kapsamı raporu
   647	flutter test --coverage
   648	```
   649	
   650	## 🏗️ Build
   651	
   652	### Android APK
   653	```bash
   654	flutter build apk --release
   655	```
   656	
   657	### Android App Bundle (Google Play için)
   658	```bash
   659	flutter build appbundle --release
   660	```
   661	
   662	### iOS
   663	```bash
   664	flutter build ios --release
   665	```
   666	
   667	## 🤝 Katkıda Bulunma
   668	
   669	1. Fork yapın
   670	2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
   671	3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
   672	4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
   673	5. Pull Request açın
   674	
   675	## 📄 Lisans
   676	
   677	Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.
   678	
   679	## 📞 İletişim
   680	
   681	Proje Sahibi - [@your-username](https://github.com/your-username)
   682	
   683	Proje Linki: [https://github.com/your-username/yardimyolda](https://github.com/your-username/yardimyolda)
   684	
   685	## 🙏 Teşekkürler
   686	
   687	- [Flutter](https://flutter.dev)
   688	- [Supabase](https://supabase.com)
   689	- [Riverpod](https://riverpod.dev)
   690	- [Google Maps](https://developers.google.com/maps)
   691	
   692	---
   693	
   694	**Not:** Bu proje aktif geliştirme aşamasındadır. Üretim ortamında kullanmadan önce tüm özelliklerin test edilmesi önerilir.
   695	