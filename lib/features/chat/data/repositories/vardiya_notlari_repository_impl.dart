import '../../../../core/models/paged_result.dart';
import '../../data/datasources/vardiya_notlari_remote_datasource.dart';
import '../../data/models/vardiya_notlari_dto.dart';
import '../../domain/entities/vardiya_notu.dart';
import '../../domain/repositories/i_vardiya_notlari_repository.dart';

class VardiyaNotlariRepositoryImpl implements IVardiyaNotlariRepository {
  final VardiyaNotlariRemoteDataSource _remoteDataSource;

  VardiyaNotlariRepositoryImpl(this._remoteDataSource);

  @override
  Future<PagedResult<VardiyaNotu>> getVardiyaNotlari({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _remoteDataSource.getVardiyaNotlari(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return PagedResult<VardiyaNotu>(
      items: response.items.map((dto) => _mapToEntity(dto)).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
      totalPages: response.totalPages,
      hasPreviousPage: response.hasPreviousPage,
      hasNextPage: response.hasNextPage,
    );
  }

  @override
  Future<VardiyaNotu> createVardiyaNotu(
    String baslik,
    String notMetni,
    int oncelikDerecesi,
  ) async {
    final dto = await _remoteDataSource.createVardiyaNotu(
      VardiyaNotuRequestDto(
        baslik: baslik,
        notMetni: notMetni,
        oncelikDerecesi: oncelikDerecesi,
      ),
    );
    return _mapToEntity(dto);
  }

  VardiyaNotu _mapToEntity(VardiyaNotuDto dto) {
    return VardiyaNotu(
      id: dto.id,
      vardiyaId: dto.vardiyaId,
      vardiyaAdi: dto.vardiyaAdi,
      baslik: dto.baslik,
      notMetni: dto.notMetni,
      oncelikDerecesi: dto.oncelikDerecesi,
      kullaniciId: dto.kullaniciId,
      kullaniciAdi: dto.kullaniciAdi,
      personelAdi: dto.personelAdi,
      olusturmaZamani: dto.olusturmaZamani,
      guncellemeZamani: dto.guncellemeZamani,
    );
  }
}
