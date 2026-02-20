class QualityApprovalSearchResult {
  final String id;
  final String productCode;
  final String productName;

  final String operator; // Operatör
  final String shift; // Vardiya
  final String approvalStatus; // Onay / Ret / Şartlı
  final DateTime date;

  QualityApprovalSearchResult({
    required this.id,
    required this.productCode,
    required this.productName,

    required this.operator,
    required this.shift,
    required this.approvalStatus,
    required this.date,
  });
}
