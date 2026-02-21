
class User {
  final int id;
  final String kullaniciAdi;
  final dynamic hesapSeviyesi; // Can be String or int from backend
  final int? personelId;
  final String? personelAdi;
  final DateTime kayitTarihi;
  final String? telefon;
  final DateTime? dogumTarihi;
  final String? yakiniTelefon;

  User({
    required this.id,
    required this.kullaniciAdi,
    required this.hesapSeviyesi,
    this.personelId,
    this.personelAdi,
    required this.kayitTarihi,
    this.telefon,
    this.dogumTarihi,
    this.yakiniTelefon,
  });

  // Getter properties for English field names
  String get username => kullaniciAdi;
  String get fullName => personelAdi ?? kullaniciAdi;
  
  // 0=SuperAdmin, 1=Admin, 2=Yonetici, 3=Kullanici, 4=Misafir
  int get level {
    if (hesapSeviyesi is int) return hesapSeviyesi;
    if (hesapSeviyesi is String) {
      final s = hesapSeviyesi.toString().toLowerCase();
      if (s.contains('superadmin')) return 0;
      if (s.contains('admin')) return 1;
      if (s.contains('yonetici') || s.contains('manager')) return 2;
      if (s.contains('user') || s.contains('kullanici')) return 3;
      if (s.contains('misafir') || s.contains('guest')) return 4;
    }
    return 3; // Default to normal user
  }

  bool get isAdmin => level <= 1;
  bool get isSuperAdmin => level == 0;
  bool get isManagerOrAbove => level <= 2;

  String get roleLabel {
    switch (level) {
      case 0: return 'Süper Admin';
      case 1: return 'Admin';
      case 2: return 'Yönetici';
      case 3: return 'Kullanıcı';
      case 4: return 'Misafir';
      default: return 'Kullanıcı';
    }
  }

  // These are now real fields
  DateTime? get birthDate => dogumTarihi;
  String? get phoneNumber => telefon;
  String? get emergencyContact => yakiniTelefon;

  User copyWith({
    int? id,
    String? kullaniciAdi,
    String? hesapSeviyesi,
    int? personelId,
    String? personelAdi,
    DateTime? kayitTarihi,
    String? telefon,
    DateTime? dogumTarihi,
    String? yakiniTelefon,
  }) {
    return User(
      id: id ?? this.id,
      kullaniciAdi: kullaniciAdi ?? this.kullaniciAdi,
      hesapSeviyesi: hesapSeviyesi ?? this.hesapSeviyesi,
      personelId: personelId ?? this.personelId,
      personelAdi: personelAdi ?? this.personelAdi,
      kayitTarihi: kayitTarihi ?? this.kayitTarihi,
      telefon: telefon ?? this.telefon,
      dogumTarihi: dogumTarihi ?? this.dogumTarihi,
      yakiniTelefon: yakiniTelefon ?? this.yakiniTelefon,
    );
  }
}
