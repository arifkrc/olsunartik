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
        print('PROCESSING SHEET: $table, Rows=${sheet.rows.length}');

        for (var row in sheet.rows) {
          if (row.isEmpty) continue;
          
          final rowLen = row.length;
          final firstCell = _extractCellValue(row[0]?.value)?.toString().trim() ?? '';
          final secondCell = rowLen > 1 ? _extractCellValue(row[1]?.value)?.toString().trim() ?? '' : '';

          if (rowLen < 2) continue;

          final productCode = secondCell;
          
          // Skip if productCode is empty or is a header ('kod')
          if (productCode.isEmpty || productCode.toLowerCase().contains('kod')) {
            continue;
          }

          // Header Check for row[0] (skip row if explicitly 'tarih' or 'date')
          if (firstCell.toLowerCase().contains('tarih') ||
              firstCell.toLowerCase().contains('date')) {
            continue;
          }

          if (rowLen < 4) {
            print('SKIPPING ROW: length=$rowLen (Expected 4+), Cell0=$firstCell, Cell1=$productCode');
            continue;
          }

          DateTime? date;
          try {
            final dateCell = row[0];
            final dVal = _extractCellValue(dateCell?.value);

            if (dVal is DateTime) {
              date = dVal;
            } else if (dVal is num) {
              date = DateTime(1899, 12, 30).add(Duration(days: dVal.toInt()));
            } else if (dVal != null) {
              var dateStr = dVal.toString().trim();
              if (dateStr.isNotEmpty) {
                if (dateStr.contains(' ')) {
                  dateStr = dateStr.split(' ')[0];
                } else if (dateStr.contains('T')) {
                  dateStr = dateStr.split('T')[0];
                }

                final separators = ['.', '/', '-'];
                for (var sep in separators) {
                  if (dateStr.contains(sep)) {
                    final parts = dateStr.split(sep);
                    if (parts.length >= 3) {
                      try {
                        int day, month, year;
                        if (parts[0].length == 4) {
                          year = int.parse(parts[0]);
                          month = int.parse(parts[1]);
                          day = int.parse(parts[2]);
                        } else {
                          day = int.parse(parts[0]);
                          month = int.parse(parts[1]);
                          year = int.parse(parts[2]);
                        }
                        if (year < 100) year += 2000;
                        date = DateTime(year, month, day);
                        break;
                      } catch (_) {}
                    }
                  }
                }
                date ??= DateTime.tryParse(dateStr);
              }
            }
          } catch (_) {}

          final factory = _extractCellValue(row[2]?.value)?.toString().trim().toUpperCase() ?? '';
          final quantityCell = row[3];
          dynamic holeQtyCell = row.length > 4 ? row[4] : null;

          int quantity = _parseQuantity(quantityCell);
          int holeQty = _parseQuantity(holeQtyCell);

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

      state = state.copyWith(isLoading: false);
      return productionItems;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Analiz hatası: $e');
      throw Exception('Excel ayrıştırma hatası: $e');
    }
  }

  Future<void> fetchDashboardData(DateTime date, {bool forceCalculate = false, int? frenbuUretimAdeti}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(fireAnalizRepositoryProvider);
      
      // Format date as yyyy-MM-dd
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final FireAnalizDetayDto detayDto;
      if (forceCalculate) {
        detayDto = await repository.hesapla(dateStr, frenbuUretimAdeti: frenbuUretimAdeti);
      } else {
        detayDto = await repository.getDetayByTarih(dateStr);
      }

      // Handle 404/Empty analysis (represented by id=0)
      if (detayDto.id == 0) {
        state = state.copyWith(isLoading: false, dashboardData: null);
        return;
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
      
      final int totalUrun = detayDto.urunDetaylari.length;
      final int matchedUrun = frenbuTable.length + frenbuClean.length + d2Table.length + d2Clean.length + d3Table.length + d3Clean.length;

      if (totalUrun > 0 && matchedUrun == 0) {
        final List<int> distinctSegments = detayDto.urunDetaylari.map((e) => e.segment).toSet().toList();
        state = state.copyWith(
          isLoading: false, 
          error: 'Veri eşleştirme hatası: Gelen $totalUrun ürün kaydının hiçbiri (1:Frenbu, 2:D2, 3:D3) segmentlerine uymuyor. Gelen segmentler: $distinctSegments. Lütfen backend segment tanımlarını kontrol edin.'
        );
        return;
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
    } catch (e, s) {
      state = state.copyWith(isLoading: false, error: 'Hesaplama verisi alınamadı: $e\n$s');
    }
  }

  dynamic _extractCellValue(dynamic val) {
    if (val == null) return null;
    if (val is IntCellValue) return val.value;
    if (val is DoubleCellValue) return val.value;
    if (val is TextCellValue) return val.value;
    if (val is DateCellValue) return val.asDateTimeLocal;
    if (val is DateTimeCellValue) return val.asDateTimeLocal;
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
