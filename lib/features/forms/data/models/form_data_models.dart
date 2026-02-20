// Quality Approval Form Data Model
class QualityApprovalFormData {
  final String operatorName;
  final DateTime date;
  final String shift;
  final String? productCode;
  final String? productName;
  final int amount;
  final String? rejectCode;
  final String? notes;

  const QualityApprovalFormData({
    required this.operatorName,
    required this.date,
    required this.shift,
    this.productCode,
    this.productName,
    this.amount = 0,
    this.rejectCode,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'operatorName': operatorName,
    'date': date.toIso8601String(),
    'shift': shift,
    'productCode': productCode,
    'productName': productName,
    'amount': amount,
    'rejectCode': rejectCode,
    'notes': notes,
  };

  factory QualityApprovalFormData.fromJson(Map<String, dynamic> json) =>
      QualityApprovalFormData(
        operatorName: json['operatorName'] as String,
        date: DateTime.parse(json['date'] as String),
        shift: json['shift'] as String,
        productCode: json['productCode'] as String?,
        productName: json['productName'] as String?,
        amount: json['amount'] as int? ?? 0,
        rejectCode: json['rejectCode'] as String?,
        notes: json['notes'] as String?,
      );
}

// Fire Entry Data Model
class FireEntryData {
  final String processedMachine;
  final String detectedMachine;
  final String zone;
  final String operation;
  final String errorReason;
  final String? notes;

  const FireEntryData({
    required this.processedMachine,
    required this.detectedMachine,
    required this.zone,
    required this.operation,
    required this.errorReason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'processedMachine': processedMachine,
    'detectedMachine': detectedMachine,
    'zone': zone,
    'operation': operation,
    'errorReason': errorReason,
    'notes': notes,
  };

  factory FireEntryData.fromJson(Map<String, dynamic> json) => FireEntryData(
    processedMachine: json['processedMachine'] as String,
    detectedMachine: json['detectedMachine'] as String,
    zone: json['zone'] as String,
    operation: json['operation'] as String,
    errorReason: json['errorReason'] as String,
    notes: json['notes'] as String?,
  );
}

// Production Counter Entry Model
class ProductionCounterEntry {
  final String type; // 'duzce', 'almanya', 'rework', 'hurda'
  final int amount;
  final DateTime timestamp;
  final String operatorName;
  final String? rejectCode;

  const ProductionCounterEntry({
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.operatorName,
    this.rejectCode,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    'operatorName': operatorName,
    'rejectCode': rejectCode,
  };

  factory ProductionCounterEntry.fromJson(Map<String, dynamic> json) =>
      ProductionCounterEntry(
        type: json['type'] as String,
        amount: json['amount'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        operatorName: json['operatorName'] as String,
        rejectCode: json['rejectCode'] as String?,
      );
}
