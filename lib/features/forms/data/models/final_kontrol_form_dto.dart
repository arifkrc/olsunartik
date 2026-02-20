import '../../domain/entities/final_kontrol_form.dart';

class FinalKontrolItemDto extends FinalKontrolItem {
  FinalKontrolItemDto({
    required super.islemTipi,
    required super.adet,
    super.retKoduId,
    super.aciklama,
  });

  Map<String, dynamic> toJson() {
    return {
      'islemTipi': islemTipi,
      'adet': adet,
      if (retKoduId != null) 'retKoduId': retKoduId,
      if (aciklama != null) 'aciklama': aciklama,
    };
  }
}

class FinalKontrolRequestDto {
  final int urunId;
  final String paletIzlenebilirlikNo;
  final List<FinalKontrolItemDto> items;

  FinalKontrolRequestDto({
    required this.urunId,
    required this.paletIzlenebilirlikNo,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'urunId': urunId,
      'paletIzlenebilirlikNo': paletIzlenebilirlikNo,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class FinalKontrolResponseItemDto {
  final int id;
  final DateTime islemTarihi;
  final int vardiyaId;
  final String? vardiyaAdi;
  final String? musteriAdi;
  final int urunId;
  final String? paletIzlenebilirlikNo;
  final String? paletNo;
  final int islemTipi;
  final int adet;
  final int paketAdet;
  final int reworkAdet;
  final int? retKoduId;
  final String? retKodu;
  final int retAdet;
  final String? aciklama;
  final int kullaniciId;
  final String? kullaniciAdi;

  FinalKontrolResponseItemDto({
    required this.id,
    required this.islemTarihi,
    required this.vardiyaId,
    this.vardiyaAdi,
    this.musteriAdi,
    required this.urunId,
    this.paletIzlenebilirlikNo,
    this.paletNo,
    required this.islemTipi,
    required this.adet,
    required this.paketAdet,
    required this.reworkAdet,
    this.retKoduId,
    this.retKodu,
    required this.retAdet,
    this.aciklama,
    required this.kullaniciId,
    this.kullaniciAdi,
  });

  factory FinalKontrolResponseItemDto.fromJson(Map<String, dynamic> json) {
    return FinalKontrolResponseItemDto(
      id: json['id'] as int? ?? 0,
      islemTarihi: json['islemTarihi'] != null 
          ? DateTime.parse(json['islemTarihi']) 
          : DateTime.now(),
      vardiyaId: json['vardiyaId'] as int? ?? 0,
      vardiyaAdi: json['vardiyaAdi'] as String?,
      musteriAdi: json['musteriAdi'] as String?,
      urunId: json['urunId'] as int? ?? 0,
      paletIzlenebilirlikNo: json['paletIzlenebilirlikNo'] as String?,
      paletNo: json['paletNo'] as String?,
      islemTipi: json['islemTipi'] as int? ?? 0,
      adet: json['adet'] as int? ?? 0,
      paketAdet: json['paketAdet'] as int? ?? 0,
      reworkAdet: json['reworkAdet'] as int? ?? 0,
      retKoduId: json['retKoduId'] as int?,
      retKodu: json['retKodu'] as String?,
      retAdet: json['retAdet'] as int? ?? 0,
      aciklama: json['aciklama'] as String?,
      kullaniciId: json['kullaniciId'] as int? ?? 0,
      kullaniciAdi: json['kullaniciAdi'] as String?,
    );
  }
}

class FinalKontrolBulkResponseDto {
  final int totalRequested;
  final int successCount;
  final int failureCount;
  final List<FinalKontrolResponseItemDto> successfulItems;
  final List<String> errors;

  FinalKontrolBulkResponseDto({
    required this.totalRequested,
    required this.successCount,
    required this.failureCount,
    required this.successfulItems,
    required this.errors,
  });

  factory FinalKontrolBulkResponseDto.fromJson(Map<String, dynamic> json) {
    // API sometimes nests this under 'data' property
    final Map<String, dynamic> dataJson = json.containsKey('data') && json['data'] is Map
        ? json['data'] as Map<String, dynamic>
        : json;

    return FinalKontrolBulkResponseDto(
      totalRequested: dataJson['totalRequested'] as int? ?? 0,
      successCount: dataJson['successCount'] as int? ?? 0,
      failureCount: dataJson['failureCount'] as int? ?? 0,
      successfulItems: (dataJson['successfulItems'] as List<dynamic>?)
              ?.map((item) => FinalKontrolResponseItemDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      errors: (dataJson['errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
