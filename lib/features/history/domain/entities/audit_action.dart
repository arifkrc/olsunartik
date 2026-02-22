class AuditAction {
  final int id;
  final int kullaniciId;
  final String kullaniciAdi;
  final String aksiyonTipi;
  final String varlikTipi;
  final int varlikId;
  final String aciklama;
  final String? eskiDeger;
  final String? yeniDeger;
  final String ipAdresi;
  final DateTime islemZamani;

  AuditAction({
    required this.id,
    required this.kullaniciId,
    required this.kullaniciAdi,
    required this.aksiyonTipi,
    required this.varlikTipi,
    required this.varlikId,
    required this.aciklama,
    this.eskiDeger,
    this.yeniDeger,
    required this.ipAdresi,
    required this.islemZamani,
  });
}
