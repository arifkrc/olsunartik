import 'package:connectivity_plus/connectivity_plus.dart';
import '../datasources/forms_local_datasource.dart';
import '../models/form_data_models.dart';
import '../../domain/repositories/forms_repository.dart';

// Repository implementation with offline-first approach
class FormsRepositoryImpl implements FormsRepository {
  final FormsLocalDataSource localDataSource;

  FormsRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveQualityApprovalForm(QualityApprovalFormData data) async {
    await localDataSource.cacheQualityApprovalForm(data);
    // Sync handled by syncData
  }

  @override
  Future<List<QualityApprovalFormData>> getQualityApprovalForms() async {
    return await localDataSource.getCachedQualityApprovalForms();
  }

  @override
  Future<void> deleteQualityApprovalForm(String id) async {
    await localDataSource.deleteQualityApprovalForm(id);
  }

  @override
  Future<void> saveFireEntry(FireEntryData data) async {
    await localDataSource.cacheFireEntry(data);
    // Sync handled by syncData
  }

  @override
  Future<List<FireEntryData>> getFireEntries() async {
    return await localDataSource.getCachedFireEntries();
  }

  @override
  Future<void> deleteFireEntry(String id) async {
    await localDataSource.deleteFireEntry(id);
  }

  @override
  Future<void> saveProductionEntry(ProductionCounterEntry data) async {
    await localDataSource.cacheProductionEntry(data);
    // Sync handled by syncData
  }

  @override
  Future<List<ProductionCounterEntry>> getProductionEntries() async {
    return await localDataSource.getCachedProductionEntries();
  }

  @override
  Stream<int> watchTotalProduction() {
    // Implement real-time stream
    return Stream.value(0);
  }

  @override
  Future<bool> syncData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }

    // Mock sync with backend
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<bool> hasUnsyncedData() async {
    return await localDataSource.hasCachedData();
  }
}
