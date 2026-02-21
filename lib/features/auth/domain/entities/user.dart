enum HesapSeviyesi { operator_, admin, superAdmin }

extension HesapSeviyesiExtension on String {
  HesapSeviyesi get toHesapSeviyesi {
    switch (toLowerCase()) {
      case 'admin':
        return HesapSeviyesi.admin;
      case 'superadmin':
        return HesapSeviyesi.superAdmin;
      case 'operator':
      default:
        return HesapSeviyesi.operator_;
    }
  }
}

class User {
  final int id;
  final String kullaniciAdi;
  final String hesapSeviyesi;
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
  
  HesapSeviyesi get role => hesapSeviyesi.toHesapSeviyesi;
  bool get isAdmin => role == HesapSeviyesi.admin || role == HesapSeviyesi.superAdmin;
  bool get isSuperAdmin => role == HesapSeviyesi.superAdmin;

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
