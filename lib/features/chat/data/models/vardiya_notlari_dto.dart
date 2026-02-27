class VardiyaNotuDto {
  final int id;
  final int vardiyaId;
  final String vardiyaAdi;
  final String baslik;
  final String notMetni;
  final int oncelikDerecesi;
  final int kullaniciId;
  final String kullaniciAdi;
  final String personelAdi;
  final DateTime olusturmaZamani;
  final DateTime guncellemeZamani;

  VardiyaNotuDto({
    required this.id,
    required this.vardiyaId,
    required this.vardiyaAdi,
    required this.baslik,
    required this.notMetni,
    required this.oncelikDerecesi,
    required this.kullaniciId,
    required this.kullaniciAdi,
    required this.personelAdi,
    required this.olusturmaZamani,
    required this.guncellemeZamani,
  });

  factory VardiyaNotuDto.fromJson(Map<String, dynamic> json) {
    return VardiyaNotuDto(
      id: json['id'] as int? ?? 0,
      vardiyaId: json['vardiyaId'] as int? ?? 0,
      vardiyaAdi: json['vardiyaAdi'] as String? ?? '',
      baslik: json['baslik'] as String? ?? '',
      notMetni: json['notMetni'] as String? ?? '',
      oncelikDerecesi: json['oncelikDerecesi'] as int? ?? 1,
      kullaniciId: json['kullaniciId'] as int? ?? 0,
      kullaniciAdi: json['kullaniciAdi'] as String? ?? '',
      personelAdi: json['personelAdi'] as String? ?? '',
      olusturmaZamani: DateTime.parse(json['olusturmaZamani'] as String),
      guncellemeZamani: DateTime.parse(json['guncellemeZamani'] as String),
    );
  }
}

class VardiyaNotuRequestDto {
  final String baslik;
  final String notMetni;
  final int oncelikDerecesi;

  VardiyaNotuRequestDto({
    required this.baslik,
    required this.notMetni,
    required this.oncelikDerecesi,
  });

  Map<String, dynamic> toJson() {
    return {
      'baslik': baslik,
      'notMetni': notMetni,
      'oncelikDerecesi': oncelikDerecesi,
    };
  }
}
