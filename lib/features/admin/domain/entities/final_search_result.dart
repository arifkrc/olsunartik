class FinalSearchResult {
  final String id;
  final String productCode;
  final String productName;
  final String customer; // Firma
  final int productionQuantity; // Uygun/Paketlenen
  final int rejectQuantity; // Ret/Hurda
  final String personnel; // Paketleyen Personel
  final DateTime date;
  final String? batchNo;

  FinalSearchResult({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.customer,
    required this.productionQuantity,
    required this.rejectQuantity,
    required this.personnel,
    required this.date,
    this.batchNo,
  });
}
