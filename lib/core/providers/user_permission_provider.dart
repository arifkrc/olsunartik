import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kullanıcı yetki yardımcı sınıfı
///
/// Backend'deki hesapSeviyesi değerlerine göre yetki kontrolü:
/// - 'Admin' / 'SuperAdmin' : Tüm alanlar, tarih düzenleme dahil
/// - 'Manager'              : Tüm alanlar, tarih düzenleme dahil
/// - Diğerleri              : Standart kullanıcı, tarih düzenleyemez
class UserPermission {
  final int level;

  const UserPermission(this.level);

  factory UserPermission.fromHesapSeviyesi(dynamic seviye) {
    if (seviye is int) return UserPermission(seviye);
    if (seviye is String) {
      final s = seviye.toLowerCase();
      if (s.contains('superadmin')) return const UserPermission(0);
      if (s.contains('admin')) return const UserPermission(1);
      if (s.contains('yonetici') || s.contains('manager'))
        return const UserPermission(2);
      if (s.contains('user') || s.contains('kullanici'))
        return const UserPermission(3);
      if (s.contains('misafir')) return const UserPermission(4);
    }
    return const UserPermission(3); // Default to normal user
  }

  /// Admin (0,1) veya Manager (2): tarih/saat alanını editleyebilir
  bool get canEditDate => level <= 2;

  /// Formları gönderebilir (tüm kullanıcılar)
  bool canEditForms() => true;

  /// Sadece admin erişimi (SuperAdmin=0, Admin=1)
  bool get isAdmin => level <= 1;

  /// Manager veya üzeri (SuperAdmin=0, Admin=1, Yonetici=2)
  bool get isManagerOrAbove => level <= 2;
}

// Legacy notifier — geriye dönük uyumluluk için korundu.
// NOT: Yeni ekranlarda doğrudan ref.watch(currentUserProvider).value?.level kullanın.
class UserPermissionNotifier extends Notifier<int> {
  @override
  int build() => 3; // Default to normal user level

  void setPermission(int level) {
    state = level;
  }

  bool canEditForms() => true;
  bool isAdmin() => state <= 1;
  bool isManager() => state <= 2;
  bool isUser() => state >= 3;
}

final userPermissionProvider = NotifierProvider<UserPermissionNotifier, int>(
  () => UserPermissionNotifier(),
);
