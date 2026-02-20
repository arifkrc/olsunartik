import '../models/form_data_models.dart';

// Local Data Source using Hive for offline-first storage
// This will be the implementation that handles local caching
abstract class FormsLocalDataSource {
  Future<void> cacheQualityApprovalForm(QualityApprovalFormData data);
  Future<List<QualityApprovalFormData>> getCachedQualityApprovalForms();

  Future<void> cacheFireEntry(FireEntryData data);
  Future<List<FireEntryData>> getCachedFireEntries();

  Future<void> cacheProductionEntry(ProductionCounterEntry data);
  Future<List<ProductionCounterEntry>> getCachedProductionEntries();

  Future<void> deleteQualityApprovalForm(String id);
  Future<void> deleteFireEntry(String id);

  Future<void> clearCache();
  Future<bool> hasCachedData();
}
