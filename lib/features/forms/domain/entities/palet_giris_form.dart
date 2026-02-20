class PaletGirisForm {
  final int? id;
  final String paletNo;
  final String tedarikci;
  final String urunKodu;
  final int miktar;
  final String durum; // 'Uygun' or 'Hasarlı'
  final String? hasar;
  final DateTime kayitTarihi;

  PaletGirisForm({
    this.id,
    required this.paletNo,
    required this.tedarikci,
    required this.urunKodu,
    required this.miktar,
    required this.durum,
    this.hasar,
    required this.kayitTarihi,
  });
}
