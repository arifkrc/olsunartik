import '../../domain/entities/numune_form.dart';

class NumuneFormDto extends NumuneForm {
  NumuneFormDto({
    super.id,
    required super.urunId,
    super.urunKodu,
    super.urunAdi,
    super.urunTuru,
    required super.adet,
    required super.sarjNo,
    required super.numuneBasligi,
    required super.genelSonuc,
    super.gorsel = '',
    super.kayitTarihi,
  });

  factory NumuneFormDto.fromJson(Map<String, dynamic> json) {
    return NumuneFormDto(
      id: json['id'] as int?,
      urunId: json['urunId'] as int,
      urunKodu: json['urunKodu'] as String?,
      urunAdi: json['urunAdi'] as String?,
      urunTuru: json['urunTuru'] as String?,
      adet: json['adet'] as int,
      sarjNo: json['sarjNo'] as String,
      numuneBasligi: json['numuneBasligi'] as String,
      genelSonuc: json['genelSonuc'] as String,
      gorsel: json['gorsel'] as String? ?? '',
      kayitTarihi: json['olusturmaZamani'] != null
          ? DateTime.parse(json['olusturmaZamani'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urunId': urunId,
      'adet': adet,
      'sarjNo': sarjNo,
      'numuneBasligi': numuneBasligi,
      'genelSonuc': genelSonuc,
      'gorsel': gorsel,
    };
  }

  NumuneForm toEntity() {
    return NumuneForm(
      id: id,
      urunId: urunId,
      urunKodu: urunKodu,
      urunAdi: urunAdi,
      urunTuru: urunTuru,
      adet: adet,
      sarjNo: sarjNo,
      numuneBasligi: numuneBasligi,
      genelSonuc: genelSonuc,
      gorsel: gorsel,
      kayitTarihi: kayitTarihi,
    );
  }
}
