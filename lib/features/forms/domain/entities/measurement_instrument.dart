class MeasurementInstrument {
  final int? id;
  final String ad;
  final String kod;
  final String tip;
  final DateTime sonKalibrasyon;
  final DateTime gelecekKalibrasyon;
  final String durum; // 'Aktif' or 'Bakımda'
  final String? aciklama;

  MeasurementInstrument({
    this.id,
    required this.ad,
    required this.kod,
    required this.tip,
    required this.sonKalibrasyon,
    required this.gelecekKalibrasyon,
    required this.durum,
    this.aciklama,
  });
}
