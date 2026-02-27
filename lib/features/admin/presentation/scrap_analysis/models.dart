class ProductionEntry {
  final String productCode;
  final String factoryType; // 'D2' or 'D3'
  final int quantity;

  ProductionEntry({
    required this.productCode,
    required this.factoryType,
    required this.quantity,
  });

  @override
  String toString() =>
      'ProductionEntry(code: $productCode, factory: $factoryType, qty: $quantity)';
}

class AnalysisResult {
  final int d2Production;
  final int d3Production;
  final int frenbuCount;
  final List<ProductionEntry> nonScrapItems;

  AnalysisResult({
    this.d2Production = 0,
    this.d3Production = 0,
    this.frenbuCount = 0,
    this.nonScrapItems = const [],
  });

  // Empty initial state
  factory AnalysisResult.empty() {
    return AnalysisResult();
  }
}

// Simplified definition of Fire Data for Isolate transfer
class FireAnalysisData {
  final String productCode;
  final String defectCode;
  final String batchNo;

  FireAnalysisData({
    required this.productCode,
    required this.defectCode, // 'hataKodu'
    required this.batchNo, // 'sarjNo'
  });
}

// -- UPLOAD MODELS --
class ScrapUploadItem {
  final DateTime? date;
  final String productCode;
  final String factory; // D2, D3
  final int quantity;
  final int holeQty;

  ScrapUploadItem({
    this.date,
    required this.productCode,
    required this.factory,
    required this.quantity,
    this.holeQty = 0,
  });
}

class ScrapUploadBatch {
  final List<ScrapUploadItem> items;
  final DateTime date;

  ScrapUploadBatch({required this.items, required this.date});
}

// -- DASHBOARD MODELS --

class ShiftData {
  final String shiftName;
  final int scrapQty;
  final num rate;

  ShiftData({
    required this.shiftName,
    required this.scrapQty,
    required this.rate,
  });
}

class ScrapDashboardData {
  final DateTime date;
  final int totalFrenbuProduction;
  final FactorySummary summary;
  final List<FactoryDailyScrap> dailyScrapRates; // For Pie Chart
  final Map<String, int> holeProductionStats; // ADDED
  final List<ScrapTableItem> frenbuTable;
  final List<DefectDistributionItem> frenbuDefectDistribution;
  final List<ProductionEntry> frenbuCleanProducts; // NEW
  final List<ShiftData> frenbuShifts; // ADDED
  final List<ScrapTableItem> d2Table;
  final List<ScrapTableItem> d3Table;
  final List<ProductionEntry> d2CleanProducts;
  final List<ProductionEntry> d3CleanProducts;

  ScrapDashboardData({
    required this.date,
    required this.totalFrenbuProduction,
    required this.summary,
    required this.dailyScrapRates,
    required this.holeProductionStats, // ADDED
    required this.frenbuTable,
    required this.frenbuDefectDistribution,
    required this.frenbuCleanProducts, // NEW
    required this.frenbuShifts, // ADDED
    required this.d2Table,
    required this.d3Table,
    required this.d2CleanProducts,
    required this.d3CleanProducts,
  });
}

class FactorySummary {
  final int d2ScrapDto;
  final num d2Rate;
  final int d2Turned;

  final int d3ScrapDto;
  final num d3Rate;
  final int d3Turned;

  final int frenbuScrapDto;
  final num frenbuRate;
  final int frenbuTurned;

  FactorySummary({
    this.d2ScrapDto = 0,
    this.d2Rate = 0.0,
    this.d2Turned = 0,
    this.d3ScrapDto = 0,
    this.d3Rate = 0.0,
    this.d3Turned = 0,
    this.frenbuScrapDto = 0,
    this.frenbuRate = 0.0,
    this.frenbuTurned = 0,
  });
}

class FactoryDailyScrap {
  final String factory; // D2, D3, FRENBU
  final num rate;
  FactoryDailyScrap(this.factory, this.rate);
}

class ScrapDetail {
  final String defectName;
  final int quantity;
  final String? imageUrl;
  final String? description;
  final String batchNo;

  ScrapDetail({
    required this.defectName,
    required this.quantity,
    this.imageUrl,
    this.description,
    required this.batchNo,
  });
}

class ScrapTableItem {
  final String productType; // Disk, Kampana, Porya
  final String productCode;
  final int productionQty;
  final int scrapQty;
  final num scrapRate;
  final List<ScrapDetail> details; // Added details list

  ScrapTableItem({
    required this.productType,
    required this.productCode,
    required this.productionQty,
    required this.scrapQty,
    required this.scrapRate,
    this.details = const [], // Default empty
  });
}

class DefectDistributionItem {
  final String defectName;
  final int diskScrap;
  final int drumScrap; // Kampana
  final int hubScrap; // Porya
  final int total;
  final num rate;

  DefectDistributionItem({
    required this.defectName,
    this.diskScrap = 0,
    this.drumScrap = 0,
    this.hubScrap = 0,
    required this.total,
    required this.rate,
  });
}
