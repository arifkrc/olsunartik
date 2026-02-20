/// Üretim sayacı log kaydı
class ProductionLogEntry {
  final String id;
  final DateTime timestamp;
  final String actionType; // 'duzce', 'almanya', 'hurda', 'rework'
  final int quantity;
  final int? scrapReasonId; // Hurda için hata kodu ID
  final String? scrapReason; // Hurda için hata kodu metni
  final String? operatorName;

  ProductionLogEntry({
    required this.id,
    required this.timestamp,
    required this.actionType,
    required this.quantity,
    this.scrapReasonId,
    this.scrapReason,
    this.operatorName,
  });

  String get actionLabel {
    switch (actionType) {
      case 'duzce':
        return 'Düzce';
      case 'almanya':
        return 'Almanya';
      case 'hurda':
        return 'Hurda';
      case 'rework':
        return 'Rework';
      default:
        return actionType;
    }
  }
}

/// 12 Kontrol Kriteri
class QualityControlCriteria {
  static const List<Map<String, dynamic>> criteria = [
    {'id': 1, 'name': 'Tam Boy'},
    {'id': 2, 'name': 'İç Çap'},
    {'id': 3, 'name': 'Dış Çap'},
    {'id': 4, 'name': 'Profil'},
    {'id': 5, 'name': 'Yüzey Kalitesi'},
    {'id': 6, 'name': 'Renk'},
    {'id': 7, 'name': 'Çapak'},
    {'id': 8, 'name': 'Darbe/Çizik'},
    {'id': 9, 'name': 'Montaj Uyumu'},
    {'id': 10, 'name': 'Ağırlık'},
    {'id': 11, 'name': 'Etiket'},
    {'id': 12, 'name': 'Paket'},
  ];
}
