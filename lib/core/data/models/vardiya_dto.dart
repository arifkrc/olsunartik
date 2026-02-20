import '../../domain/entities/vardiya.dart';

class VardiyaDto extends Vardiya {
  VardiyaDto({
    required super.id,
    required super.vardiyaAdi,
    required super.baslangicSaati,
    required super.bitisSaati,
  });

  factory VardiyaDto.fromJson(Map<String, dynamic> json) {
    return VardiyaDto(
      id: json['id'] as int,
      vardiyaAdi: json['vardiyaAdi'] as String,
      baslangicSaati: json['baslangicSaati'] as String,
      bitisSaati: json['bitisSaati'] as String,
    );
  }
}
