import '../../domain/entities/palet_giris_form.dart';

class PaletGirisFormDto extends PaletGirisForm {
  PaletGirisFormDto({
    super.id,
    required super.paletNo,
    required super.tedarikci,
    required super.urunKodu,
    required super.miktar,
    required super.durum,
    super.hasar,
    required super.kayitTarihi,
  });

  factory PaletGirisFormDto.fromJson(Map<String, dynamic> json) {
    return PaletGirisFormDto(
      id: json['id'] as int?,
      paletNo: json['paletNo'] as String,
      tedarikci: json['tedarikci'] as String,
      urunKodu: json['urunKodu'] as String,
      miktar: json['miktar'] as int,
      durum: json['durum'] as String,
      hasar: json['hasar'] as String?,
      kayitTarihi: DateTime.parse(json['kayitTarihi'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'paletNo': paletNo,
      'tedarikci': tedarikci,
      'urunKodu': urunKodu,
      'miktar': miktar,
      'durum': durum,
      if (hasar != null) 'hasar': hasar,
      'kayitTarihi': kayitTarihi.toIso8601String(),
    };
  }

  PaletGirisForm toEntity() {
    return PaletGirisForm(
      id: id,
      paletNo: paletNo,
      tedarikci: tedarikci,
      urunKodu: urunKodu,
      miktar: miktar,
      durum: durum,
      hasar: hasar,
      kayitTarihi: kayitTarihi,
    );
  }
}
