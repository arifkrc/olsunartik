import '../../domain/entities/numune_form.dart';

class NumuneFormDto extends NumuneForm {
  NumuneFormDto({
    super.id,
    required super.urunKodu,
    required super.urunAdi,
    required super.urunTuru,
    required super.adet,
    required super.testSonucu,
    super.aciklama,
    required super.kayitTarihi,
  });

  factory NumuneFormDto.fromJson(Map<String, dynamic> json) {
    return NumuneFormDto(
      id: json['id'] as int?,
      urunKodu: json['urunKodu'] as String,
      urunAdi: json['urunAdi'] as String,
      urunTuru: json['urunTuru'] as String,
      adet: json['adet'] as int,
      testSonucu: json['testSonucu'] as String,
      aciklama: json['aciklama'] as String?,
      kayitTarihi: DateTime.parse(json['kayitTarihi'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'urunKodu': urunKodu,
      'urunAdi': urunAdi,
      'urunTuru': urunTuru,
      'adet': adet,
      'testSonucu': testSonucu,
      if (aciklama != null) 'aciklama': aciklama,
      'kayitTarihi': kayitTarihi.toIso8601String(),
    };
  }

  NumuneForm toEntity() {
    return NumuneForm(
      id: id,
      urunKodu: urunKodu,
      urunAdi: urunAdi,
      urunTuru: urunTuru,
      adet: adet,
      testSonucu: testSonucu,
      aciklama: aciklama,
      kayitTarihi: kayitTarihi,
    );
  }
}
