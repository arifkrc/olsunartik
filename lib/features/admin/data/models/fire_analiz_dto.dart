import 'package:freezed_annotation/freezed_annotation.dart';

part 'fire_analiz_dto.freezed.dart';
part 'fire_analiz_dto.g.dart';

@freezed
abstract class FireAnalizDetayDto with _$FireAnalizDetayDto {
  const factory FireAnalizDetayDto({
    required int id,
    required String analizTarihi,
    required int frenbuUretimAdeti,
    required int frenbuFireAdeti,
    required double frenbuFireOrani,
    required int d2UretimAdeti,
    required int d2FireAdeti,
    required double d2FireOrani,
    required int d3UretimAdeti,
    required int d3FireAdeti,
    required double d3FireOrani,
    required int frenbuDelikAdeti,
    required int d2DelikAdeti,
    required int d3DelikAdeti,
    required int toplamDelikAdeti,
    @Default([]) List<UrunDetayiDto> urunDetaylari,
    @Default([]) List<HataDagilimiDto> hataDagilimleri,
  }) = _FireAnalizDetayDto;

  factory FireAnalizDetayDto.fromJson(Map<String, dynamic> json) =>
      _$FireAnalizDetayDtoFromJson(json);
}

@freezed
abstract class UrunDetayiDto with _$UrunDetayiDto {
  const factory UrunDetayiDto({
    required int segment, // 1: Frenbu, 2: D2, 3: D3
    required bool fireVar,
    required String urunKodu,
    required String urunTuru,
    String? urunAdi,
    required int uretimAdeti,
    required int fireAdeti,
    required double fireOrani,
    String? hataDetaylari, // Optional details
  }) = _UrunDetayiDto;

  factory UrunDetayiDto.fromJson(Map<String, dynamic> json) =>
      _$UrunDetayiDtoFromJson(json);
}

@freezed
abstract class HataDagilimiDto with _$HataDagilimiDto {
  const factory HataDagilimiDto({
    required String urunTuru, // Örneğin "Disk", "Kampana", "Porya"
    required String hataKodu,
    required int fireAdeti,
    required double fireOrani,
  }) = _HataDagilimiDto;

  factory HataDagilimiDto.fromJson(Map<String, dynamic> json) =>
      _$HataDagilimiDtoFromJson(json);
}

@freezed
abstract class FireAnalizHesaplaRequestDto with _$FireAnalizHesaplaRequestDto {
  const factory FireAnalizHesaplaRequestDto({
    required String analizTarihi,
  }) = _FireAnalizHesaplaRequestDto;

  factory FireAnalizHesaplaRequestDto.fromJson(Map<String, dynamic> json) =>
      _$FireAnalizHesaplaRequestDtoFromJson(json);
}
