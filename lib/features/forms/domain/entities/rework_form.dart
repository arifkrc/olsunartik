class ReworkForm {
  final int? id;
  final String urunKodu;
  final String sarjNo;
  final int miktar;
  final int islemId; // Rework işlem tipi (e.g., Yüzey Temizleme, Çapak Alma)
  final String? aciklama;
  final DateTime kayitTarihi;

  ReworkForm({
    this.id,
    required this.urunKodu,
    required this.sarjNo,
    required this.miktar,
    required this.islemId,
    this.aciklama,
    required this.kayitTarihi,
  });
}
