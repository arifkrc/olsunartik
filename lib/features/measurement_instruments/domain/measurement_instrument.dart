class MeasurementInstrument {
  final String id;
  final String brand; // Marka
  final String name; // Ad
  final String measurementRange; // Ölçüm aralığı
  final String precision; // Hassasiyet
  final String serialNumber; // Seri no
  final String instrumentNumber; // Ölçü Aleti no
  final DateTime calibrationValidDate; // Kalibrasyon geçerlilik tarihi
  final String? description; // Açıklama

  MeasurementInstrument({
    required this.id,
    required this.brand,
    required this.name,
    required this.measurementRange,
    required this.precision,
    required this.serialNumber,
    required this.instrumentNumber,
    required this.calibrationValidDate,
    this.description,
  });

  bool get isCalibrationValid {
    final now = DateTime.now();
    // Reset time part of now for day comparison, or just compare roughly
    final today = DateTime(now.year, now.month, now.day);
    final validDate = DateTime(
      calibrationValidDate.year,
      calibrationValidDate.month,
      calibrationValidDate.day,
    );
    return validDate.isAfter(today);
  }
}
