import '../../domain/entities/user.dart';

class UserDto extends User {
  UserDto({
    required super.id,
    required super.kullaniciAdi,
    required super.hesapSeviyesi,
    super.personelId,
    super.personelAdi,
    required super.kayitTarihi,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      kullaniciAdi: json['kullaniciAdi'] as String,
      hesapSeviyesi: json['hesapSeviyesi'] as String,
      personelId: json['personelId'] as int?,
      personelAdi: json['personelAdi'] as String?,
      kayitTarihi: DateTime.parse(json['kayitTarihi'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kullaniciAdi': kullaniciAdi,
      'hesapSeviyesi': hesapSeviyesi,
      'personelId': personelId,
      'personelAdi': personelAdi,
      'kayitTarihi': kayitTarihi.toIso8601String(),
    };
  }
}
