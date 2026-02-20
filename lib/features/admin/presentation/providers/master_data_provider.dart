import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/master_data_item.dart';

// Mock master data notifier
class MasterDataNotifier extends Notifier<List<MasterDataItem>> {
  @override
  List<MasterDataItem> build() => _generateMockData();

  static List<MasterDataItem> _generateMockData() {
    return [
      // Machines
      MasterDataItem(
        id: 1,
        category: 'machines',
        code: 'M1',
        description: 'Tezgah 1',
      ),
      MasterDataItem(
        id: 2,
        category: 'machines',
        code: 'M2',
        description: 'Tezgah 2',
      ),
      MasterDataItem(
        id: 3,
        category: 'machines',
        code: 'PRES',
        description: 'Pres Makinesi',
      ),
      MasterDataItem(
        id: 4,
        category: 'machines',
        code: 'TOR',
        description: 'Torna',
      ),

      // Operators
      MasterDataItem(id: 5, category: 'operators', code: 'Furkan Yılmaz'),
      MasterDataItem(id: 6, category: 'operators', code: 'Ahmet Demir'),
      MasterDataItem(id: 7, category: 'operators', code: 'Mehmet Yılmaz'),
      MasterDataItem(id: 8, category: 'operators', code: 'Ali Veli'),

      // Reject Codes
      MasterDataItem(
        id: 9,
        category: 'reject-codes',
        code: 'ÇATLAK',
        description: 'Çatlak var',
      ),
      MasterDataItem(
        id: 10,
        category: 'reject-codes',
        code: 'PÜRÜZ',
        description: 'Yüzey pürüzlü',
      ),
      MasterDataItem(
        id: 11,
        category: 'reject-codes',
        code: 'ÖLÇÜ',
        description: 'Ölçü hatası',
      ),
      MasterDataItem(
        id: 12,
        category: 'reject-codes',
        code: 'DELİK',
        description: 'Delik problemi',
      ),

      // Zones
      MasterDataItem(
        id: 13,
        category: 'zones',
        code: 'A',
        description: 'A Bölgesi',
      ),
      MasterDataItem(
        id: 14,
        category: 'zones',
        code: 'B',
        description: 'B Bölgesi',
      ),
      MasterDataItem(
        id: 15,
        category: 'zones',
        code: 'C',
        description: 'C Bölgesi',
      ),
      MasterDataItem(
        id: 16,
        category: 'zones',
        code: 'D',
        description: 'D Bölgesi',
      ),

      // Product Codes (NEW)
      MasterDataItem(
        id: 20,
        category: 'product-codes',
        code: 'P001',
        description: 'Fren Diski - Ağır Vasıta',
        productType: 'Fren Diski',
      ),
      MasterDataItem(
        id: 21,
        category: 'product-codes',
        code: 'P002',
        description: 'Fren Kampanası - Otobüs',
        productType: 'Fren Kampanası',
      ),
      MasterDataItem(
        id: 22,
        category: 'product-codes',
        code: 'P003',
        description: 'Fren Balatası - Kamyon',
        productType: 'Fren Balatası',
      ),

      // Operation Names (NEW)
      MasterDataItem(
        id: 23,
        category: 'operation-names',
        code: 'TORNALAMA',
        description: 'Torna operasyonu',
      ),
      MasterDataItem(
        id: 24,
        category: 'operation-names',
        code: 'FREZELEME',
        description: 'Freze operasyonu',
      ),
      MasterDataItem(
        id: 25,
        category: 'operation-names',
        code: 'DELME',
        description: 'Delme operasyonu',
      ),
      MasterDataItem(
        id: 26,
        category: 'operation-names',
        code: 'TAŞLAMA',
        description: 'Taşlama operasyonu',
      ),

      // Rework Operations (NEW)
      MasterDataItem(
        id: 27,
        category: 'rework-operations',
        code: 'YÜZEY DÜZELTİM',
        description: 'Yüzey düzeltme işlemi',
      ),
      MasterDataItem(
        id: 28,
        category: 'rework-operations',
        code: 'YENİDEN İŞLEME',
        description: 'Tam yeniden işleme',
      ),
      MasterDataItem(
        id: 29,
        category: 'rework-operations',
        code: 'KAYNAK TAMİRİ',
        description: 'Kaynak ile tamir',
      ),
      MasterDataItem(
        id: 30,
        category: 'rework-operations',
        code: 'BOYUT AYARI',
        description: 'Boyut ayarlama işlemi',
      ),
    ];
  }

  List<MasterDataItem> getByCategory(String category) {
    return state.where((item) => item.category == category).toList();
  }

  void addItem({
    required String category,
    required String code,
    String? description,
    String? productType,
  }) {
    final nextId = state.isEmpty
        ? 1
        : state.map((i) => i.id).reduce((a, b) => a > b ? a : b) + 1;
    final newItem = MasterDataItem(
      id: nextId,
      category: category,
      code: code,
      description: description,
      productType: productType,
    );
    state = [...state, newItem];
  }

  void updateItem(
    int id, {
    String? code,
    String? description,
    String? productType,
    bool? isActive,
  }) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(
          code: code,
          description: description,
          productType: productType,
          isActive: isActive,
        );
      }
      return item;
    }).toList();
  }

  void deleteItem(int id) {
    state = state.where((item) => item.id != id).toList();
  }

  void toggleActive(int id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isActive: !item.isActive);
      }
      return item;
    }).toList();
  }
}

// Provider
final masterDataProvider =
    NotifierProvider<MasterDataNotifier, List<MasterDataItem>>(() {
      return MasterDataNotifier();
    });

// Selected category provider (using NotifierProvider instead of StateProvider)
class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'machines';

  void setCategory(String category) {
    state = category;
  }
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(() {
      return SelectedCategoryNotifier();
    });

// Filtered items by selected category
final filteredMasterDataProvider = Provider<List<MasterDataItem>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final allData = ref.watch(masterDataProvider);
  return allData.where((item) => item.category == category).toList();
});

// Categories (UPDATED: removed foundries and locations, added product-codes, operation-names, rework-operations)
const masterDataCategories = {
  'machines': {'label': 'Tezgahlar', 'icon': 'settings'},
  'operators': {'label': 'Operatörler', 'icon': 'user'},
  'reject-codes': {'label': 'Ret Kodları', 'icon': 'xCircle'},
  'zones': {'label': 'Bölgeler', 'icon': 'mapPin'},
  'product-codes': {'label': 'Ürün Kodları', 'icon': 'box'},
  'operation-names': {'label': 'Operasyon Adları', 'icon': 'tool'},
  'rework-operations': {'label': 'Rework İşlemleri', 'icon': 'rotateC cw'},
};
