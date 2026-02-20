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
