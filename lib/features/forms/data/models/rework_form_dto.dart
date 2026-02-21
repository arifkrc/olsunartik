import '../../domain/entities/rework_form.dart';

class ReworkFormDto extends ReworkForm {
  ReworkFormDto({
    super.id,
    required super.urunId,
    super.urunKodu,
    super.urunAdi,
    required super.adet,
    required super.retKoduId,
    required super.sarjNo,
    required super.sonuc,
    super.aciklama,
    super.kayitTarihi,
  });

  /// API response'dan okurken kullanılır
  factory ReworkFormDto.fromJson(Map<String, dynamic> json) {
    return ReworkFormDto(
      id: json['id'] as int?,
      urunId: json['urunId'] as int,
      urunKodu: json['urunKodu'] as String?,
      urunAdi: json['urunAdi'] as String?,
      adet: json['adet'] as int,
      retKoduId: json['retKoduId'] as int,
      sarjNo: json['sarjNo'] as String,
      sonuc: json['sonuc'] as String,
      kayitTarihi: json['olusturmaZamani'] != null
          ? DateTime.parse(json['olusturmaZamani'] as String)
          : null,
    );
  }

  /// Bulk POST request body elemanı olarak dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'urunId': urunId,
      'adet': adet,
      'retKoduId': retKoduId,
      'sarjNo': sarjNo,
      'sonuc': sonuc,
    };
  }

  ReworkForm toEntity() {
    return ReworkForm(
      id: id,
      urunId: urunId,
      urunKodu: urunKodu,
      urunAdi: urunAdi,
      adet: adet,
      retKoduId: retKoduId,
      sarjNo: sarjNo,
      sonuc: sonuc,
      aciklama: aciklama,
      kayitTarihi: kayitTarihi,
    );
  }
}
