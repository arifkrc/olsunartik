import '../../domain/entities/final_kontrol_form.dart';
import '../../domain/repositories/i_final_kontrol_repository.dart';
import '../datasources/final_kontrol_remote_datasource.dart';
import '../models/final_kontrol_form_dto.dart';

class FinalKontrolRepositoryImpl implements IFinalKontrolRepository {
  final FinalKontrolRemoteDataSource _remoteDataSource;

  FinalKontrolRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<FinalKontrolForm>> getAll() async {
    await _remoteDataSource.getAll();
    // Return empty list since we migrated to new entity structure
    return [];
  }

  @override
  Future<List<FinalKontrolForm>> getForms({DateTime? date}) async {
    // Not implemented yet, returns empty list
    return [];
  }

  @override
  Future<FinalKontrolBulkResponseDto> createForm(FinalKontrolRequestDto requestDto) async {
    return _remoteDataSource.createForm(requestDto);
  }

  @override
  Future<void> update(FinalKontrolForm form) async {
    // Not implemented with new structure
  }

  @override
  Future<void> delete(int id) async {
    await _remoteDataSource.delete(id);
  }
}
