class Tezgah {
  final int id;
  final String tezgahNo;
  final String tezgahTuru;

  const Tezgah({
    required this.id,
    required this.tezgahNo,
    required this.tezgahTuru,
  });

  String get displayLabel => '$tezgahNo - $tezgahTuru';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Tezgah && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
