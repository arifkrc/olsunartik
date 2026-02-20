/// Production and Analysis Constants
/// Business logic constants for production calculations and fire analysis
class ProductionConstants {
  ProductionConstants._(); // Private constructor

  // Fire Analysis
  /// Estimated production multiplier for fire records
  /// NOTE: This is a mock value. Real production data should come from backend.
  static const int estimatedProductionMultiplier = 20;

  static const String estimationNote =
      'Production quantity is estimated. Backend integration required for actual values.';

  // Default Factory Values
  static const String defaultFactory = 'FRENBU';
  static const String defaultProductType = 'Disk';

  // Factory Names
  static const List<String> factories = ['FRENBU', 'D2', 'D3'];

  // Production Counter Limits
  static const int maxProductionQuantity = 9999;
  static const int minProductionQuantity = 0;

  // Quick Add Buttons
  static const List<int> quickAddAmounts = [1, 5, 10];

  // Hurda (Scrap) Reasons
  static const List<String> hurdaReasons = [
    'SEVK_PAKET',
    'OXY_KAPAK',
    'MAKINA_ARIZA',
    'KALITE_HATA',
    'OPERATOR_HATA',
    'MALZEME_HATA',
    'OLCU_UYGUNSUZ',
    'YUZEY_HATA',
    'MONTAJ_HATA',
    'TASIMA_HASAR',
    'DIGER',
    'BILINMEYEN',
  ];

  // Date Range Limits
  static const int maxDateRangeDays = 365;
  static const int defaultDateRangeDays = 30;
}
