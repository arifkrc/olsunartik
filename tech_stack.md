# Proje Teknoloji Raporu (Tech Stack)

Bu rapor, **QualityApp** projesinde kullanılan teknolojileri, kütüphaneleri ve mimari tercihleri belgelemektedir. Proje, modern Flutter geliştirme standartlarına uygun olarak tasarlanmıştır.

## 1. Çekirdek Teknolojiler (Core)
- **Framework**: [Flutter](https://flutter.dev/) (SDK: `^3.10.4`)
  - Cross-platform mobil uygulama geliştirme (iOS & Android).
- **Dil**: [Dart](https://dart.dev/)
  - Tip güvenli, nesne yönelimli programlama dili.

## 2. Mimari ve Durum Yönetimi (Architecture & State Management)
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod: ^3.1.0`)
  - **Generator**: `riverpod_generator` ve `riverpod_annotation` kullanılarak "Code Generation" temelli modern Riverpod yapısı benimsenmiştir. Bu sayede boilerplate code azalır ve tip güvenliği artar.
- **Mimari Desen**: **Feature-First (Özellik Bazlı) Mimari**
  - Proje, `lib/features/` altında özellik bazlı klasörlenmiştir (örn: `auth`, `forms`, `home`).
  - Her feature kendi içinde `data`, `domain`, `presentation` ve `providers` katmanlarına ayrılmıştır (Clean Architecture prensipleri).

## 3. Ağ ve Veri İletişimi (Networking)
- **HTTP Client**: [Dio](https://pub.dev/packages/dio) (`^5.9.0`)
  - REST API istekleri için gelişmiş HTTP istemcisi. Interceptor'lar ile token yönetimi ve loglama yapılmaktadır.
- **Lokal Depolama**: [Shared Preferences](https://pub.dev/packages/shared_preferences) (`^2.5.4`)
  - Basit anahtar-değer verileri (örn: Auth token) saklamak için.

## 4. Kullanıcı Arayüzü (UI & UX)
- **İkonlar**: [Lucide Icons](https://pub.dev/packages/lucide_icons) (`^0.257.0`)
  - Modern, temiz ve tutarlı ikon seti.
- **Fontlar**: [Google Fonts](https://pub.dev/packages/google_fonts) (`^7.0.2`)
  - Dinamik font yükleme yönetimi.
- **Responsive Tasarım**: [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil) (`^5.9.3`)
  - Farklı ekran boyutlarına (tablet, telefon) uyum sağlamak için ölçeklenebilir UI yapısı.
- **Grafikler**: [FL Chart](https://pub.dev/packages/fl_chart) (`^1.1.1`)
  - Dashboard ve raporlama ekranlarında verileri görselleştirmek için.

## 5. Araçlar ve Yardımcı Kütüphaneler (Utilities)
- **Medya**: [Image Picker](https://pub.dev/packages/image_picker) (`^1.2.1`)
  - Kamera ve galeriden fotoğraf seçimi (Numune ve Fire formları için).
- **Dosya İşlemleri**:
  - [File Picker](https://pub.dev/packages/file_picker) (`^10.3.8`): Dosya seçimi.
  - [Excel](https://pub.dev/packages/excel) (`^4.0.6`): Raporları Excel formatında dışa aktarmak için.
- **Uluslararasılaştırma (i18n)**: `flutter_localizations` ve `intl` (`^0.20.2`)
  - Tarih/saat formatlama ve potansiyel çoklu dil desteği altyapısı.

## 6. Geliştirme Araçları (Dev Tools)
- **Kod Üretimi**: `build_runner` (`^2.10.5`)
  - Riverpod generator ve JSON serialization gibi işlemler için.
- **Linting & Kalite**:
  - `flutter_lints` (`^6.0.0`): Standart Flutter kod kuralları.
  - **Custom Lints**: `custom_lint` & `riverpod_lint` ile Riverpod'a özel kod analiz kuralları.

---

## Özet
Proje, **Flutter + Riverpod + Dio** üçlüsü üzerine kurulmuş, **Clean Architecture** prensiplerini özellik bazlı (feature-based) bir klasör yapısıyla uygulayan, ölçeklenebilir ve bakımı kolay bir yapıdadır. UI tarafında responsive tasarım ve modern ikon setleri ile kullanıcı deneyimi ön planda tutulmuştur.
