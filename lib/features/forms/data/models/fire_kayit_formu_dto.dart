import '../../domain/entities/fire_kayit_formu.dart';

class FireKayitRequestDto {
  final DateTime islemTarihi;
  final int urunId;
  final String? sarjNo;
  final int tezgahId;
  final int tespitEdilenTezgahId;
  final int tespitEdilenOperasyonId;
  final int malzemeDurumu;
  final int adet;
  final int operasyonId;
  final int bolgeId;
  final List<int> retKoduIds;
  final String operatorAdi;
  final String aciklama;

  FireKayitRequestDto({
    required this.islemTarihi,
    required this.urunId,
    this.sarjNo,
    required this.tezgahId,
    required this.tespitEdilenTezgahId,
    required this.tespitEdilenOperasyonId,
    required this.malzemeDurumu,
    required this.adet,
    required this.operasyonId,
    required this.bolgeId,
    required this.retKoduIds,
    required this.operatorAdi,
    required this.aciklama,
  });

  Map<String, dynamic> toJson() {
    return {
      'islemTarihi': islemTarihi.toUtc().toIso8601String(),
      'urunId': urunId,
      if (sarjNo != null) 'sarjNo': sarjNo,
      'tezgahId': tezgahId,
      'tespitEdilenTezgahId': tespitEdilenTezgahId,
      'tespitEdilenOperasyonId': tespitEdilenOperasyonId,
      'malzemeDurumu': malzemeDurumu,
      'adet': adet,
      'operasyonId': operasyonId,
      'bolgeId': bolgeId,
      'retKoduIds': retKoduIds,
      'operatorAdi': operatorAdi,
      'aciklama': aciklama,
    };
  }
}

class FireKayitResponseDto {
  final int id;
  final int? vardiyaId;
  final String? vardiyaAdi;
  final DateTime islemTarihi;
  final int urunId;
  final String? urunKodu;
  final String? urunAdi;
  final String? sarjNo;
  final int? tezgahId;
  final String? tezgahNo;
  final int? tespitEdilenTezgahId;
  final String? tespitEdilenTezgahNo;
  final int? tespitEdilenOperasyonId;
  final String? tespitEdilenOperasyonAdi;
  final int malzemeDurumu;
  final int adet;
  final int? operasyonId;
  final String? operasyonAdi;
  final int? bolgeId;
  final String? bolgeAdi;
  final List<int> retKoduIds;
  final String? operatorAdi;
  final String? aciklama;
  final String? fotografYolu;

  FireKayitResponseDto({
    required this.id,
    this.vardiyaId,
    this.vardiyaAdi,
    required this.islemTarihi,
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
  });

  factory FireKayitResponseDto.fromJson(Map<String, dynamic> json) {
    // retKodlari map'inden sadece ID'leri alıp UI'da işleyecek şekilde sadeliştiriyoruz
    List<int> retKoduList = [];
    if (json['retKodlari'] != null && json['retKodlari'] is List) {
      retKoduList = (json['retKodlari'] as List)
          .map((e) => e['id'] as int)
          .toList();
    }

    return FireKayitResponseDto(
      id: json['id'] as int,
      vardiyaId: json['vardiyaId'] as int?,
      vardiyaAdi: json['vardiyaAdi'] as String?,
      islemTarihi: DateTime.parse(json['islemTarihi'] as String),
      urunId: json['urunId'] as int,
      urunKodu: json['urunKodu'] as String?,
      urunAdi: json['urunAdi'] as String?,
      sarjNo: json['sarjNo'] as String?,
      tezgahId: json['tezgahId'] as int?,
      tezgahNo: json['tezgahNo'] as String?,
      tespitEdilenTezgahId: json['tespitEdilenTezgahId'] as int?,
      tespitEdilenTezgahNo: json['tespitEdilenTezgahNo'] as String?,
      tespitEdilenOperasyonId: json['tespitEdilenOperasyonId'] as int?,
      tespitEdilenOperasyonAdi: json['tespitEdilenOperasyonAdi'] as String?,
      malzemeDurumu: json['malzemeDurumu'] as int? ?? 1,
      adet: json['adet'] as int,
      operasyonId: json['operasyonId'] as int?,
      operasyonAdi: json['operasyonAdi'] as String?,
      bolgeId: json['bolgeId'] as int?,
      bolgeAdi: json['bolgeAdi'] as String?,
      retKoduIds: retKoduList,
      operatorAdi: json['operatorAdi'] as String?,
      aciklama: json['aciklama'] as String?,
      fotografYolu: json['fotografYolu'] as String?,
    );
  }

  FireKayitFormu toEntity() {
    return FireKayitFormu(
      id: id,
      islemTarihi: islemTarihi,
      vardiyaId: vardiyaId,
      vardiyaAdi: vardiyaAdi,
      urunId: urunId,
      urunKodu: urunKodu,
      urunAdi: urunAdi,
      sarjNo: sarjNo,
      tezgahId: tezgahId,
      tezgahNo: tezgahNo,
      tespitEdilenTezgahId: tespitEdilenTezgahId,
      tespitEdilenTezgahNo: tespitEdilenTezgahNo,
      tespitEdilenOperasyonId: tespitEdilenOperasyonId,
      tespitEdilenOperasyonAdi: tespitEdilenOperasyonAdi,
      malzemeDurumu: malzemeDurumu,
      adet: adet,
      operasyonId: operasyonId,
      operasyonAdi: operasyonAdi,
      bolgeId: bolgeId,
      bolgeAdi: bolgeAdi,
      retKoduIds: retKoduIds,
      operatorAdi: operatorAdi,
      aciklama: aciklama,
      fotografYolu: fotografYolu,
      kullaniciId: null, // response'da gelmese de olabilir
    );
  }
}
