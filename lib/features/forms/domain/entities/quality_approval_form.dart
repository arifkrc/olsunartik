class QualityApprovalForm {
  final int? id;
  final int urunId; // Backend'deki ürünün primary key'i
  final String urunKodu; // Görüntüleme için
  final String urunAdi; // Görüntüleme için
  final String urunTuru; // Görüntüleme için
  final int adet;
  final bool isUygun; // true = Uygun, false = RET
  final int? retKoduId;
  final String? aciklama;
  final DateTime islemTarihi; // Yetkililer düzenleyebilir, operatörler hayır

  QualityApprovalForm({
    this.id,
    required this.urunId,
    this.urunKodu = '',
    this.urunAdi = '',
    this.urunTuru = '',
    required this.adet,
    required this.isUygun,
    this.retKoduId,
    this.aciklama,
    required this.islemTarihi,
  });
}

