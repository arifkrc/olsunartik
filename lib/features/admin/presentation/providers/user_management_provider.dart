import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user.dart';

// Mock user state notifier
class UserManagementNotifier extends Notifier<List<User>> {
  @override
  List<User> build() => _generateMockUsers();

  static List<User> _generateMockUsers() {
    return [
      User(
        id: 1,
        kullaniciAdi: 'admin',
        hesapSeviyesi: 'Admin',
        personelId: null,
        personelAdi: 'Admin User',
        kayitTarihi: DateTime(2024, 1, 15),
        telefon: '5551112233',
        dogumTarihi: DateTime(1985, 5, 20),
        yakiniTelefon: '5559998877',
      ),
      User(
        id: 2,
        kullaniciAdi: 'yonetici',
        hesapSeviyesi: 'Manager',
        personelId: 101,
        personelAdi: 'Ahmet Yılmaz',
        kayitTarihi: DateTime(2024, 3, 20),
        telefon: '5552223344',
        dogumTarihi: DateTime(1990, 8, 15),
        yakiniTelefon: '5558887766',
      ),
      User(
        id: 3,
        kullaniciAdi: 'kullanici',
        hesapSeviyesi: 'User',
        personelId: 102,
        personelAdi: 'Mehmet Demir',
        kayitTarihi: DateTime(2024, 5, 10),
        telefon: '5553334455',
        dogumTarihi: DateTime(1995, 2, 28),
        yakiniTelefon: '5557776655',
      ),
    ];
  }

  void addUser({
    required String kullaniciAdi,
    required String hesapSeviyesi,
    int? personelId,
    String? personelAdi,
    String? telefon,
    DateTime? dogumTarihi,
    String? yakiniTelefon,
  }) {
    final newUser = User(
      id: state.isEmpty
          ? 1
          : state.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1,
      kullaniciAdi: kullaniciAdi,
      hesapSeviyesi: hesapSeviyesi,
      personelId: personelId,
      personelAdi: personelAdi,
      kayitTarihi: DateTime.now(),
      telefon: telefon,
      dogumTarihi: dogumTarihi,
      yakiniTelefon: yakiniTelefon,
    );
    state = [...state, newUser];
  }

  void updateUser(
    int id, {
    String? hesapSeviyesi,
    String? personelAdi,
    String? telefon,
    DateTime? dogumTarihi,
    String? yakiniTelefon,
  }) {
    state = state.map((user) {
      if (user.id == id) {
        return user.copyWith(
          hesapSeviyesi: hesapSeviyesi,
          personelAdi: personelAdi,
          telefon: telefon,
          dogumTarihi: dogumTarihi,
          yakiniTelefon: yakiniTelefon,
        );
      }
      return user;
    }).toList();
  }

  void deleteUser(int id) {
    state = state.where((user) => user.id != id).toList();
  }

  void changePassword(int id, String newPassword) {
    // Mock implementation - just show success message
    // In real implementation, this would call API
  }
}

// Provider
final userManagementProvider =
    NotifierProvider<UserManagementNotifier, List<User>>(() {
      return UserManagementNotifier();
    });

// Permission levels
final permissionLevels = ['Admin', 'Manager', 'User'];
