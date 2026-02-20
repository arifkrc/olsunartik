import 'package:dio/dio.dart';
import '../models/vardiya_dto.dart';
import '../../domain/entities/operasyon.dart';
import '../../domain/entities/tezgah.dart';
import '../../domain/entities/bolge.dart';
import '../../domain/entities/ret_kodu.dart';

class LookupRemoteDataSource {
  final Dio _dio;

  LookupRemoteDataSource(this._dio);

  Future<List<VardiyaDto>> getVardiyalar() async {
    final response = await _dio.get('/api/vardiyalar');
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => VardiyaDto.fromJson(e)).toList();
    }
    throw Exception('Failed to load vardiyalar');
  }

  Future<List<Operasyon>> getOperasyonlar() async {
    final response = await _dio.get('/api/lookup/operasyonlar');
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data
          .map(
            (e) => Operasyon(
              id: e['id'],
              operasyonKodu: e['operasyonKodu'],
              operasyonAdi: e['operasyonAdi'],
            ),
          )
          .toList();
    }
    throw Exception('Failed to load operasyonlar');
  }

  Future<List<Tezgah>> getTezgahlar() async {
    final response = await _dio.get('/api/lookup/tezgahlar');
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data
          .map(
            (e) => Tezgah(
              id: e['id'],
              tezgahNo: e['tezgahNo'],
              tezgahTuru: e['tezgahTuru'],
            ),
          )
          .toList();
    }
    throw Exception('Failed to load tezgahlar');
  }

  Future<List<Bolge>> getBolgeler() async {
    final response = await _dio.get('/api/lookup/bolgeler');
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data
          .map((e) => Bolge(id: e['id'], bolgeAdi: e['bolgeAdi']))
          .toList();
    }
    throw Exception('Failed to load bolgeler');
  }

  Future<List<RetKodu>> getRetKodlari() async {
    final response = await _dio.get('/api/lookup/ret-kodlari');
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data
          .map(
            (e) => RetKodu(
              id: e['id'],
              retKodu: e['retKodu'],
              aciklama: e['aciklama'],
            ),
          )
          .toList();
    }
    throw Exception('Failed to load ret kodları');
  }
}
