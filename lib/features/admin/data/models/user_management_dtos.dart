class KullaniciDto {
  final int id;
  final String kullaniciAdi;
  final int hesapSeviyesi;
  final bool isActive;
  final DateTime kayitTarihi;
  final int? personelId;
  final String? personelAdi;
  final String? telefonNo;
  final DateTime? dogumTarihi;

  KullaniciDto({
    required this.id,
    required this.kullaniciAdi,
    required this.hesapSeviyesi,
    required this.isActive,
    required this.kayitTarihi,
    this.personelId,
    this.personelAdi,
    this.telefonNo,
    this.dogumTarihi,
  });

  factory KullaniciDto.fromJson(Map<String, dynamic> json) {
    return KullaniciDto(
      id: json['id'] as int,
      kullaniciAdi: json['kullaniciAdi'] as String,
      hesapSeviyesi: json['hesapSeviyesi'] as int,
      isActive: json['isActive'] as bool? ?? false,
      kayitTarihi: DateTime.parse(json['kayitTarihi'] as String),
      personelId: json['personelId'] as int?,
      personelAdi: json['personelAdi'] as String?,
      telefonNo: json['telefonNo'] as String?,
      dogumTarihi: json['dogumTarihi'] != null 
          ? DateTime.parse(json['dogumTarihi'] as String) 
          : null,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PaginatedResponse({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(Object?) fromJsonT) {
    return PaginatedResponse(
      items: (json['items'] as List).map((i) => fromJsonT(i)).toList(),
      pageNumber: json['pageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalCount: json['totalCount'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }
}

class UpdateAccountRequest {
  final String? kullaniciAdi;
  final int? hesapSeviyesi;
  final bool? isActive;
  final int? personelId;

  UpdateAccountRequest({
    this.kullaniciAdi,
    this.hesapSeviyesi,
    this.isActive,
    this.personelId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (kullaniciAdi != null) 'kullaniciAdi': kullaniciAdi,
      if (hesapSeviyesi != null) 'hesapSeviyesi': hesapSeviyesi,
      if (isActive != null) 'isActive': isActive,
      if (personelId != null) 'personelId': personelId,
    };
  }
}

class UpdatePersonnelRequest {
  final String adSoyad;
  final String? telefonNo;
  final String? dogumTarihi;

  UpdatePersonnelRequest({
    required this.adSoyad,
    this.telefonNo,
    this.dogumTarihi,
  });

  Map<String, dynamic> toJson() {
    return {
      'adSoyad': adSoyad,
      if (telefonNo != null) 'telefonNo': telefonNo,
      if (dogumTarihi != null) 'dogumTarihi': dogumTarihi,
    };
  }
}

class ChangePasswordRequest {
  final String? eskiParola;
  final String yeniParola;

  ChangePasswordRequest({
    this.eskiParola,
    required this.yeniParola,
  });

  Map<String, dynamic> toJson() {
    return {
      if (eskiParola != null) 'eskiParola': eskiParola,
      'yeniParola': yeniParola,
    };
  }
}
