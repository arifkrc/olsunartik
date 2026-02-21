class ReworkForm {
  final int? id;
  final int urunId;
  final String? urunKodu; // Opsiyonel referans olarak tutabiliriz UI'da göstermek için (API'ye Bulk payload'da gönderilmiyor, response'da geliyor)
  final String? urunAdi; // API response'da geliyor, local gösterim için saklanabilir
  final int adet;
  final int retKoduId;
  final String sarjNo;
  final String sonuc;
  final String? aciklama; // API beklemiyor ama lokal taslaklarda / UI state'te tutmak için
  final DateTime? kayitTarihi; // API'nin 'olusturmaZamani' vb., bulk'ta request ile yollamıyoruz

  ReworkForm({
    this.id,
    required this.urunId,
    this.urunKodu,
    this.urunAdi,
    required this.adet,
    required this.retKoduId,
    required this.sarjNo,
    required this.sonuc,
    this.aciklama,
    this.kayitTarihi,
  });
}
