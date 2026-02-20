import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../logic/cubits/scrap_analysis_cubit.dart';

class ScrapFactoryTable extends StatelessWidget {
  final List<ScrapData> data;
  final String factory;

  const ScrapFactoryTable({
    super.key,
    required this.data,
    required this.factory,
  });

  @override
  Widget build(BuildContext context) {
    final items = data.where((e) => e.factory == factory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table Header Section (Factory Name)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: const BoxDecoration(
            color: AppColors.primary, // Corporate Red
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              '$factory DIŞ FİRE',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),

        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black, // Darker background
              border: Border.all(
                color: AppColors.glassBorder,
                width: 2,
              ), // Thicker border
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Text(
                'Bu fabrika için veri bulunamadı.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.black, // Opaque Black Background
              border: Border.all(
                color: AppColors.glassBorder,
                width: 2,
              ), // Thicker Border
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2), // Ürün Türü
                  1: FlexColumnWidth(1.2), // Ürün Kodu
                  2: FlexColumnWidth(1.0), // Üretim Adeti
                  3: FlexColumnWidth(1.0), // Fire ADET
                  4: FlexColumnWidth(1.0), // Fire Oranı
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: AppColors.glassBorder, // Clearer borders
                    width: 1.5,
                  ),
                  verticalInside: BorderSide(
                    color: AppColors.glassBorder,
                    width: 1.5,
                  ),
                ),
                children: [
                  // Column Headers
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E1E1E), // Slightly lighter than black
                    ),
                    children: const [
                      _TableHeaderCell('Ürün Türü'),
                      _TableHeaderCell('Ürün Kodu'),
                      _TableHeaderCell('Üretim Adeti'),
                      _TableHeaderCell('Fire ADET'),
                      _TableHeaderCell('Fire Oranı'),
                    ],
                  ),
                  // Data Rows
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    // Alternating Dark Colors
                    // Even darker for "Dimmed" look (0.6 opacity black)
                    final bool isEven = index % 2 == 0;
                    final color = isEven
                        ? const Color(
                            0xFF121212,
                          ) // Slightly lighter than pure black for stripe
                        : Colors.black;

                    return TableRow(
                      decoration: BoxDecoration(color: color),
                      children: [
                        _TableCell(
                          item.productType,
                          onTap: null, // No action
                        ),
                        // Product Code - Clickable for Mini Detail
                        _TableCell(
                          item.productCode,
                          isBold: true,
                          isClickable: true,
                          onTap: () => _showProductDetailModal(context, item),
                        ),
                        _TableCell('${item.productionQty}'),
                        _TableCell('${item.scrapQty}'),
                        _TableCell('%${item.rate.toStringAsFixed(1)}'),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showProductDetailModal(BuildContext context, ScrapData item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark background matching theme
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.factory} - ${item.productType}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.glassBorder),
              const SizedBox(height: 16),

              // Image Placeholder (as per standard)
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        size: 40,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ürün Görseli',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Grid
              Row(
                children: [
                  _buildDetailStat(
                    'Üretim',
                    '${item.productionQty}',
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildDetailStat(
                    'Fire',
                    '${item.scrapQty}',
                    AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildDetailStat(
                    'Oran',
                    '%${item.rate.toStringAsFixed(1)}',
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color textStyleColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05), // Light white background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
          ), // White border
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: textStyleColor, // Keep original text color
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: textStyleColor.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScrapDefectDistributionTable extends StatelessWidget {
  final List<ScrapData> data;
  final String factory;

  const ScrapDefectDistributionTable({
    super.key,
    required this.data,
    required this.factory,
  });

  @override
  Widget build(BuildContext context) {
    // Filter items with scrap > 0
    final items = data
        .where(
          (e) =>
              e.factory == factory &&
              e.scrapQty > 0 &&
              e.defectReason.isNotEmpty,
        )
        .toList();

    // Aggregate Data
    final Map<String, Map<String, int>> aggregated = {};
    // defect -> { 'Disk': 5, 'Kampana': 2 ... }

    for (var item in items) {
      if (!aggregated.containsKey(item.defectReason)) {
        aggregated[item.defectReason] = {
          'Disk': 0,
          'Kampana': 0,
          'Porya': 0,
          'Volan': 0,
        };
      }
      final currentMap = aggregated[item.defectReason]!;
      currentMap[item.productType] =
          (currentMap[item.productType] ?? 0) + item.scrapQty;
    }

    final defects = aggregated.keys.toList()..sort();
    final totalProduction = data
        .where((e) => e.factory == factory)
        .fold(0, (sum, item) => sum + item.productionQty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: const BoxDecoration(
            color: AppColors.primary, // Corporate Red
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$factory FİRE DAĞILIMI',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'TOPLAM ÜRETİM: $totalProduction',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: AppColors.glassBorder, width: 2),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.0), // Hata Tanımı (Geniş)
                1: FlexColumnWidth(1.0), // Disk
                2: FlexColumnWidth(1.0), // Kampana
                3: FlexColumnWidth(1.0), // Porya
                4: FlexColumnWidth(1.0), // Toplam
                5: FlexColumnWidth(1.0), // Oran
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: AppColors.glassBorder,
                  width: 1.5,
                ),
                verticalInside: BorderSide(
                  color: AppColors.glassBorder,
                  width: 1.5,
                ),
              ),
              children: [
                // Headers
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFF1E1E1E)),
                  children: const [
                    _TableHeaderCell('Hata Tanımı'),
                    _TableHeaderCell('Disk Fire'),
                    _TableHeaderCell('Kampana Fire'),
                    _TableHeaderCell('Porya Fire'),
                    _TableHeaderCell('Toplam'),
                    _TableHeaderCell('Fire Oranı'),
                  ],
                ),
                // Rows
                ...defects.asMap().entries.map((entry) {
                  final index = entry.key;
                  final defect = entry.value;
                  final counts = aggregated[defect]!;
                  final disk = counts['Disk'] ?? 0;
                  final kampana = counts['Kampana'] ?? 0;
                  final porya = counts['Porya'] ?? 0;
                  final totalScrap = disk + kampana + porya; // Row total

                  // Calculate rate based on Total Production
                  final rate = totalProduction > 0
                      ? (totalScrap / totalProduction) * 100
                      : 0.0;

                  // Alternating Colors
                  final bool isEven = index % 2 == 0;
                  final color = isEven ? const Color(0xFF121212) : Colors.black;

                  return TableRow(
                    decoration: BoxDecoration(color: color),
                    children: [
                      _TableCell(defect, isBold: true),
                      _TableCell('$disk'),
                      _TableCell('$kampana'),
                      _TableCell('$porya'),
                      _TableCell('$totalScrap'),
                      _TableCell('%${rate.toStringAsFixed(2)}'),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NonScrapProductionTable extends StatelessWidget {
  final List<ScrapData> data;
  final String factory;

  const NonScrapProductionTable({
    super.key,
    required this.data,
    required this.factory,
  });

  @override
  Widget build(BuildContext context) {
    // Only items with 0 scrap
    final items = data
        .where((e) => e.factory == factory && e.scrapQty == 0)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF00B4D8), // Light Blue per screenshot request
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              '$factory FİRESİZ ÜRÜN ADETİ',
              style: const TextStyle(
                color: Colors.white, // Or Black? Keeping White for consistency.
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: AppColors.glassBorder, width: 2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Text(
                'Firesiz üretim kaydı bulunamadı.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.black, // Opaque Black
              border: Border.all(
                color: AppColors.glassBorder,
                width: 2,
              ), // Thicker
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.0),
                  1: FlexColumnWidth(1.0),
                  2: FlexColumnWidth(1.0),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: AppColors.glassBorder,
                    width: 1.5,
                  ),
                  verticalInside: BorderSide(
                    color: AppColors.glassBorder,
                    width: 1.5,
                  ),
                ),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFF1E1E1E)),
                    children: const [
                      _TableHeaderCell('Ürün Türü'),
                      _TableHeaderCell('Ürün Kodu'),
                      _TableHeaderCell('Üretim Adeti'),
                    ],
                  ),
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final bool isEven = index % 2 == 0;
                    final color = isEven
                        ? const Color(0xFF121212)
                        : Colors.black;

                    return TableRow(
                      decoration: BoxDecoration(color: color),
                      children: [
                        _TableCell(item.productType),
                        _TableCell(item.productCode, isBold: true),
                        _TableCell('${item.productionQty}'),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isBold;
  final bool isClickable;
  final VoidCallback? onTap;

  const _TableCell(
    this.text, {
    this.isBold = false,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          // Always white (AppColors.textMain) even if clickable, UNLESS you want it to look different
          // User requested "white again".
          color: AppColors.textMain,
          // Keep font weight
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          // Keep underline to indicate clickability?
          // User said "onları beyaza geri çevir" (turn them back to white).
          // I will keep underline but make it white, or simple remove underline if it looks cleaner.
          // Let's keep it clean: White text.
          decoration: isClickable ? TextDecoration.underline : null,
          decorationColor: Colors.white, // White underline
          fontSize: 14,
        ),
      ),
    );

    if (isClickable && onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }

    return content;
  }
}
