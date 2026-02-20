// Analytics Range DTO
// Maps the full /api/v1/analytics/range response structure
// API returns: { "data": [ { "tarih": "...", "kaliteOnay": {...}, ... }, ... ], "success": true }
// All daily items are aggregated (summed) into a single AnalyticsRangeDto.

class KaliteOnayUrunStatDto {
  final int uygun;
  final int ret;

  KaliteOnayUrunStatDto({required this.uygun, required this.ret});

  factory KaliteOnayUrunStatDto.fromJson(Map<String, dynamic> json) =>
      KaliteOnayUrunStatDto(
        uygun: json['uygun'] as int? ?? 0,
        ret: json['ret'] as int? ?? 0,
      );

  KaliteOnayUrunStatDto operator +(KaliteOnayUrunStatDto other) =>
      KaliteOnayUrunStatDto(uygun: uygun + other.uygun, ret: ret + other.ret);
}

class KaliteOnayAnalyticsDto {
  final int toplamUygun;
  final int toplamRet;
  final Map<String, KaliteOnayUrunStatDto> urunGrubuStats;

  KaliteOnayAnalyticsDto({
    required this.toplamUygun,
    required this.toplamRet,
    required this.urunGrubuStats,
  });

  factory KaliteOnayAnalyticsDto.fromJson(Map<String, dynamic> json) {
    final rawStats = json['urunGrubuStats'] as Map<String, dynamic>? ?? {};
    final stats = rawStats.map(
      (k, v) => MapEntry(k, KaliteOnayUrunStatDto.fromJson(v as Map<String, dynamic>)),
    );
    return KaliteOnayAnalyticsDto(
      toplamUygun: json['toplamUygun'] as int? ?? 0,
      toplamRet: json['toplamRet'] as int? ?? 0,
      urunGrubuStats: stats,
    );
  }

  static KaliteOnayAnalyticsDto aggregate(List<KaliteOnayAnalyticsDto> items) {
    int totalUygun = 0;
    int totalRet = 0;
    final Map<String, KaliteOnayUrunStatDto> merged = {};
    for (final item in items) {
      totalUygun += item.toplamUygun;
      totalRet += item.toplamRet;
      for (final entry in item.urunGrubuStats.entries) {
        merged[entry.key] = merged.containsKey(entry.key)
            ? merged[entry.key]! + entry.value
            : entry.value;
      }
    }
    return KaliteOnayAnalyticsDto(
      toplamUygun: totalUygun,
      toplamRet: totalRet,
      urunGrubuStats: merged,
    );
  }
}

class FinalKontrolUrunStatDto {
  final int uygun;
  final int ret;
  final int rework;

  FinalKontrolUrunStatDto({
    required this.uygun,
    required this.ret,
    required this.rework,
  });

  factory FinalKontrolUrunStatDto.fromJson(Map<String, dynamic> json) =>
      FinalKontrolUrunStatDto(
        uygun: json['uygun'] as int? ?? 0,
        ret: json['ret'] as int? ?? 0,
        rework: json['rework'] as int? ?? 0,
      );

  FinalKontrolUrunStatDto operator +(FinalKontrolUrunStatDto other) =>
      FinalKontrolUrunStatDto(
        uygun: uygun + other.uygun,
        ret: ret + other.ret,
        rework: rework + other.rework,
      );
}

class FinalKontrolAnalyticsDto {
  final int toplamUygun;
  final int toplamRet;
  final int toplamRework;
  final Map<String, FinalKontrolUrunStatDto> urunGrubuStats;

  FinalKontrolAnalyticsDto({
    required this.toplamUygun,
    required this.toplamRet,
    required this.toplamRework,
    required this.urunGrubuStats,
  });

  factory FinalKontrolAnalyticsDto.fromJson(Map<String, dynamic> json) {
    final rawStats = json['urunGrubuStats'] as Map<String, dynamic>? ?? {};
    final stats = rawStats.map(
      (k, v) => MapEntry(k, FinalKontrolUrunStatDto.fromJson(v as Map<String, dynamic>)),
    );
    return FinalKontrolAnalyticsDto(
      toplamUygun: json['toplamUygun'] as int? ?? 0,
      toplamRet: json['toplamRet'] as int? ?? 0,
      toplamRework: json['toplamRework'] as int? ?? 0,
      urunGrubuStats: stats,
    );
  }

  static FinalKontrolAnalyticsDto aggregate(List<FinalKontrolAnalyticsDto> items) {
    int totalUygun = 0, totalRet = 0, totalRework = 0;
    final Map<String, FinalKontrolUrunStatDto> merged = {};
    for (final item in items) {
      totalUygun += item.toplamUygun;
      totalRet += item.toplamRet;
      totalRework += item.toplamRework;
      for (final entry in item.urunGrubuStats.entries) {
        merged[entry.key] = merged.containsKey(entry.key)
            ? merged[entry.key]! + entry.value
            : entry.value;
      }
    }
    return FinalKontrolAnalyticsDto(
      toplamUygun: totalUygun,
      toplamRet: totalRet,
      toplamRework: totalRework,
      urunGrubuStats: merged,
    );
  }
}

class GirisKaliteAnalyticsDto {
  final int toplamKontrol;
  final int toplamOnay;
  final int toplamRet;

  GirisKaliteAnalyticsDto({
    required this.toplamKontrol,
    required this.toplamOnay,
    required this.toplamRet,
  });

  factory GirisKaliteAnalyticsDto.fromJson(Map<String, dynamic> json) =>
      GirisKaliteAnalyticsDto(
        toplamKontrol: json['toplamKontrol'] as int? ?? 0,
        toplamOnay: json['toplamOnay'] as int? ?? 0,
        toplamRet: json['toplamRet'] as int? ?? 0,
      );

  static GirisKaliteAnalyticsDto aggregate(List<GirisKaliteAnalyticsDto> items) =>
      GirisKaliteAnalyticsDto(
        toplamKontrol: items.fold(0, (s, e) => s + e.toplamKontrol),
        toplamOnay: items.fold(0, (s, e) => s + e.toplamOnay),
        toplamRet: items.fold(0, (s, e) => s + e.toplamRet),
      );
}

class FireAnalyticsDto {
  final int toplamAdet;
  final Map<String, int> urunBazinda;
  final Map<String, int> retKoduBazinda;

  FireAnalyticsDto({
    required this.toplamAdet,
    required this.urunBazinda,
    required this.retKoduBazinda,
  });

  factory FireAnalyticsDto.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseIntMap(dynamic raw) {
      if (raw == null) return {};
      return (raw as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    return FireAnalyticsDto(
      toplamAdet: json['toplamAdet'] as int? ?? 0,
      urunBazinda: parseIntMap(json['urunBazinda']),
      retKoduBazinda: parseIntMap(json['retKoduBazinda']),
    );
  }

  static FireAnalyticsDto aggregate(List<FireAnalyticsDto> items) {
    Map<String, int> mergeIntMaps(List<Map<String, int>> maps) {
      final result = <String, int>{};
      for (final m in maps) {
        for (final e in m.entries) {
          result[e.key] = (result[e.key] ?? 0) + e.value;
        }
      }
      return result;
    }

    return FireAnalyticsDto(
      toplamAdet: items.fold(0, (s, e) => s + e.toplamAdet),
      urunBazinda: mergeIntMaps(items.map((e) => e.urunBazinda).toList()),
      retKoduBazinda: mergeIntMaps(items.map((e) => e.retKoduBazinda).toList()),
    );
  }
}

class ReworkFormAnalyticsDto {
  final int toplamAdet;
  final Map<String, int> urunBazinda;

  ReworkFormAnalyticsDto({
    required this.toplamAdet,
    required this.urunBazinda,
  });

  factory ReworkFormAnalyticsDto.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseIntMap(dynamic raw) {
      if (raw == null) return {};
      return (raw as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    return ReworkFormAnalyticsDto(
      toplamAdet: json['toplamAdet'] as int? ?? 0,
      urunBazinda: parseIntMap(json['urunBazinda']),
    );
  }

  static ReworkFormAnalyticsDto aggregate(List<ReworkFormAnalyticsDto> items) {
    final Map<String, int> merged = {};
    for (final item in items) {
      for (final e in item.urunBazinda.entries) {
        merged[e.key] = (merged[e.key] ?? 0) + e.value;
      }
    }
    return ReworkFormAnalyticsDto(
      toplamAdet: items.fold(0, (s, e) => s + e.toplamAdet),
      urunBazinda: merged,
    );
  }
}

class ReworkAnalizAnalyticsDto {
  final Map<String, int> tureGoreToplam;
  final Map<String, int> hataNedenleriVeAdetler;

  ReworkAnalizAnalyticsDto({
    required this.tureGoreToplam,
    required this.hataNedenleriVeAdetler,
  });

  factory ReworkAnalizAnalyticsDto.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseIntMap(dynamic raw) {
      if (raw == null) return {};
      return (raw as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    return ReworkAnalizAnalyticsDto(
      tureGoreToplam: parseIntMap(json['tureGoreToplam']),
      hataNedenleriVeAdetler: parseIntMap(json['hataNedenleriVeAdetler']),
    );
  }

  static ReworkAnalizAnalyticsDto aggregate(List<ReworkAnalizAnalyticsDto> items) {
    Map<String, int> mergeIntMaps(List<Map<String, int>> maps) {
      final result = <String, int>{};
      for (final m in maps) {
        for (final e in m.entries) {
          result[e.key] = (result[e.key] ?? 0) + e.value;
        }
      }
      return result;
    }

    return ReworkAnalizAnalyticsDto(
      tureGoreToplam: mergeIntMaps(items.map((e) => e.tureGoreToplam).toList()),
      hataNedenleriVeAdetler: mergeIntMaps(items.map((e) => e.hataNedenleriVeAdetler).toList()),
    );
  }
}

class NumuneRecordDto {
  final String urunKodu;
  final DateTime testTarihi;
  final String sonuc;
  final String personelAdi;

  NumuneRecordDto({
    required this.urunKodu,
    required this.testTarihi,
    required this.sonuc,
    required this.personelAdi,
  });

  factory NumuneRecordDto.fromJson(Map<String, dynamic> json) =>
      NumuneRecordDto(
        urunKodu: json['urunKodu'] as String? ?? '',
        testTarihi: json['testTarihi'] != null
            ? DateTime.parse(json['testTarihi'] as String)
            : DateTime.now(),
        sonuc: json['sonuc'] as String? ?? '',
        personelAdi: json['personelAdi'] as String? ?? '',
      );
}

/// Aggregated analytics for a date range.
/// Built by summing all daily items returned by the API.
class AnalyticsRangeDto {
  final String tarih; // e.g. "2026-02-19 – 2026-02-20" (summary label)
  final DateTime lastCalculatedAt;
  final KaliteOnayAnalyticsDto kaliteOnay;
  final FinalKontrolAnalyticsDto finalKontrol;
  final GirisKaliteAnalyticsDto girisKalite;
  final FireAnalyticsDto fire;
  final ReworkFormAnalyticsDto reworkFormu;
  final ReworkAnalizAnalyticsDto reworkAnaliz;
  final List<NumuneRecordDto> numuneRecords;

  AnalyticsRangeDto({
    required this.tarih,
    required this.lastCalculatedAt,
    required this.kaliteOnay,
    required this.finalKontrol,
    required this.girisKalite,
    required this.fire,
    required this.reworkFormu,
    required this.reworkAnaliz,
    required this.numuneRecords,
  });

  /// Parse the API response.
  /// Supports both:
  ///   - { "data": [ {...}, {...} ], "success": true }  ← real API (array)
  ///   - { "tarih": "...", "kaliteOnay": {...}, ... }   ← single-day fallback
  factory AnalyticsRangeDto.fromJson(Map<String, dynamic> json) {
    // Unwrap envelope if present
    final rawData = json['data'];

    // Array response (real API)
    if (rawData is List && rawData.isNotEmpty) {
      final items = rawData.cast<Map<String, dynamic>>();

      // Parse all daily items
      final kaliteOnayList = items
          .map((e) => KaliteOnayAnalyticsDto.fromJson(
              e['kaliteOnay'] as Map<String, dynamic>? ?? {}))
          .toList();
      final finalKontrolList = items
          .map((e) => FinalKontrolAnalyticsDto.fromJson(
              e['finalKontrol'] as Map<String, dynamic>? ?? {}))
          .toList();
      final girisKaliteList = items
          .map((e) => GirisKaliteAnalyticsDto.fromJson(
              e['girisKalite'] as Map<String, dynamic>? ?? {}))
          .toList();
      final fireList = items
          .map((e) => FireAnalyticsDto.fromJson(
              e['fire'] as Map<String, dynamic>? ?? {}))
          .toList();
      final reworkFormList = items
          .map((e) => ReworkFormAnalyticsDto.fromJson(
              e['reworkFormu'] as Map<String, dynamic>? ?? {}))
          .toList();
      final reworkAnalizList = items
          .map((e) => ReworkAnalizAnalyticsDto.fromJson(
              e['reworkAnaliz'] as Map<String, dynamic>? ?? {}))
          .toList();
      final numuneRecords = items
          .expand((e) =>
              (e['numuneRecords'] as List<dynamic>? ?? [])
                  .map((r) => NumuneRecordDto.fromJson(r as Map<String, dynamic>)))
          .toList();

      // Use the latest lastCalculatedAt across all items
      final lastCalc = items
          .map((e) => e['lastCalculatedAt'] != null
              ? DateTime.parse(e['lastCalculatedAt'] as String)
              : DateTime.now())
          .reduce((a, b) => a.isAfter(b) ? a : b);

      // Build date range label
      final tarihLabel = items.length == 1
          ? items.first['tarih'] as String? ?? ''
          : '${items.first['tarih']} – ${items.last['tarih']}';

      return AnalyticsRangeDto(
        tarih: tarihLabel,
        lastCalculatedAt: lastCalc,
        kaliteOnay: KaliteOnayAnalyticsDto.aggregate(kaliteOnayList),
        finalKontrol: FinalKontrolAnalyticsDto.aggregate(finalKontrolList),
        girisKalite: GirisKaliteAnalyticsDto.aggregate(girisKaliteList),
        fire: FireAnalyticsDto.aggregate(fireList),
        reworkFormu: ReworkFormAnalyticsDto.aggregate(reworkFormList),
        reworkAnaliz: ReworkAnalizAnalyticsDto.aggregate(reworkAnalizList),
        numuneRecords: numuneRecords,
      );
    }

    // Single-object fallback (older shape or empty array)
    final data = rawData is Map<String, dynamic>
        ? rawData
        : (rawData == null ? json : json);
    return AnalyticsRangeDto(
      tarih: data['tarih'] as String? ?? '',
      lastCalculatedAt: data['lastCalculatedAt'] != null
          ? DateTime.parse(data['lastCalculatedAt'] as String)
          : DateTime.now(),
      kaliteOnay: KaliteOnayAnalyticsDto.fromJson(
          data['kaliteOnay'] as Map<String, dynamic>? ?? {}),
      finalKontrol: FinalKontrolAnalyticsDto.fromJson(
          data['finalKontrol'] as Map<String, dynamic>? ?? {}),
      girisKalite: GirisKaliteAnalyticsDto.fromJson(
          data['girisKalite'] as Map<String, dynamic>? ?? {}),
      fire: FireAnalyticsDto.fromJson(
          data['fire'] as Map<String, dynamic>? ?? {}),
      reworkFormu: ReworkFormAnalyticsDto.fromJson(
          data['reworkFormu'] as Map<String, dynamic>? ?? {}),
      reworkAnaliz: ReworkAnalizAnalyticsDto.fromJson(
          data['reworkAnaliz'] as Map<String, dynamic>? ?? {}),
      numuneRecords: (data['numuneRecords'] as List<dynamic>? ?? [])
          .map((e) => NumuneRecordDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
