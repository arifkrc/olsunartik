import '../../domain/entities/giris_kalite_kontrol_form.dart';

class GirisKaliteKontrolFormDto extends GirisKaliteKontrolForm {
  GirisKaliteKontrolFormDto({
    super.id,
    required super.tedarikci,
    required super.urunKodu,
    required super.lotNo,
    required super.miktar,
    required super.kabul,
    super.retNedeni,
    super.aciklama,
    required super.kayitTarihi,
  });

  factory GirisKaliteKontrolFormDto.fromJson(Map<String, dynamic> json) {
    return GirisKaliteKontrolFormDto(
      id: json['id'] as int?,
      tedarikci: json['tedarikci'] as String,
      urunKodu: json['urunKodu'] as String,
      lotNo: json['lotNo'] as String,
      miktar: json['miktar'] as int,
      kabul: json['kabul'] is bool 
          ? json['kabul'] as bool 
          : json['kabul'].toString().toLowerCase() == 'kabul' || json['kabul'].toString().toLowerCase() == 'true',
      retNedeni: json['retNedeni'] as String?,
      aciklama: json['aciklama'] as String?,
      kayitTarihi: DateTime.parse(json['kayitTarihi'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tedarikci': tedarikci,
      'urunKodu': urunKodu,
      'lotNo': lotNo,
      'miktar': miktar,
      'kabul': kabul,
      if (retNedeni != null) 'retNedeni': retNedeni,
      if (aciklama != null) 'aciklama': aciklama,
      'kayitTarihi': kayitTarihi.toUtc().toIso8601String(),
    };
  }

  GirisKaliteKontrolForm toEntity() {
    return GirisKaliteKontrolForm(
      id: id,
      tedarikci: tedarikci,
      urunKodu: urunKodu,
      lotNo: lotNo,
      miktar: miktar,
      kabul: kabul,
      retNedeni: retNedeni,
      aciklama: aciklama,
      kayitTarihi: kayitTarihi,
    );
  }
}
