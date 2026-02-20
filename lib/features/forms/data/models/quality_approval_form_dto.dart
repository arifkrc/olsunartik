import '../../domain/entities/quality_approval_form.dart';

/// Request DTO — POST /api/kaliteonay için gönderilecek body
class KaliteOnayRequestDto {
  final DateTime islemTarihi;
  final int urunId;
  final int adet;
  final bool isUygun;
  final int? retKoduId;
  final String? aciklama;

  KaliteOnayRequestDto({
    required this.islemTarihi,
    required this.urunId,
    required this.adet,
    required this.isUygun,
    this.retKoduId,
    this.aciklama,
  });

  factory KaliteOnayRequestDto.fromEntity(QualityApprovalForm form) {
    return KaliteOnayRequestDto(
      islemTarihi: form.islemTarihi,
      urunId: form.urunId,
      adet: form.adet,
      isUygun: form.isUygun,
      retKoduId: form.retKoduId,
      aciklama: form.aciklama,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'islemTarihi': islemTarihi.toUtc().toIso8601String(),
      'urunId': urunId,
      'adet': adet,
      'isUygun': isUygun,
      if (retKoduId != null) 'retKoduId': retKoduId,
      if (aciklama != null && aciklama!.isNotEmpty) 'aciklama': aciklama,
    };
  }
}

/// Response DTO — Backend'den dönen kayıt modeli
class KaliteOnayResponseDto {
  final int id;
  final DateTime islemTarihi;
  final int? vardiyaId;
  final String? vardiyaAdi;
  final int urunId;
  final String? urunKodu;
  final String? urunAdi;
  final String? urunTuru;
  final int adet;
  final bool isUygun;
  final int? retKoduId;
  final String? retKodu;
  final String? aciklama;
  final int? kullaniciId;
  final String? kullaniciAdi;
  final DateTime olusturmaZamani;

  KaliteOnayResponseDto({
    required this.id,
    required this.islemTarihi,
    this.vardiyaId,
    this.vardiyaAdi,
    required this.urunId,
    this.urunKodu,
    this.urunAdi,
    this.urunTuru,
    required this.adet,
    required this.isUygun,
    this.retKoduId,
    this.retKodu,
    this.aciklama,
    this.kullaniciId,
    this.kullaniciAdi,
    required this.olusturmaZamani,
  });

  factory KaliteOnayResponseDto.fromJson(Map<String, dynamic> json) {
    return KaliteOnayResponseDto(
      id: json['id'] as int,
      islemTarihi: DateTime.parse(json['islemTarihi'] as String),
      vardiyaId: json['vardiyaId'] as int?,
      vardiyaAdi: json['vardiyaAdi'] as String?,
      urunId: json['urunId'] as int,
      urunKodu: json['urunKodu'] as String?,
      urunAdi: json['urunAdi'] as String?,
      urunTuru: json['urunTuru'] as String?,
      adet: json['adet'] as int,
      isUygun: json['isUygun'] as bool,
      retKoduId: json['retKoduId'] as int?,
      retKodu: json['retKodu'] as String?,
      aciklama: json['aciklama'] as String?,
      kullaniciId: json['kullaniciId'] as int?,
      kullaniciAdi: json['kullaniciAdi'] as String?,
      olusturmaZamani: DateTime.parse(json['olusturmaZamani'] as String),
    );
  }
}

// Eski DTO geriye dönük uyumluluk için tutuldu ama artık kullanılmıyor
class QualityApprovalFormDto extends QualityApprovalForm {
  QualityApprovalFormDto({
    super.id,
    required super.urunId,
    super.urunKodu = '',
    super.urunAdi = '',
    super.urunTuru = '',
    required super.adet,
    required super.isUygun,
    super.retKoduId,
    super.aciklama,
    required super.islemTarihi,
  });

  factory QualityApprovalFormDto.fromJson(Map<String, dynamic> json) {
    return QualityApprovalFormDto(
      id: json['id'] as int?,
      urunId: json['urunId'] as int? ?? 0,
      urunKodu: json['urunKodu'] as String? ?? '',
      urunAdi: json['urunAdi'] as String? ?? '',
      urunTuru: json['urunTuru'] as String? ?? '',
      adet: json['adet'] as int,
      isUygun: json['isUygun'] as bool? ?? true,
      retKoduId: json['retKoduId'] as int?,
      aciklama: json['aciklama'] as String?,
      islemTarihi: DateTime.parse(
        json['islemTarihi'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
