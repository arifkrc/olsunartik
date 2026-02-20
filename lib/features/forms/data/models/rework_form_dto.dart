import '../../domain/entities/rework_form.dart';

class ReworkFormDto extends ReworkForm {
  ReworkFormDto({
    super.id,
    required super.urunKodu,
    required super.sarjNo,
    required super.miktar,
    required super.islemId,
    super.aciklama,
    required super.kayitTarihi,
  });

  factory ReworkFormDto.fromJson(Map<String, dynamic> json) {
    return ReworkFormDto(
      id: json['id'] as int?,
      urunKodu: json['urunKodu'] as String,
      sarjNo: json['sarjNo'] as String,
      miktar: json['miktar'] as int,
      islemId: json['islemId'] as int,
      aciklama: json['aciklama'] as String?,
      kayitTarihi: DateTime.parse(json['kayitTarihi'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'urunKodu': urunKodu,
      'sarjNo': sarjNo,
      'miktar': miktar,
      'islemId': islemId,
      if (aciklama != null) 'aciklama': aciklama,
      'kayitTarihi': kayitTarihi.toIso8601String(),
    };
  }

  ReworkForm toEntity() {
    return ReworkForm(
      id: id,
      urunKodu: urunKodu,
      sarjNo: sarjNo,
      miktar: miktar,
      islemId: islemId,
      aciklama: aciklama,
      kayitTarihi: kayitTarihi,
    );
  }
}
