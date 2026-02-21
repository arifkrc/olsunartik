class NumuneForm {
  final int? id;
  final int urunId;
  final String? urunKodu; // API response'dan gelir
  final String? urunAdi; // API response'dan gelir
  final String? urunTuru; // API response'dan gelir
  final int adet;
  final String sarjNo; // Yeni eklendi (payload)
  final String numuneBasligi; // payload
  final String genelSonuc; // payload (önceki testSonucu yerine)
  final String gorsel; // payload (base64 vb olabilir)
  final DateTime? kayitTarihi; // olusturmaZamani

  NumuneForm({
    this.id,
    required this.urunId,
    this.urunKodu,
    this.urunAdi,
    this.urunTuru,
    required this.adet,
    required this.sarjNo,
    required this.numuneBasligi,
    required this.genelSonuc,
    this.gorsel = '', // Şimdilik boş string default
    this.kayitTarihi,
  });
}
