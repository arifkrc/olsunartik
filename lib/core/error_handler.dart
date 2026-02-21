import 'network/models/api_result.dart';

String resolveErrorMessage(ApiResult result) {
  if (result.errors != null && result.errors!.isNotEmpty) {
    return result.errors!.join('\n'); // Validation: each field error on a new line
  }
  return result.message ?? 'Beklenmeyen bir hata oluştu.';
}
