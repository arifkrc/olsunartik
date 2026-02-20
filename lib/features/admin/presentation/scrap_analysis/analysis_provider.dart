import 'package:excel/excel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

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

  Future<void> parseExcel(List<int> bytes) async {
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
            } else if (dVal is String) {
              // Try string format dd.MM.yyyy
              final dateStr = dVal.trim();
              final parts = dateStr.split('.');
              if (parts.length == 3) {
                date = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );
              }
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

      // Generate Dashboard Data
      // Use the date from the first batch or current date if not found
      DateTime initialDate = DateTime.now();
      if (productionItems.isNotEmpty && productionItems.first.date != null) {
        initialDate = productionItems.first.date!;
      }

      final dashboardData = _generateDashboardData(
        productionItems,
        initialDate,
      );
      state = state.copyWith(isLoading: false, dashboardData: dashboardData);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Analiz hatası: $e');
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
    // Handle Data object if passed directly
    var val = cell is Data ? cell.value : cell;
    val = _extractCellValue(val);

    if (val == null) return 0;

    if (val is int) return val;
    if (val is double) return val.toInt();

    // Robust String Parsing
    final strVal = val.toString().trim().replaceAll(' ', '');
    if (strVal.isEmpty) return 0;

    return int.tryParse(strVal) ?? 0;
  }

  ScrapDashboardData _generateDashboardData(
    List<ScrapUploadItem> productionItems,
    DateTime date,
  ) {
    // 1. MOCK SCRAP DATA (Simulating 'Fire Kayıtları' from database)
    // In real app, this would be fetched from repository based on Date Range
    // Structure: Defect Code, Product Code, Scrap Qty
    final List<Map<String, dynamic>> mockScrapData = [
      // Frenbu Scraps (Starts with T, TI, etc - usually TI)
      {'defect': 'Tİ-01', 'product': '1310130', 'qty': 1},
      {'defect': 'Tİ-02', 'product': '4210020', 'qty': 14},
      {'defect': 'Tİ-01', 'product': '5623060', 'qty': 1},
      {'defect': 'Tİ-03', 'product': '6312011', 'qty': 2},
      {'defect': 'Tİ-04', 'product': '6325360', 'qty': 1},
      // D2 Scraps (Starts with D)
      {'defect': 'D-01', 'product': '1820910', 'qty': 7},
      {'defect': 'D-02', 'product': '2621090', 'qty': 5},
      {'defect': 'D-03', 'product': '3921980', 'qty': 2},
      {'defect': 'D-01', 'product': '5623060', 'qty': 1},
      {'defect': 'D-05', 'product': '6340051', 'qty': 6},
      // D3 Scraps (Starts with D)
      {'defect': 'D-01', 'product': '1310130', 'qty': 7},
      {'defect': 'D-02', 'product': '4210010', 'qty': 7},
      {'defect': 'D-03', 'product': '4210020', 'qty': 11},
      {'defect': 'D-04', 'product': '4810310', 'qty': 1},

      // Some mock defects for distribution matrix
      {'defect': '1.Yön Bağlama Hatası', 'product': '5623060', 'qty': 1},
      {'defect': 'Darbeye Bağlı Kırık', 'product': '1310130', 'qty': 1},
      {'defect': 'Delik Kaçıklığı', 'product': '4210020', 'qty': 16},
    ];

    // 2. Aggregate Data
    final frenbuTable = <ScrapTableItem>[];
    final frenbuClean = <ProductionEntry>[]; // NEW
    final d2Table = <ScrapTableItem>[];
    final d3Table = <ScrapTableItem>[];
    final d2Clean = <ProductionEntry>[];
    final d3Clean = <ProductionEntry>[];

    int totalFrenbuProd = 0;
    int totalD2Scrap = 0;
    int totalD3Scrap = 0;
    int totalFrenbuScrap = 0;

    int totalD2Turned = 0;

    int totalD3Turned = 0;

    // Hole Production Stats - ADDED
    int totalD2Hole = 0;
    int totalD3Hole = 0;
    int totalFrenbuHole = 0;

    // Filter scraps by selected date (Mocking logic: if date is selected, we might want to vary data)
    // For now, we use static mock data but in real scenario, we would query DB with this date.
    final selectedScraps = mockScrapData;

    // In a real implementation:
    // final selectedScraps = await repository.getScrapsByDate(date);

    for (var item in productionItems) {
      // Accumulate Hole Qty - ADDED
      // Accumulate Hole Qty - CORRECTED LOGIC
      if (item.holeQty > 0) {
        if (item.factory == 'D2') {
          totalD2Hole += item.holeQty;
        } else if (item.factory == 'D3') {
          totalD3Hole += item.holeQty;
        } else {
          // If not D2 or D3, assume Frenbu/Other
          totalFrenbuHole += item.holeQty;
        }
      }

      // Find scraps for this product
      final productScraps = selectedScraps
          .where((s) => s['product'] == item.productCode)
          .toList();

      int dScrapQty = 0;
      int tiScrapQty = 0;

      for (var s in productScraps) {
        final defectCode = s['defect'] as String;
        final qty = s['qty'] as int;

        if (defectCode.startsWith('D')) {
          dScrapQty += qty;
        } else if (defectCode.startsWith('Tİ') ||
            defectCode.startsWith('TI') ||
            !defectCode.startsWith('D')) {
          // Treating non-D as Frenbu (Tİ) based on user prompt logic
          tiScrapQty += qty;
        }
      }

      String type = _getProductType(item.productCode);

      // FRENBU TABLE (TI Scraps)
      // Only process if it feels like a Frenbu part (implied by context or if it has TI scraps)
      // Or if we decide all parts go through Frenbu check?
      // Current logic: If it has TI scraps OR it is NOT D2/D3 specific?
      // Actually the Excel has 'Factory' column.
      // If Factory is D2, it contributes to D2. If D3, to D3.
      // But typically ALL parts might be processed in Frenbu too?
      // Let's assume ANY part can be in Frenbu list if it has production there.
      // For now, let's assume items with factory 'D2' or 'D3' are foundry items.
      // What about Frenbu items? Usually they don't have 'D2'/'D3' factory in typical uploads if separate?
      // OR, does the user want ALL items to be checked for Frenbu scraps?
      // Based on previous code:
      // if (tiScrapQty > 0 || item.quantity > 0) -> added to frenbuTable if prod > 0.

      // Let's refine:
      if (item.quantity > 0) {
        totalFrenbuProd += item.quantity;
        if (tiScrapQty > 0) {
          final details = <ScrapDetail>[];
          for (var s in productScraps) {
            final defectCode = s['defect'] as String;
            final qty = s['qty'] as int;
            // Mocking details
            details.add(
              ScrapDetail(
                defectName: defectCode,
                quantity: qty,
                batchNo: 'SARJ-${DateTime.now().millisecond}', // Mock Batch
                description:
                    'Otomatik ölçüm sonrası tespit edilen $defectCode hatası.',
                imageUrl: 'https://via.placeholder.com/150', // Mock Image
              ),
            );
          }

          frenbuTable.add(
            ScrapTableItem(
              productType: type,
              productCode: item.productCode,
              productionQty: item.quantity,
              scrapQty: tiScrapQty,
              scrapRate: (tiScrapQty / item.quantity) * 100,
              details: details,
            ),
          );
          totalFrenbuScrap += tiScrapQty;
        } else {
          // No TI scraps -> Clean for Frenbu
          frenbuClean.add(
            ProductionEntry(
              productCode: item.productCode,
              factoryType: 'FRENBU',
              quantity: item.quantity,
            ),
          );
        }
      }

      // FOUNDRY TABLES (D Scraps)
      if (item.factory == 'D2') {
        totalD2Turned += item.quantity;
        if (dScrapQty > 0) {
          d2Table.add(
            ScrapTableItem(
              productType: type,
              productCode: item.productCode,
              productionQty: item.quantity,
              scrapQty: dScrapQty,
              scrapRate: item.quantity > 0
                  ? (dScrapQty / item.quantity) * 100
                  : 0,
            ),
          );
          totalD2Scrap += dScrapQty;
        } else {
          d2Clean.add(
            ProductionEntry(
              productCode: item.productCode,
              factoryType: 'D2',
              quantity: item.quantity,
            ),
          );
        }
      } else if (item.factory == 'D3') {
        totalD3Turned += item.quantity;
        if (dScrapQty > 0) {
          d3Table.add(
            ScrapTableItem(
              productType: type,
              productCode: item.productCode,
              productionQty: item.quantity,
              scrapQty: dScrapQty,
              scrapRate: item.quantity > 0
                  ? (dScrapQty / item.quantity) * 100
                  : 0,
            ),
          );
          totalD3Scrap += dScrapQty;
        } else {
          d3Clean.add(
            ProductionEntry(
              productCode: item.productCode,
              factoryType: 'D3',
              quantity: item.quantity,
            ),
          );
        }
      }
    }

    // Sort tables by Scrap Rate desc
    frenbuTable.sort((a, b) => b.scrapRate.compareTo(a.scrapRate));
    d2Table.sort((a, b) => b.scrapRate.compareTo(a.scrapRate));
    d3Table.sort((a, b) => b.scrapRate.compareTo(a.scrapRate));

    // Mock Shifts for Frenbu
    final mockFrenbuShifts = [
      ShiftData(
        shiftName: '00:00 - 08:00',
        scrapQty: (totalFrenbuScrap * 0.4).toInt(),
        rate: 2.1,
      ),
      ShiftData(
        shiftName: '08:00 - 16:00',
        scrapQty: (totalFrenbuScrap * 0.35).toInt(),
        rate: 1.8,
      ),
      ShiftData(
        shiftName: '16:00 - 00:00',
        scrapQty: (totalFrenbuScrap * 0.25).toInt(),
        rate: 1.2,
      ),
    ];

    return ScrapDashboardData(
      date: DateTime.now(), // Should rely on Excel date column if available
      totalFrenbuProduction: totalFrenbuProd,
      summary: FactorySummary(
        d2ScrapDto: totalD2Scrap,
        d2Turned: totalD2Turned,
        d2Rate: totalD2Turned > 0 ? (totalD2Scrap / totalD2Turned) * 100 : 0,
        d3ScrapDto: totalD3Scrap,
        d3Turned: totalD3Turned,
        d3Rate: totalD3Turned > 0 ? (totalD3Scrap / totalD3Turned) * 100 : 0,
        frenbuScrapDto: totalFrenbuScrap,
        frenbuTurned: totalFrenbuProd,
        frenbuRate: totalFrenbuProd > 0
            ? (totalFrenbuScrap / totalFrenbuProd) * 100
            : 0,
      ),
      dailyScrapRates: [
        FactoryDailyScrap(
          'D2',
          totalD2Turned > 0 ? (totalD2Scrap / totalD2Turned) * 100 : 0,
        ),
        FactoryDailyScrap(
          'D3',
          totalD3Turned > 0 ? (totalD3Scrap / totalD3Turned) * 100 : 0,
        ),
        FactoryDailyScrap(
          'FRENBU',
          totalFrenbuProd > 0 ? (totalFrenbuScrap / totalFrenbuProd) * 100 : 0,
        ),
      ],
      holeProductionStats: {
        // ADDED
        'D2': totalD2Hole,
        'D3': totalD3Hole,
        'FRENBU': totalFrenbuHole,
      },
      frenbuTable: frenbuTable,
      frenbuDefectDistribution: _generateMockDistribution(), // Mock for now
      frenbuCleanProducts: frenbuClean, // NEW
      frenbuShifts: mockFrenbuShifts, // ADDED
      d2Table: d2Table,
      d3Table: d3Table,
      d2CleanProducts: d2Clean,
      d3CleanProducts: d3Clean,
    );
  }

  String _getProductType(String code) {
    if (code.startsWith('1')) return 'Disk';
    if (code.startsWith('4')) return 'Disk';
    if (code.startsWith('5')) return 'Kampana';
    if (code.startsWith('6')) return 'Kampana';
    if (code.startsWith('8')) return 'Kampana';
    if (code.startsWith('2')) return 'Kampana';
    if (code.startsWith('3')) return 'Kampana';
    if (code.startsWith('8')) return 'Kampana';
    if (code.startsWith('634')) return 'Porya';
    return 'Kampana'; // Default fallback
  }

  List<DefectDistributionItem> _generateMockDistribution() {
    return [
      DefectDistributionItem(
        defectName: '1.Yön Bağlama Hatası',
        drumScrap: 1,
        total: 1,
        rate: 0.03,
      ),
      DefectDistributionItem(
        defectName: 'Darbeye Bağlı Kırık',
        diskScrap: 1,
        total: 1,
        rate: 0.03,
      ),
      DefectDistributionItem(
        defectName: 'Delik Kaçıklığı',
        diskScrap: 12,
        drumScrap: 4,
        total: 16,
        rate: 0.54,
      ),
      DefectDistributionItem(
        defectName: 'Elmas Kırması',
        diskScrap: 1,
        drumScrap: 2,
        total: 3,
        rate: 0.10,
      ),
      DefectDistributionItem(
        defectName: 'Eşmerkezlilik Hatası',
        diskScrap: 2,
        hubScrap: 1,
        total: 3,
        rate: 0.10,
      ),
    ];
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
