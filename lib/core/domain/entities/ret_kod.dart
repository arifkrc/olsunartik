/// Ret Kodu entity — kalite onay formunda kullanılır
class RetKod {
  final int id;
  final String kod;
  final String aciklama;

  const RetKod({
    required this.id,
    required this.kod,
    required this.aciklama,
  });

  /// Dropdown'da görüntülenecek label
  String get displayLabel => '$kod - $aciklama';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is RetKod && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
