import '../../domain/entities/measurement_instrument.dart';

class MeasurementInstrumentDto extends MeasurementInstrument {
  MeasurementInstrumentDto({
    super.id,
    required super.ad,
    required super.kod,
    required super.tip,
    required super.sonKalibrasyon,
    required super.gelecekKalibrasyon,
    required super.durum,
    super.aciklama,
  });

  factory MeasurementInstrumentDto.fromJson(Map<String, dynamic> json) {
    return MeasurementInstrumentDto(
      id: json['id'] as int?,
      ad: json['ad'] as String,
      kod: json['kod'] as String,
      tip: json['tip'] as String,
      sonKalibrasyon: DateTime.parse(json['sonKalibrasyon'] as String),
      gelecekKalibrasyon: DateTime.parse(json['gelecekKalibrasyon'] as String),
      durum: json['durum'] as String,
      aciklama: json['aciklama'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'ad': ad,
      'kod': kod,
      'tip': tip,
      'sonKalibrasyon': sonKalibrasyon.toIso8601String(),
      'gelecekKalibrasyon': gelecekKalibrasyon.toIso8601String(),
      'durum': durum,
      if (aciklama != null) 'aciklama': aciklama,
    };
  }

  MeasurementInstrument toEntity() {
    return MeasurementInstrument(
      id: id,
      ad: ad,
      kod: kod,
      tip: tip,
      sonKalibrasyon: sonKalibrasyon,
      gelecekKalibrasyon: gelecekKalibrasyon,
      durum: durum,
      aciklama: aciklama,
    );
  }
}
