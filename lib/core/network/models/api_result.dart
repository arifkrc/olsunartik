class ApiResult<T> {
  final bool success;
  final T? data;
  final String? message;
  final List<String>? errors;

  ApiResult({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  factory ApiResult.fromJson(
      Map<String, dynamic> json, T? Function(dynamic)? fromData) {
    return ApiResult(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : null,
      message: json['message'] as String?,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
    );
  }
}
