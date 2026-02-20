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
