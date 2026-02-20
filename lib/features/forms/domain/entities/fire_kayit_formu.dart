class FireKayitFormu {
  final int id;
  final DateTime islemTarihi;
  final int? vardiyaId;
  final String? vardiyaAdi;
  final int urunId;
  final String? urunKodu;
  final String? urunAdi;
  final String? sarjNo;
  final int? tezgahId;
  final String? tezgahNo;
  
  // Yeni eklenen alanlar
  final int? tespitEdilenTezgahId;
  final String? tespitEdilenTezgahNo;
  final int? tespitEdilenOperasyonId;
  final String? tespitEdilenOperasyonAdi;
  final int malzemeDurumu; // 1 = Ham, 2 = İşlenmiş
  final int adet;
  
  final int? operasyonId;
  final String? operasyonAdi;
  final int? bolgeId;
  final String? bolgeAdi;
  
  // RetKoduIds (Request) ve RetKodlari (Response) 
  // Response üzerinden sadeleştirilmiş hali
  final List<int> retKoduIds; 
  final String? operatorAdi;
  final String? aciklama;
  final String? fotografYolu;
  final int? kullaniciId;

  FireKayitFormu({
    required this.id,
    required this.islemTarihi,
    this.vardiyaId,
    this.vardiyaAdi,
    required this.urunId,
    this.urunKodu,
    this.urunAdi,
    this.sarjNo,
    this.tezgahId,
    this.tezgahNo,
    this.tespitEdilenTezgahId,
    this.tespitEdilenTezgahNo,
    this.tespitEdilenOperasyonId,
    this.tespitEdilenOperasyonAdi,
    required this.malzemeDurumu,
    required this.adet,
    this.operasyonId,
    this.operasyonAdi,
    this.bolgeId,
    this.bolgeAdi,
    required this.retKoduIds,
    this.operatorAdi,
    this.aciklama,
    this.fotografYolu,
    this.kullaniciId,
  });
}
