class VardiyaNotu {
  final int id;
  final int vardiyaId;
  final String vardiyaAdi;
  final String baslik;
  final String notMetni;
  final int oncelikDerecesi;
  final int kullaniciId;
  final String kullaniciAdi;
  final String personelAdi;
  final DateTime olusturmaZamani;
  final DateTime guncellemeZamani;

  VardiyaNotu({
    required this.id,
    required this.vardiyaId,
    required this.vardiyaAdi,
    required this.baslik,
    required this.notMetni,
    required this.oncelikDerecesi,
    required this.kullaniciId,
    required this.kullaniciAdi,
    required this.personelAdi,
    required this.olusturmaZamani,
    required this.guncellemeZamani,
  });
}
