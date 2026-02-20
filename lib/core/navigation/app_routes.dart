/// Application route names
/// Centralized route definitions for named routing
class AppRoutes {
  AppRoutes._(); // Private constructor

  // Auth routes
  static const String login = '/login';
  static const String splash = '/';

  // Main routes
  static const String home = '/home';
  static const String profile = '/profile';
  static const String about = '/about';

  // Form routes
  static const String forms = '/forms';
  static const String qualityApproval = '/forms/quality-approval';
  static const String fireKayit = '/forms/fire-kayit';
  static const String safB9Counter = '/forms/saf-b9-counter';
  static const String finalKontrol = '/forms/final-kontrol';
  static const String numuneScreen = '/forms/numune';
  static const String denemeNumune = '/forms/deneme-numune';
  static const String girisDeneme = '/forms/giris-deneme';
  static const String rework = '/forms/rework';
  static const String paletGiris = '/forms/palet-giris';

  // Admin routes
  static const String adminPanel = '/admin';
  static const String scrapAnalysis = '/admin/scrap-analysis';

  // Other routes
  static const String shiftNotes = '/shift-notes';
  static const String history = '/history';
  static const String measurementInstruments = '/measurement-instruments';
}
