abstract class ILookupRepository {
  Future<List<Map<String, dynamic>>> getAll(String endpoint);
  Future<Map<String, dynamic>> create(String endpoint, Map<String, dynamic> data);
  Future<Map<String, dynamic>> update(String endpoint, int id, Map<String, dynamic> data);
  Future<void> delete(String endpoint, int id);
}
