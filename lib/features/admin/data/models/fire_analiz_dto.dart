import 'package:freezed_annotation/freezed_annotation.dart';

part 'fire_analiz_dto.freezed.dart';
part 'fire_analiz_dto.g.dart';

@freezed
abstract class FireAnalizDetayDto with _$FireAnalizDetayDto {
  const factory FireAnalizDetayDto({
    @Default(0) int id,
    @Default('') String analizTarihi,
    @Default(0) int frenbuUretimAdeti,
    @Default(0) int frenbuFireAdeti,
    @Default(0) num frenbuFireOrani,
    @Default(0) int d2UretimAdeti,
    @Default(0) int d2FireAdeti,
    @Default(0) num d2FireOrani,
    @Default(0) int d3UretimAdeti,
    @Default(0) int d3FireAdeti,
    @Default(0) num d3FireOrani,
    @Default(0) int frenbuDelikAdeti,
    @Default(0) int d2DelikAdeti,
    @Default(0) int d3DelikAdeti,
    @Default(0) int toplamDelikAdeti,
    @Default([]) List<UrunDetayiDto> urunDetaylari,
    @Default([]) List<HataDagilimiDto> hataDagilimleri,
  }) = _FireAnalizDetayDto;

  factory FireAnalizDetayDto.fromJson(Map<String, dynamic> json) =>
      _$FireAnalizDetayDtoFromJson(json);
}

@freezed
abstract class UrunDetayiDto with _$UrunDetayiDto {
  const factory UrunDetayiDto({
    @Default(0) int segment, // 1: Frenbu, 2: D2, 3: D3
    @Default(false) bool fireVar,
    @Default('') String urunKodu,
    @Default('') String urunTuru,
    String? urunAdi,
    @Default(0) int uretimAdeti,
    @Default(0) int fireAdeti,
    @Default(0) num fireOrani,
    String? hataDetaylari, // Optional details
  }) = _UrunDetayiDto;

  factory UrunDetayiDto.fromJson(Map<String, dynamic> json) =>
      _$UrunDetayiDtoFromJson(json);
}

@freezed
abstract class HataDagilimiDto with _$HataDagilimiDto {
  const factory HataDagilimiDto({
    @Default('') String urunTuru, // Örneğin "Disk", "Kampana", "Porya"
    @Default('') String hataKodu,
    @Default(0) int fireAdeti,
    @Default(0) num fireOrani,
  }) = _HataDagilimiDto;

  factory HataDagilimiDto.fromJson(Map<String, dynamic> json) =>
      _$HataDagilimiDtoFromJson(json);
}

@freezed
abstract class FireAnalizHesaplaRequestDto with _$FireAnalizHesaplaRequestDto {
  const factory FireAnalizHesaplaRequestDto({
    required String analizTarihi,
    int? frenbuUretimAdeti,
  }) = _FireAnalizHesaplaRequestDto;

  factory FireAnalizHesaplaRequestDto.fromJson(Map<String, dynamic> json) =>
      _$FireAnalizHesaplaRequestDtoFromJson(json);
}
