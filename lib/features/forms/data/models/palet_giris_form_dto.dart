import '../../domain/entities/palet_giris_form.dart';

class PaletGirisFormDto extends PaletGirisForm {
  PaletGirisFormDto({
    super.id,
    required super.tedarikciAdi,
    required super.irsaliyeNo,
    required super.urunAdi,
    required super.nemOlcumleri,
    required super.fizikiYapiKontrol,
    required super.muhurKontrol,
    required super.irsaliyeEslestirme,
    super.aciklama,
    super.fotografYolu,
    super.kayitTarihi,
  });

  factory PaletGirisFormDto.fromJson(Map<String, dynamic> json) {
    return PaletGirisFormDto(
      id: json['id'] as int?,
      tedarikciAdi: json['tedarikciAdi'] as String,
      irsaliyeNo: json['irsaliyeNo'] as String,
      urunAdi: json['urunAdi'] as String,
      nemOlcumleri: (json['nemOlcumleri'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      fizikiYapiKontrol: json['fizikiYapiKontrol'] as int,
      muhurKontrol: json['muhurKontrol'] as int,
      irsaliyeEslestirme: json['irsaliyeEslestirme'] as int,
      aciklama: json['aciklama'] as String? ?? '',
      fotografYolu: json['fotografYolu'] as String? ?? '',
      kayitTarihi: json['olusturmaZamani'] != null
          ? DateTime.parse(json['olusturmaZamani'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tedarikciAdi': tedarikciAdi,
      'irsaliyeNo': irsaliyeNo,
      'urunAdi': urunAdi,
      'nemOlcumleri': nemOlcumleri,
      'fizikiYapiKontrol': fizikiYapiKontrol,
      'muhurKontrol': muhurKontrol,
      'irsaliyeEslestirme': irsaliyeEslestirme,
      'aciklama': aciklama,
      'fotografYolu': fotografYolu,
    };
  }

  PaletGirisForm toEntity() {
    return PaletGirisForm(
      id: id,
      tedarikciAdi: tedarikciAdi,
      irsaliyeNo: irsaliyeNo,
      urunAdi: urunAdi,
      nemOlcumleri: nemOlcumleri,
      fizikiYapiKontrol: fizikiYapiKontrol,
      muhurKontrol: muhurKontrol,
      irsaliyeEslestirme: irsaliyeEslestirme,
      aciklama: aciklama,
      fotografYolu: fotografYolu,
      kayitTarihi: kayitTarihi,
    );
  }
}
