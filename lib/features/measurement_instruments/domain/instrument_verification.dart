import 'measurement_instrument.dart';

/// Ölçü aleti doğrulama kaydı - her seçilen alet için çoklu ölçüm tutar
class InstrumentVerificationEntry {
  final MeasurementInstrument instrument;
  List<String> measurements; // Çoklu ölçüm değerleri
  String? notes;

  InstrumentVerificationEntry({
    required this.instrument,
    List<String>? measurements,
    this.notes,
  }) : measurements = measurements ?? ['', '', ''];

  void addMeasurement() {
    measurements.add('');
  }

  void removeMeasurement(int index) {
    if (measurements.length > 1 && index >= 0 && index < measurements.length) {
      measurements.removeAt(index);
    }
  }
}

/// Tüm doğrulama formunun verisi
class InstrumentVerificationForm {
  final String id;
  final DateTime verificationDate;
  final List<InstrumentVerificationEntry> entries;
  final String? performedBy;

  InstrumentVerificationForm({
    required this.id,
    required this.verificationDate,
    required this.entries,
    this.performedBy,
  });
}
