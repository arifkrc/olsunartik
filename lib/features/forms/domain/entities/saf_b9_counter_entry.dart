class SafB9CounterEntry {
  final int? id;
  final String urunKodu;
  final String urunAdi;
  final int duzceCount;
  final int almanyaCount;
  final int hurdaCount;
  final String? retNedeni;
  final DateTime kayitTarihi;

  SafB9CounterEntry({
    this.id,
    required this.urunKodu,
    required this.urunAdi,
    required this.duzceCount,
    required this.almanyaCount,
    required this.hurdaCount,
    this.retNedeni,
    required this.kayitTarihi,
  });
}
