import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';

class LookupRemoteDataSource {
  final Dio _dio;

  LookupRemoteDataSource(this._dio);

  Future<List<Map<String, dynamic>>> getAll(String endpoint) async {
    final response = await _dio.get('${ApiConstants.lookupBase}/$endpoint');
    
    // Check if the response is a standard Map wrapping a 'data' array
    if (response.data is Map<String, dynamic>) {
      final mapData = response.data as Map<String, dynamic>;
      if (mapData['success'] == true && mapData['data'] is List) {
        return List<Map<String, dynamic>>.from(mapData['data']);
      }
    } else if (response.data is List) {
      return List<Map<String, dynamic>>.from(response.data);
    }
    
    return [];
  }

  Future<Map<String, dynamic>> create(String endpoint, Map<String, dynamic> data) async {
    final response = await _dio.post('${ApiConstants.lookupBase}/$endpoint', data: data);
    
    if (response.data is Map<String, dynamic>) {
      final mapData = response.data as Map<String, dynamic>;
      if (mapData['success'] == true && mapData['data'] is Map<String, dynamic>) {
        return mapData['data'] as Map<String, dynamic>;
      }
      return mapData;
    }
    return {};
  }

  Future<Map<String, dynamic>> update(String endpoint, int id, Map<String, dynamic> data) async {
    final response = await _dio.put('${ApiConstants.lookupBase}/$endpoint/$id', data: data);
    
    if (response.data is Map<String, dynamic>) {
      final mapData = response.data as Map<String, dynamic>;
      if (mapData['success'] == true && mapData['data'] is Map<String, dynamic>) {
        return mapData['data'] as Map<String, dynamic>;
      }
      return mapData;
    }
    return {};
  }

  Future<void> delete(String endpoint, int id) async {
    // Soft delete using PUT request
    await _dio.put('${ApiConstants.lookupBase}/$endpoint/$id', data: {'isActive': false});
  }
}
