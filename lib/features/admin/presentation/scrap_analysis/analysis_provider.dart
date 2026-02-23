import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';
import '../providers/fire_analiz_providers.dart';
import '../../data/models/fire_analiz_dto.dart';

class ScrapAnalysisState {
  final bool isLoading;
  final String? error;
  final ScrapDashboardData? dashboardData;

  ScrapAnalysisState({this.isLoading = false, this.error, this.dashboardData});

  ScrapAnalysisState copyWith({
    bool? isLoading,
    String? error,
    ScrapDashboardData? dashboardData,
  }) {
    return ScrapAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      dashboardData: dashboardData ?? this.dashboardData,
    );
  }
}

class ScrapAnalysisNotifier extends Notifier<ScrapAnalysisState> {
  @override
  ScrapAnalysisState build() {
    return ScrapAnalysisState();
  }

  Future<List<ScrapUploadItem>> parseExcel(List<int> bytes) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final excel = Excel.decodeBytes(bytes);
      final List<ScrapUploadItem> productionItems = [];

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        for (var row in sheet.rows) {
          if (row.isEmpty) continue;

          // Header Check (skip row if contains 'kod')
          final firstCellVal = row[0]?.value?.toString() ?? '';
          if (firstCellVal.toLowerCase().contains('tarih') ||
              firstCellVal.toLowerCase().contains('kod')) {
            continue;
          }

          if (row.length < 4) continue; // Col A, B, C, D (Index 0, 1, 2, 3)

          // 0: Date (Optional, can extract if needed)
          // 1: Product Code
          // 2: Factory (D2, D3)
          // 3: Quantity
          // 4: Hole Quantity (Optional)

          DateTime? date;
        try {
          final dateCell = row[0];
          final dVal = _extractCellValue(dateCell?.value);

          if (dVal is DateTime) {
            date = dVal;
          } else if (dVal is num) {
            // Excel Serial Date (Days since 1900-01-01)
            // 25569 is the offset between 1900 and 1970
            date = DateTime(1899, 12, 30).add(Duration(days: dVal.toInt()));
          } else if (dVal != null) {
            final dateStr = dVal.toString().trim();
            // Handle dd.MM.yyyy, dd/MM/yyyy, dd-MM-yyyy
            final separators = ['.', '/', '-'];
            for (var sep in separators) {
              final parts = dateStr.split(sep);
              if (parts.length == 4) { // Handle case where space or something adds extra parts
                  // ...
              }
              if (parts.length == 3) {
                try {
                  int day = int.parse(parts[0]);
                  int month = int.parse(parts[1]);
                  int year = int.parse(parts[2]);
                  
                  if (year < 100) year += 2000;
                  
                  date = DateTime(year, month, day);
                  break;
                } catch (_) {}
              }
            }
            
            // Final fallback to DateTime.tryParse (ISO format)
            date ??= DateTime.tryParse(dateStr);
          }
        } catch (_) {}

        final productCode =
              _extractCellValue(row[1]?.value)?.toString().trim() ?? '';
          final factory =
              _extractCellValue(
                row[2]?.value,
              )?.toString().trim().toUpperCase() ??
              '';

          final quantityCell = row[3];

          // Safer Column E Access
          dynamic holeQtyCell;
          if (row.length > 4) {
            holeQtyCell = row[4];
          }

          int quantity = _parseQuantity(quantityCell);
          int holeQty = _parseQuantity(holeQtyCell);

          if (productCode.isNotEmpty) {
            productionItems.add(
              ScrapUploadItem(
                date: date,
                productCode: productCode,
                factory: factory,
                quantity: quantity,
                holeQty: holeQty,
              ),
            );
          }
        }
      }

      state = state.copyWith(isLoading: false);
      return productionItems;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Analiz hatası: $e');
      throw Exception('Excel ayrıştırma hatası: $e');
    }
  }

  Future<void> fetchDashboardData(DateTime date, {bool forceCalculate = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(fireAnalizRepositoryProvider);
      
      // Format date as yyyy-MM-dd
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final FireAnalizDetayDto detayDto;
      if (forceCalculate) {
        // Trigger calculation (POST /api/fire-analiz/hesapla)
        detayDto = await repository.hesapla(dateStr);
      } else {
        // Just fetch details (GET /api/fire-analiz/{date})
        detayDto = await repository.getDetayByTarih(dateStr);
      }

      final frenbuTable = <ScrapTableItem>[];
      final d2Table = <ScrapTableItem>[];
      final d3Table = <ScrapTableItem>[];
      final frenbuClean = <ProductionEntry>[];
      final d2Clean = <ProductionEntry>[];
      final d3Clean = <ProductionEntry>[];

      for (var urun in detayDto.urunDetaylari) {
        if (urun.segment == 1) { // Frenbu
          if (urun.fireVar) {
            frenbuTable.add(
              ScrapTableItem(
                productType: urun.urunTuru,
                productCode: urun.urunKodu,
                productionQty: urun.uretimAdeti,
                scrapQty: urun.fireAdeti,
                scrapRate: urun.fireOrani,
                details: [], // Optionally decode details from `hataDetaylari` if provided as string
              ),
            );
          } else {
            frenbuClean.add(
              ProductionEntry(
                productCode: urun.urunKodu,
                factoryType: 'FRENBU',
                quantity: urun.uretimAdeti,
              ),
            );
          }
        } else if (urun.segment == 2) { // D2
          if (urun.fireVar) {
            d2Table.add(
              ScrapTableItem(
                productType: urun.urunTuru,
                productCode: urun.urunKodu,
                productionQty: urun.uretimAdeti,
                scrapQty: urun.fireAdeti,
                scrapRate: urun.fireOrani,
              ),
            );
          } else {
            d2Clean.add(
              ProductionEntry(
                productCode: urun.urunKodu,
                factoryType: 'D2',
                quantity: urun.uretimAdeti,
              ),
            );
          }
        } else if (urun.segment == 3) { // D3
          if (urun.fireVar) {
            d3Table.add(
              ScrapTableItem(
                productType: urun.urunTuru,
                productCode: urun.urunKodu,
                productionQty: urun.uretimAdeti,
                scrapQty: urun.fireAdeti,
                scrapRate: urun.fireOrani,
              ),
            );
          } else {
            d3Clean.add(
              ProductionEntry(
                productCode: urun.urunKodu,
                factoryType: 'D3',
                quantity: urun.uretimAdeti,
              ),
            );
          }
        }
      }

      // Populate Distribution
      final distribution = <DefectDistributionItem>[];
      // Group by hataKodu
      final groupedHata = <String, Map<String, num>>{};
      for (var dist in detayDto.hataDagilimleri) {
         groupedHata.putIfAbsent(dist.hataKodu, () => {'disk': 0, 'drum': 0, 'hub': 0, 'total': 0});
         
         if (dist.urunTuru.toLowerCase().contains('disk')) {
           groupedHata[dist.hataKodu]!['disk'] = (groupedHata[dist.hataKodu]!['disk'] ?? 0) + dist.fireAdeti;
         } else if (dist.urunTuru.toLowerCase().contains('kampana')) {
           groupedHata[dist.hataKodu]!['drum'] = (groupedHata[dist.hataKodu]!['drum'] ?? 0) + dist.fireAdeti;
         } else if (dist.urunTuru.toLowerCase().contains('porya')) {
           groupedHata[dist.hataKodu]!['hub'] = (groupedHata[dist.hataKodu]!['hub'] ?? 0) + dist.fireAdeti;
         }
         groupedHata[dist.hataKodu]!['total'] = (groupedHata[dist.hataKodu]!['total'] ?? 0) + dist.fireAdeti;
      }

      final double totalFrenbuScrapCalculated = detayDto.frenbuFireAdeti.toDouble();

      groupedHata.forEach((hataKodu, data) {
        final total = (data['total'] ?? 0).toInt();
        distribution.add(
          DefectDistributionItem(
            defectName: hataKodu,
            diskScrap: (data['disk'] ?? 0).toInt(),
            drumScrap: (data['drum'] ?? 0).toInt(),
            hubScrap: (data['hub'] ?? 0).toInt(),
            total: total,
            rate: totalFrenbuScrapCalculated > 0 ? (total / totalFrenbuScrapCalculated) * 100 : 0,
          )
        );
      });

      frenbuTable.sort((a, b) => b.scrapRate.compareTo(a.scrapRate));
      d2Table.sort((a, b) => b.scrapRate.compareTo(a.scrapRate));
      d3Table.sort((a, b) => b.scrapRate.compareTo(a.scrapRate));

      final dashboardData = ScrapDashboardData(
        date: date,
        totalFrenbuProduction: detayDto.frenbuUretimAdeti,
        summary: FactorySummary(
          d2ScrapDto: detayDto.d2FireAdeti,
          d2Turned: detayDto.d2UretimAdeti,
          d2Rate: detayDto.d2FireOrani,
          d3ScrapDto: detayDto.d3FireAdeti,
          d3Turned: detayDto.d3UretimAdeti,
          d3Rate: detayDto.d3FireOrani,
          frenbuScrapDto: detayDto.frenbuFireAdeti,
          frenbuTurned: detayDto.frenbuUretimAdeti,
          frenbuRate: detayDto.frenbuFireOrani,
        ),
        dailyScrapRates: [
          FactoryDailyScrap('D2', detayDto.d2FireOrani),
          FactoryDailyScrap('D3', detayDto.d3FireOrani),
          FactoryDailyScrap('FRENBU', detayDto.frenbuFireOrani),
        ],
        holeProductionStats: {
          'D2': detayDto.d2DelikAdeti,
          'D3': detayDto.d3DelikAdeti,
          'FRENBU': detayDto.frenbuDelikAdeti,
        },
        frenbuTable: frenbuTable,
        frenbuDefectDistribution: distribution,
        frenbuCleanProducts: frenbuClean, 
        frenbuShifts: [], // Optional/Mock feature removed or leave empty
        d2Table: d2Table,
        d3Table: d3Table,
        d2CleanProducts: d2Clean,
        d3CleanProducts: d3Clean,
      );

      state = state.copyWith(isLoading: false, dashboardData: dashboardData);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Hesaplama verisi alınamadı: $e');
    }
  }

  dynamic _extractCellValue(dynamic val) {
    if (val == null) return null;
    if (val is IntCellValue) return val.value;
    if (val is DoubleCellValue) return val.value;
    if (val is TextCellValue) return val.value;
    if (val is DateCellValue) return val.asDateTimeLocal;
    return val;
  }

  int _parseQuantity(dynamic cell) {
    if (cell == null) return 0;
    var val = cell is Data ? cell.value : cell;
    val = _extractCellValue(val);

    if (val == null) return 0;

    if (val is int) return val;
    if (val is double) return val.toInt();

    final strVal = val.toString().trim().replaceAll(' ', '');
    if (strVal.isEmpty) return 0;

    return int.tryParse(strVal) ?? 0;
  }

  void reset() {
    state = ScrapAnalysisState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}


final scrapAnalysisProvider =
    NotifierProvider<ScrapAnalysisNotifier, ScrapAnalysisState>(
      ScrapAnalysisNotifier.new,
    );
