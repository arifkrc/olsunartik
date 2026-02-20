import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kullanıcı yetki yardımcı sınıfı
///
/// Backend'deki hesapSeviyesi değerlerine göre yetki kontrolü:
/// - 'Admin' / 'SuperAdmin' : Tüm alanlar, tarih düzenleme dahil
/// - 'Manager'              : Tüm alanlar, tarih düzenleme dahil
/// - Diğerleri              : Standart kullanıcı, tarih düzenleyemez
class UserPermission {
  final String hesapSeviyesi;

  const UserPermission(this.hesapSeviyesi);

  factory UserPermission.fromHesapSeviyesi(String? seviye) {
    return UserPermission((seviye ?? '').toLowerCase());
  }

  /// Admin veya Manager: tarih/saat alanını editleyebilir
  bool get canEditDate {
    return hesapSeviyesi.contains('admin') ||
        hesapSeviyesi.contains('manager') ||
        hesapSeviyesi.contains('superadmin');
  }

  /// Formları gönderebilir (tüm kullanıcılar)
  bool canEditForms() => true;

  /// Sadece admin erişimi
  bool get isAdmin =>
      hesapSeviyesi.contains('admin') || hesapSeviyesi.contains('superadmin');

  /// Manager veya üzeri
  bool get isManagerOrAbove => isAdmin || hesapSeviyesi.contains('manager');
}

// Legacy notifier — geriye dönük uyumluluk için korundu.
// NOT: Yeni ekranlarda doğrudan ref.watch(currentUserProvider).value?.hesapSeviyesi kullanın.
class UserPermissionNotifier extends Notifier<String> {
  @override
  String build() => 'User';

  void setPermission(String permission) {
    state = permission;
  }

  bool canEditForms() => true;
  bool isAdmin() => state.toLowerCase().contains('admin');
  bool isManager() => state.toLowerCase().contains('manager');
  bool isUser() => !isAdmin() && !isManager();
}

final userPermissionProvider = NotifierProvider<UserPermissionNotifier, String>(
  () => UserPermissionNotifier(),
);
