/// Product entity - Pure business model
/// Ürün bilgilerini temsil eden domain entity
class Product {
  final int? id; // Backend'deki primary key — submission'da kullanılır
  final String urunKodu;
  final String urunAdi;
  final String urunTuru;

  const Product({
    this.id,
    required this.urunKodu,
    required this.urunAdi,
    required this.urunTuru,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.urunKodu == urunKodu &&
        other.urunAdi == urunAdi &&
        other.urunTuru == urunTuru;
  }

  @override
  int get hashCode =>
      id.hashCode ^ urunKodu.hashCode ^ urunAdi.hashCode ^ urunTuru.hashCode;

  @override
  String toString() =>
      'Product(id: $id, urunKodu: $urunKodu, urunAdi: $urunAdi, urunTuru: $urunTuru)';
}
