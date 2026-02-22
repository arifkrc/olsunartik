import '../../domain/entities/audit_action.dart';

class AuditActionDto {
  final int id;
  final int kullaniciId;
  final String kullaniciAdi;
  final String aksiyonTipi;
  final String varlikTipi;
  final int varlikId;
  final String aciklama;
  final String? eskiDeger;
  final String? yeniDeger;
  final String ipAdresi;
  final String islemZamani;

  AuditActionDto({
    required this.id,
    required this.kullaniciId,
    required this.kullaniciAdi,
    required this.aksiyonTipi,
    required this.varlikTipi,
    required this.varlikId,
    required this.aciklama,
    this.eskiDeger,
    this.yeniDeger,
    required this.ipAdresi,
    required this.islemZamani,
  });

  factory AuditActionDto.fromJson(Map<String, dynamic> json) {
    return AuditActionDto(
      id: json['id'] as int,
      kullaniciId: json['kullaniciId'] as int,
      kullaniciAdi: json['kullaniciAdi'] as String,
      aksiyonTipi: json['aksiyonTipi'] as String,
      varlikTipi: json['varlikTipi'] as String,
      varlikId: json['varlikId'] as int,
      aciklama: json['aciklama'] as String,
      eskiDeger: json['eskiDeger'] as String?,
      yeniDeger: json['yeniDeger'] as String?,
      ipAdresi: json['ipAdresi'] as String,
      islemZamani: json['islemZamani'] as String,
    );
  }

  AuditAction toEntity() {
    return AuditAction(
      id: id,
      kullaniciId: kullaniciId,
      kullaniciAdi: kullaniciAdi,
      aksiyonTipi: aksiyonTipi,
      varlikTipi: varlikTipi,
      varlikId: varlikId,
      aciklama: aciklama,
      eskiDeger: eskiDeger,
      yeniDeger: yeniDeger,
      ipAdresi: ipAdresi,
      islemZamani: DateTime.parse(islemZamani),
    );
  }
}
