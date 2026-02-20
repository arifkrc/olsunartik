/// Centralized constants for form dropdown options
/// Eliminates hardcoded data scattered across presentation screens
class FormOptions {
  FormOptions._(); // Private constructor to prevent instantiation

  // Machine options
  static const List<String> machines = [
    'T01',
    'T02',
    'T03',
    'T04',
    'T05',
    'CNC-A',
    'CNC-B',
    'CNC-C',
    'M21',
    'M22',
  ];

  // Zone options
  static const List<String> zones = [
    'Z1 (Giriş)',
    'Z2 (İşleme)',
    'Z3 (Montaj)',
    'Z4 (Paketleme)',
    'Z5 (Depo)',
  ];

  // Error reasons for fire kayit
  static const List<String> errorReasons = [
    'İç Çap Hatası',
    'Dış Çap Hatası',
    'Profil Hatası',
    'Yüzey Kalitesi',
    'Çapak',
    'Darbe/Çizik',
    'Boyut Hatası',
    'Montaj Uyumsuzluğu',
    'Diğer',
  ];

  // Operation options
  static const List<String> operations = [
    'İşleme',
    'Montaj',
    'Kalite Kontrol',
    'Paketleme',
    'Taşıma',
  ];

  // Reject codes for quality approval
  static const List<String> rejectCodes = [
    'Hata 001 - Boyut Hatası',
    'Hata 002 - Yüzey Hatası',
    'Hata 003 - Montaj Hatası',
  ];

  // Product state options
  static const List<String> productStates = ['İşlenmiş', 'Ham'];

  // Tezgah list for SAF B9
  static const List<String> tezgahList = [
    'Tezgah 1',
    'Tezgah 2',
    'Tezgah 3',
    'Tezgah 4',
    'Tezgah 5',
  ];
}
