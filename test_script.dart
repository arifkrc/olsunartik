import 'package:dio/dio.dart';
void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5033/api')); // Adjust port if needed
  try {
    final response = await dio.get('/audit/my-actions?pageNumber=1&pageSize=5');
    final actions = response.data['data'] as List?;
    if (actions != null && actions.isNotEmpty) {
      for (var action in actions) {
        print('AksiyonTipi: ${action['aksiyonTipi']}');
        print('VarlikTipi: ${action['varlikTipi']}');
        print('YeniDeger: ${action['yeniDeger']}');
      }
    } else {
      print('No actions found');
    }
  } catch (e) {
    print('Error: $e');
  }
}
