import 'package:freezed_annotation/freezed_annotation.dart';

part 'uretim_bilgisi_bulk_dto.freezed.dart';
part 'uretim_bilgisi_bulk_dto.g.dart';

@freezed
abstract class UretimBilgisiBulkRequestDto with _$UretimBilgisiBulkRequestDto {
  const factory UretimBilgisiBulkRequestDto({
    required List<UretimBilgisiBulkItemDto> kayitlar,
  }) = _UretimBilgisiBulkRequestDto;

  factory UretimBilgisiBulkRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UretimBilgisiBulkRequestDtoFromJson(json);
}

@freezed
abstract class UretimBilgisiBulkItemDto with _$UretimBilgisiBulkItemDto {
  const factory UretimBilgisiBulkItemDto({
    required String uretimTarihi,
    required int urunId,
    required String dokumhaneAdi,
    required int uretimAdeti,
    int? delikAdeti,
  }) = _UretimBilgisiBulkItemDto;

  factory UretimBilgisiBulkItemDto.fromJson(Map<String, dynamic> json) =>
      _$UretimBilgisiBulkItemDtoFromJson(json);
}


