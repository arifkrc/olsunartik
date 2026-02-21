class PaletGirisForm {
  final int? id;
  final String tedarikciAdi;
  final String irsaliyeNo;
  final String urunAdi;
  final List<int> nemOlcumleri;
  final int fizikiYapiKontrol;
  final int muhurKontrol;
  final int irsaliyeEslestirme;
  final String aciklama;
  final String fotografYolu;
  final DateTime? kayitTarihi;

  PaletGirisForm({
    this.id,
    required this.tedarikciAdi,
    required this.irsaliyeNo,
    required this.urunAdi,
    required this.nemOlcumleri,
    required this.fizikiYapiKontrol,
    required this.muhurKontrol,
    required this.irsaliyeEslestirme,
    this.aciklama = '',
    this.fotografYolu = '',
    this.kayitTarihi,
  });
}
