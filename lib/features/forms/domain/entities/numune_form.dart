class NumuneForm {
  final int? id;
  final String urunKodu;
  final String urunAdi;
  final String urunTuru;
  final int adet;
  final String testSonucu; // 'Başarılı' or 'Başarısız'
  final String? aciklama;
  final DateTime kayitTarihi;

  NumuneForm({
    this.id,
    required this.urunKodu,
    required this.urunAdi,
    required this.urunTuru,
    required this.adet,
    required this.testSonucu,
    this.aciklama,
    required this.kayitTarihi,
  });
}
