class FinalKontrolItem {
  final int islemTipi;
  final int adet;
  final int? retKoduId;
  final String? aciklama;

  FinalKontrolItem({
    required this.islemTipi,
    required this.adet,
    this.retKoduId,
    this.aciklama,
  });
}

class FinalKontrolForm {
  final int urunId;
  final String paletIzlenebilirlikNo;
  final List<FinalKontrolItem> items;

  FinalKontrolForm({
    required this.urunId,
    required this.paletIzlenebilirlikNo,
    required this.items,
  });
}

class FinalKontrolRecord {
  final int id;
  final DateTime islemTarihi;
  final int vardiyaId;
  final String? vardiyaAdi;
  final String? musteriAdi;
  final int urunId;
  final String? urunKodu; // Added for convenience in UI
  final String? paletIzlenebilirlikNo;
  final String? paletNo;
  final int islemTipi;
  final int adet;
  final int paketAdet;
  final int reworkAdet;
  final int? retKoduId;
  final String? retKodu;
  final int retAdet;
  final String? aciklama;
  final int kullaniciId;
  final String? kullaniciAdi;

  FinalKontrolRecord({
    required this.id,
    required this.islemTarihi,
    required this.vardiyaId,
    this.vardiyaAdi,
    this.musteriAdi,
    required this.urunId,
    this.urunKodu,
    this.paletIzlenebilirlikNo,
    this.paletNo,
    required this.islemTipi,
    required this.adet,
    required this.paketAdet,
    required this.reworkAdet,
    this.retKoduId,
    this.retKodu,
    required this.retAdet,
    this.aciklama,
    required this.kullaniciId,
    this.kullaniciAdi,
  });
}
