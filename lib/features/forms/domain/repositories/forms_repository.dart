// Forms Repository Interface - Defines the contract for form data operations
import 'package:qualityapp/features/forms/data/models/form_data_models.dart';

abstract class FormsRepository {
  // Quality Approval
  Future<void> saveQualityApprovalForm(QualityApprovalFormData data);
  Future<List<QualityApprovalFormData>> getQualityApprovalForms();
  Future<void> deleteQualityApprovalForm(String id);

  // Fire Entries
  Future<void> saveFireEntry(FireEntryData data);
  Future<List<FireEntryData>> getFireEntries();
  Future<void> deleteFireEntry(String id);

  // Production Counter
  Future<void> saveProductionEntry(ProductionCounterEntry data);
  Future<List<ProductionCounterEntry>> getProductionEntries();
  Stream<int> watchTotalProduction();

  // Sync operations
  Future<bool> syncData();
  Future<bool> hasUnsyncedData();
}
