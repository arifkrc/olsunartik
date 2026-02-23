class SAFBRequestDto {
  final int urunId; // Default 303
  final int tezgahId;
  final int duzceAdet;
  final int almanyaAdet;
  final int reworkAdet;
  final List<SAFBRetDetayDto> retDetaylari;
  final String? aciklama;

  SAFBRequestDto({
    required this.urunId,
    required this.tezgahId,
    required this.duzceAdet,
    required this.almanyaAdet,
    required this.reworkAdet,
    required this.retDetaylari,
    this.aciklama,
  });

  Map<String, dynamic> toJson() {
    return {
      'urunId': urunId,
      'tezgahId': tezgahId,
      'duzceAdet': duzceAdet,
      'almanyaAdet': almanyaAdet,
      'reworkAdet': reworkAdet,
      'retDetaylari': retDetaylari.map((e) => e.toJson()).toList(),
      if (aciklama != null && aciklama!.isNotEmpty) 'aciklama': aciklama,
    };
  }
}

class SAFBRetDetayDto {
  final int retKoduId;
  final String? retKodu;
  final int retAdet;

  SAFBRetDetayDto({
    required this.retKoduId,
    this.retKodu,
    required this.retAdet,
  });

  Map<String, dynamic> toJson() {
    return {
      'retKoduId': retKoduId,
      if (retKodu != null) 'retKodu': retKodu,
      'retAdet': retAdet,
    };
  }
}
class SAFBResponseDto {
  final int id;
  final DateTime islemTarihi;
  final int? vardiyaId;
  final String? vardiyaAdi;
  final int urunId;
  final String? urunKodu;
  final int duzceSayac;
  final int almanyaSayac;
  final int retAdet;
  final String? aciklama;
  final int? kullaniciId;
  final String? kullaniciAdi;

  SAFBResponseDto({
    required this.id,
    required this.islemTarihi,
    this.vardiyaId,
    this.vardiyaAdi,
    required this.urunId,
    this.urunKodu,
    required this.duzceSayac,
    required this.almanyaSayac,
    required this.retAdet,
    this.aciklama,
    this.kullaniciId,
    this.kullaniciAdi,
  });

  factory SAFBResponseDto.fromJson(Map<String, dynamic> json) {
    return SAFBResponseDto(
      id: json['id'] as int? ?? 0,
      islemTarihi: json['islemTarihi'] != null 
          ? DateTime.parse(json['islemTarihi']) 
          : DateTime.now(),
      vardiyaId: json['vardiyaId'] as int?,
      vardiyaAdi: json['vardiyaAdi'] as String?,
      urunId: json['urunId'] as int? ?? 0,
      urunKodu: json['urunKodu'] as String?,
      duzceSayac: json['duzceSayac'] as int? ?? 0,
      almanyaSayac: json['almanyaSayac'] as int? ?? 0,
      retAdet: json['retAdet'] as int? ?? 0,
      aciklama: json['aciklama'] as String?,
      kullaniciId: json['kullaniciId'] as int?,
      kullaniciAdi: json['kullaniciAdi'] as String?,
    );
  }
}
