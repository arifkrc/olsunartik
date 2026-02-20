import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Beyaz & Kırmızı Tema
  static const Color primary = Color(
    0xFFD6001A,
  ); // Frenbu Kırmızı - Ana vurgu rengi
  static const Color primaryLight = Color(0xFFE53935); // Açık kırmızı
  static const Color primaryDark = Color(0xFFB71C1C); // Koyu kırmızı
  static const Color secondary = Color(0xFFFFFFFF); // Beyaz - İkincil vurgu
  static const Color accent = Color(0xFFD6001A); // Kırmızı aksan

  // Dark Theme - Arka Plan
  static const Color background = Color(0xFF1A1A1D); // Koyu antrasit zemin
  static const Color backgroundLight = Color(0xFF242428); // Biraz açık antrasit
  static const Color surface = Color(0xFF2D2D32); // Kart yüzeyleri
  static const Color surfaceLight = Color(0xFF3D3D44); // Hover durumu için

  // Glassmorphism Efektleri
  static const Color glassWhite = Color(0x1AFFFFFF); // %10 beyaz overlay
  static const Color glassBorder = Color(0x33FFFFFF); // %20 beyaz border
  static const Color glassHighlight = Color(0x0DFFFFFF); // %5 subtle highlight
  static const Color glassRed = Color(0x1AD6001A); // %10 kırmızı overlay

  // Semantic Colors - Beyaz & Kırmızı Tonları
  static const Color success = Color(0xFF4CAF50); // Yeşil (Onay/Başarı)
  static const Color error = Color(0xFFD6001A); // Frenbu Kırmızı (Hata/Hurda)
  static const Color warning = Color(0xFFE57373); // Açık kırmızı (Uyarı)
  static const Color info = Color(0xFFF5F5F5); // Açık beyaz (Bilgi)

  // Üretim Sayaç Renkleri
  static const Color duzceGreen = Color(0xFF4CAF50); // Yeşil - Düzce
  static const Color almanyaBlue = Color(0xFF2196F3); // Mavi - Almanya
  static const Color reworkOrange = Color(
    0xFFFF6900,
  ); // Turuncu - Rework (Revize 2)

  // Status Çizgisi Renkleri (Kart sol kenarı için)
  static const Color statusValid = Color(0xFFFFFFFF); // Beyaz - Geçerli
  static const Color statusInvalid = Color(0xFFD6001A); // Kırmızı - Geçersiz
  static const Color statusPending = Color(
    0xFFE57373,
  ); // Açık kırmızı - Beklemede

  // Neutral Colors - Dark Theme
  static const Color border = Color(0xFF404048);
  static const Color borderLight = Color(0x33FFFFFF); // Beyaz border vurgusu
  static const Color textMain = Color(0xFFFFFFFF); // Saf beyaz metin
  static const Color textSecondary = Color(0xFFE0E0E0); // Gri-beyaz metin
  static const Color textLight = Color(0xFFBDBDBD); // Soluk beyaz metin
  static const Color textRed = Color(0xFFD6001A); // Kırmızı metin vurgusu

  // Eski uyumluluk için
  static const Color cardBackground = surface;
}
