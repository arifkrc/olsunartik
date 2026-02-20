import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/product_remote_datasource.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/entities/product.dart';
import '../domain/repositories/i_product_repository.dart';
import '../domain/usecases/search_products_usecase.dart';
import '../network/dio_client.dart';

/// Product Remote DataSource Provider
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource(ref.watch(dioClientProvider));
});

/// Product Repository Provider
final productRepositoryProvider = Provider<IProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productRemoteDataSourceProvider));
});

/// Search Products UseCase Provider
final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  return SearchProductsUseCase(ref.watch(productRepositoryProvider));
});

/// Tüm ürün listesini bir kez çekip cache'leyen provider
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(productRepositoryProvider).getAllProducts();
});

/// Product Search State Provider
final productSearchProvider =
    NotifierProvider<ProductSearchNotifier, AsyncValue<List<Product>>>(
  ProductSearchNotifier.new,
);

class ProductSearchNotifier extends Notifier<AsyncValue<List<Product>>> {
  @override
  AsyncValue<List<Product>> build() => const AsyncValue.data([]);

  /// İlk kullanımda arka planda ürün listesini ısıt
  void warmup() {
    ref.read(allProductsProvider.future).ignore();
  }

  /// Her karakter girişinde anlık client-side filtre
  void searchProducts(String query) {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    final allProductsAsync = ref.read(allProductsProvider);

    allProductsAsync.when(
      data: (allList) {
        final lowerQuery = query.toLowerCase();
        final filtered = allList.where((p) {
          return p.urunKodu.toLowerCase().contains(lowerQuery) ||
              p.urunAdi.toLowerCase().contains(lowerQuery);
        }).toList();

        filtered.sort((a, b) {
          final aStartsWith4 = a.urunKodu.startsWith('4');
          final bStartsWith4 = b.urunKodu.startsWith('4');
          if (aStartsWith4 && !bStartsWith4) return 1;
          if (!aStartsWith4 && bStartsWith4) return -1;
          return 0;
        });

        state = AsyncValue.data(filtered);
      },
      loading: () => state = const AsyncValue.loading(),
      error: (err, stack) => state = AsyncValue.error(err, stack),
    );
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
