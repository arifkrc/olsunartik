import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/vardiya_notlari_remote_datasource.dart';
import '../../data/repositories/vardiya_notlari_repository_impl.dart';
import '../../domain/entities/vardiya_notu.dart';
import '../../domain/repositories/i_vardiya_notlari_repository.dart';

// --- Data Layer Providers ---
final vardiyaNotlariDataSourceProvider = Provider<VardiyaNotlariRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return VardiyaNotlariRemoteDataSource(dio);
});

final vardiyaNotlariRepositoryProvider = Provider<IVardiyaNotlariRepository>((ref) {
  final dataSource = ref.watch(vardiyaNotlariDataSourceProvider);
  return VardiyaNotlariRepositoryImpl(dataSource);
});

// --- State Providers ---

// Fetch latest messages for view (e.g. Page 1, Size 10 or more)
final vardiyaNotlariProvider = FutureProvider.autoDispose<List<VardiyaNotu>>((ref) async {
  final repository = ref.watch(vardiyaNotlariRepositoryProvider);
  // Fetch latest 20 items to show in chat view
  final result = await repository.getVardiyaNotlari(pageNumber: 1, pageSize: 20);
  
  // They arrive in DESC order (latest first). We generally want chat view to display oldest at top, latest at bottom
  // Reverse the list
  return result.items.reversed.toList();
});
