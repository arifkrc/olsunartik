import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';

// Input for the isolate
class AnalysisInput {
  final List<int> excelBytes;
  final List<FireAnalysisData> fireData;

  AnalysisInput({required this.excelBytes, required this.fireData});
}

// Compute function
Future<AnalysisResult> analyzeScrapData(AnalysisInput input) async {
  // 1. Parse Excel
  final excel = Excel.decodeBytes(input.excelBytes);
  final List<ProductionEntry> productionEntries = [];

  for (var table in excel.tables.keys) {
    // Assuming data is in the first sheet or iterating all
    final sheet = excel.tables[table];
    if (sheet == null) continue;

    // Skip header row if necessary, or check logic
    // Prompt says: Sütun A: Ürün Kodu, B: Fabrika (D2/D3), C: Üretim Adeti
    // Excel rows are 0-indexed.

    for (var row in sheet.rows) {
      if (row.isEmpty) continue;

      try {
        // Safe access to cells
        final c0 = row.elementAtOrNull(0)?.value; // Product Code
        final c1 = row.elementAtOrNull(1)?.value; // Factory
        final c2 = row.elementAtOrNull(2)?.value; // Quantity

        final productCode = c0?.toString().trim() ?? '';
        final factory = c1?.toString().trim().toUpperCase() ?? '';

        // Parse quantity safely
        int quantity = 0;
        if (c2 is IntCellValue) {
          quantity = c2.value;
        } else if (c2 is DoubleCellValue) {
          quantity = c2.value.toInt();
        } else if (c2 is TextCellValue) {
          quantity = int.tryParse(c2.value.toString()) ?? 0;
        } else {
          // Fallback or other types
          quantity = int.tryParse(c2.toString()) ?? 0;
        }

        if (quantity > 0) {
          productionEntries.add(
            ProductionEntry(
              productCode: productCode,
              factoryType: factory,
              quantity: quantity,
            ),
          );
        }
      } catch (e) {
        // Skip malformed rows
        debugPrint('Error parsing row: $e');
      }
    }
  }

  // 2. Analyze Fire Data (Frenbu Detection)
  // Frenbu Logic: HataKodu starts with "Tİ" -> Frenbu
  // User Prompt: "Frenbu Üretim: (Logic ile Frenbu olduğu tespit edilenlerin adeti/sayısı)."
  // Interpreting as: Count of defective items classified as Frenbu.

  int frenbuCount = 0;
  final Set<String> fireProductCodes = {};

  for (var fireItem in input.fireData) {
    fireProductCodes.add(fireItem.productCode);

    if (fireItem.defectCode.toUpperCase().startsWith('Tİ')) {
      frenbuCount++;
    }
  }

  // 3. Calculate D2/D3 Production from Excel
  int d2Total = 0;
  int d3Total = 0;

  for (var entry in productionEntries) {
    if (entry.factoryType == 'D2') {
      d2Total += entry.quantity;
    } else if (entry.factoryType == 'D3') {
      d3Total += entry.quantity;
    }
  }

  // 4. Identify Non-Scrap Products (Firesiz Ürünler)
  // Logic: In Excel (Prod > 0) AND NOT in Fire List
  final List<ProductionEntry> nonScrapItems = [];

  for (var entry in productionEntries) {
    // Check if this product code exists in fire list
    if (!fireProductCodes.contains(entry.productCode)) {
      nonScrapItems.add(entry);
    }
  }

  return AnalysisResult(
    d2Production: d2Total,
    d3Production: d3Total,
    frenbuCount: frenbuCount,
    nonScrapItems: nonScrapItems,
  );
}
