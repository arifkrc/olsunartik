import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/audit_remote_datasource.dart';
import '../../data/repositories/audit_repository_impl.dart';
import '../../domain/repositories/i_audit_repository.dart';
import '../../domain/entities/audit_action.dart';

final auditRemoteDataSourceProvider = Provider<AuditRemoteDataSource>((ref) {
  return AuditRemoteDataSource(ref.watch(dioClientProvider));
});

final auditRepositoryProvider = Provider<IAuditRepository>((ref) {
  return AuditRepositoryImpl(ref.watch(auditRemoteDataSourceProvider));
});

class AuditNotifier extends AsyncNotifier<List<AuditAction>> {
  int _currentPage = 1;
  static const int _pageSize = 5;
  bool _hasMore = true;
  bool _isFetchingNextPage = false;

  @override
  Future<List<AuditAction>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isFetchingNextPage = false;
    final actions = await _fetchActions();
    if (actions.length < _pageSize) {
      _hasMore = false;
    }
    return actions;
  }

  Future<List<AuditAction>> _fetchActions() async {
    final repository = ref.read(auditRepositoryProvider);
    return repository.getMyActions(
      pageNumber: _currentPage,
      pageSize: _pageSize,
    );
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    _isFetchingNextPage = false;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final actions = await _fetchActions();
      if (actions.length < _pageSize) {
        _hasMore = false;
      }
      return actions;
    });
  }

  Future<void> loadNextPage() async {
    if (_isFetchingNextPage || !_hasMore) return;

    _isFetchingNextPage = true;
    try {
      _currentPage++;
      final newActions = await _fetchActions();
      
      if (newActions.length < _pageSize) {
        _hasMore = false;
      } else {
        _hasMore = true;
      }

      state = AsyncValue.data([...state.value ?? [], ...newActions]);
    } catch (e) {
      _currentPage--;
      // Keep existing data, maybe signal an error if supported
      state = AsyncValue.data(state.value ?? []); 
    } finally {
      _isFetchingNextPage = false;
    }
  }

  bool get hasMore => _hasMore;
}

final auditStateProvider = AsyncNotifierProvider<AuditNotifier, List<AuditAction>>(
  AuditNotifier.new,
);
