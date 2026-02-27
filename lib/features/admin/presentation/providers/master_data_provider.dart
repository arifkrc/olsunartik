import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/lookup_remote_datasource.dart';
import '../../data/repositories/lookup_repository_impl.dart';
import '../../domain/repositories/i_lookup_repository.dart';
import '../../domain/entities/master_data_item.dart';

final lookupRemoteDataSourceProvider = Provider<LookupRemoteDataSource>((ref) {
  return LookupRemoteDataSource(ref.watch(dioClientProvider));
});

final lookupRepositoryProvider = Provider<ILookupRepository>((ref) {
  return LookupRepositoryImpl(ref.watch(lookupRemoteDataSourceProvider));
});

class MasterDataNotifier extends AsyncNotifier<List<MasterDataItem>> {
  @override
  Future<List<MasterDataItem>> build() async {
    final category = ref.watch(selectedCategoryProvider);
    return _fetchData(category);
  }

  Future<List<MasterDataItem>> _fetchData(String category) async {
    final repository = ref.read(lookupRepositoryProvider);
    try {
      final rawData = await repository.getAll(category);
      return rawData.map((json) => _mapJsonToMasterDataItem(category, json)).toList();
    } catch (e) {
      throw Exception('Veri yüklenemedi: $e');
    }
  }

  // Expose this as a public method so other providers can use it
  Future<List<MasterDataItem>> fetchCategory(String category) async {
    return _fetchData(category);
  }

  MasterDataItem _mapJsonToMasterDataItem(String category, Map<String, dynamic> json) {
    int id = json['id'] as int? ?? 0;
    String code = '';
    String? description;
    String? productType;
    DateTime? createdAt;
    DateTime? updatedAt;
    String? createdByName;
    String? updatedByName;

    DateTime? dogumTarihi;
    String? yakinTelefonNo;
    String? yakinlikDerecesi;

    final String? cDate = json['createdAt']?.toString() ?? json['createdDate']?.toString();
    if (cDate != null) createdAt = DateTime.tryParse(cDate);

    final String? uDate = json['updatedAt']?.toString() ?? json['updatedDate']?.toString();
    if (uDate != null) updatedAt = DateTime.tryParse(uDate);

    createdByName = json['createdByName']?.toString() ?? json['createdBy']?.toString();
    updatedByName = json['updatedByName']?.toString() ?? json['updatedBy']?.toString();

    switch (category) {
      case 'operasyonlar':
        code = json['operasyonKodu']?.toString() ?? '';
        description = json['operasyonAdi']?.toString();
        break;
      case 'operatorler':
        code = json['adSoyad']?.toString() ?? '';
        description = json['sicilNo']?.toString();
        break;
      case 'bolgeler':
        code = json['bolgeKodu']?.toString() ?? '';
        description = json['bolgeAdi']?.toString();
        break;
      case 'ret-kodlari':
        code = json['kod']?.toString() ?? '';
        description = json['aciklama']?.toString();
        break;
      case 'tezgahlar':
        code = json['tezgahNo']?.toString() ?? '';
        description = json['tezgahTuru']?.toString();
        break;
      case 'urunler':
      case 'ham-urunler':
        code = json['urunKodu']?.toString() ?? '';
        description = json['urunAdi']?.toString();
        productType = json['urunTuru']?.toString();
        break;
      case 'personeller':
        code = json['adSoyad']?.toString() ?? '';
        description = json['telefonNo']?.toString();
        if (json['dogumTarihi'] != null) {
          dogumTarihi = DateTime.tryParse(json['dogumTarihi'].toString());
        }
        yakinTelefonNo = json['yakinTelefonNo']?.toString();
        yakinlikDerecesi = json['yakinlikDerecesi']?.toString();
        break;
      default:
        code = json['code']?.toString() ?? 'Bilinmiyor';
        description = json['description']?.toString();
    }

    return MasterDataItem(
      id: id,
      category: category,
      code: code,
      description: description,
      productType: productType,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdByName: createdByName,
      updatedByName: updatedByName,
      dogumTarihi: dogumTarihi,
      yakinTelefonNo: yakinTelefonNo,
      yakinlikDerecesi: yakinlikDerecesi,
    );
  }
  Map<String, dynamic> _mapMasterDataItemToMap(MasterDataItem item) {
    Map<String, dynamic> data = {
      'id': item.id,
      'isActive': item.isActive,
    };

    switch (item.category) {
      case 'operasyonlar':
        data['operasyonKodu'] = item.code;
        data['operasyonAdi'] = item.description;
        break;
      case 'operatorler':
        data['adSoyad'] = item.code;
        data['sicilNo'] = item.description;
        break;
      case 'bolgeler':
        data['bolgeKodu'] = item.code;
        data['bolgeAdi'] = item.description;
        break;
      case 'ret-kodlari':
        data['kod'] = item.code;
        data['aciklama'] = item.description;
        break;
      case 'tezgahlar':
        data['tezgahNo'] = item.code;
        data['tezgahTuru'] = item.description;
        break;
      case 'urunler':
      case 'ham-urunler':
        data['urunKodu'] = item.code;
        data['urunAdi'] = item.description;
        data['urunTuru'] = item.productType;
        break;
      case 'personeller':
        data['adSoyad'] = item.code;
        data['telefonNo'] = item.description;
        if (item.dogumTarihi != null) {
          data['dogumTarihi'] = item.dogumTarihi!.toUtc().toIso8601String();
        }
        data['yakinTelefonNo'] = item.yakinTelefonNo;
        data['yakinlikDerecesi'] = item.yakinlikDerecesi;
        break;
      default:
        data['code'] = item.code;
        data['description'] = item.description;
    }

    return data;
  }

  Future<void> addItem({
    required String category,
    required Map<String, dynamic> payload,
  }) async {
    final repository = ref.read(lookupRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      await repository.create(category, payload);
      ref.invalidateSelf();
      if (category == 'personeller') {
        ref.invalidate(personnelListProvider);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateItem({
    required MasterDataItem item,
    required Map<String, dynamic> payload,
  }) async {
    final repository = ref.read(lookupRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      // Merge current item data with changes to ensure all required fields are sent
      final currentMap = _mapMasterDataItemToMap(item);
      final fullPayload = {...currentMap, ...payload};
      
      await repository.update(item.category, item.id, fullPayload);
      ref.invalidateSelf();
      if (item.category == 'personeller') {
        ref.invalidate(personnelListProvider);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteItem(MasterDataItem item) async {
    final repository = ref.read(lookupRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      // Soft delete: Send full object with isActive: false
      final payload = _mapMasterDataItemToMap(item.copyWith(isActive: false));
      
      await repository.delete(item.category, item.id, payload);
      ref.invalidateSelf();
      if (item.category == 'personeller') {
        ref.invalidate(personnelListProvider);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider
final masterDataProvider =
    AsyncNotifierProvider<MasterDataNotifier, List<MasterDataItem>>(() {
      return MasterDataNotifier();
    });

// Selected category provider
class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'operasyonlar';

  void setCategory(String category) {
    state = category;
  }
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(() {
      return SelectedCategoryNotifier();
    });

// Filters are calculated within the UI now as the provider returns the list for the current category directly
final filteredMasterDataProvider = Provider<List<MasterDataItem>>((ref) {
  return ref.watch(masterDataProvider).value ?? [];
});

// Categories map directly to API endpoints
const masterDataCategories = {
  'operasyonlar': {'label': 'Operasyonlar', 'icon': 'tool'},
  'operatorler': {'label': 'Operatörler', 'icon': 'user'},
  'personeller': {'label': 'Kalite Personelleri', 'icon': 'users'},
  'bolgeler': {'label': 'Bölgeler', 'icon': 'mapPin'},
  'ret-kodlari': {'label': 'Ret Kodları', 'icon': 'xCircle'},
  'tezgahlar': {'label': 'Tezgahlar', 'icon': 'settings'},
  'urunler': {'label': 'Ürünler', 'icon': 'box'},
  'ham-urunler': {'label': 'Ham Ürünler', 'icon': 'package'},
};

// Standalone provider for fetching personnel, useful for dropdowns in other screens
final personnelListProvider = FutureProvider<List<MasterDataItem>>((ref) async {
  final repository = ref.watch(lookupRepositoryProvider);
  
  final rawData = await repository.getAll('personeller');
  
  return rawData.map((json) {
    int id = json['id'] as int? ?? 0;
    String code = json['adSoyad']?.toString() ?? '';
    return MasterDataItem(
      id: id,
      category: 'personeller',
      code: code,
      description: json['telefonNo']?.toString(),
      dogumTarihi: json['dogumTarihi'] != null ? DateTime.tryParse(json['dogumTarihi'].toString()) : null,
      yakinTelefonNo: json['yakinTelefonNo']?.toString(),
      yakinlikDerecesi: json['yakinlikDerecesi']?.toString(),
    );
  }).toList();
});

final rejectCodesProvider = FutureProvider<List<MasterDataItem>>((ref) async {
  final repository = ref.watch(lookupRepositoryProvider);
  final rawData = await repository.getAll('ret-kodlari');
  return rawData.map((json) {
    return MasterDataItem(
      id: json['id'] as int? ?? 0,
      category: 'ret-kodlari',
      code: json['kod']?.toString() ?? '',
      description: json['aciklama']?.toString(),
    );
  }).toList();
});
