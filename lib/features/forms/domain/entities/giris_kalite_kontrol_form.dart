class GirisKaliteKontrolForm {
  final int? id;
  final String tedarikci;
  final String urunKodu;
  final String lotNo;
  final int miktar;
  final bool kabul;
  final String? retNedeni;
  final String? aciklama;
  final String? birim;
  final DateTime kayitTarihi;

  GirisKaliteKontrolForm({
    this.id,
    required this.tedarikci,
    required this.urunKodu,
    required this.lotNo,
    required this.miktar,
    required this.kabul,
    this.retNedeni,
    this.aciklama,
    this.birim,
    required this.kayitTarihi,
  });
}
