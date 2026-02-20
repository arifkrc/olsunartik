import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../logic/cubits/scrap_analysis_cubit.dart'; // Import ScrapData via Cubit

class ScrapPieChart extends StatelessWidget {
  final List<ScrapData> data;

  const ScrapPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Fabrika bazlı oran hesapla
    Map<String, double> factoryRates = {};
    for (var f in ['D2', 'D3', 'FRENBU']) {
      final items = data.where((e) => e.factory == f).toList();
      int p = items.fold(0, (sum, e) => sum + e.productionQty);
      int s = items.fold(0, (sum, e) => sum + e.scrapQty);
      factoryRates[f] = p > 0 ? (s / p) * 100 : 0;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          const Text(
            'Fabrikaların Günlük Fire Oranları',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.blue,
                          value: factoryRates['D2'] ?? 0,
                          title:
                              'D2\n%${(factoryRates['D2'] ?? 0).toStringAsFixed(2)}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: AppColors.reworkOrange,
                          value: factoryRates['D3'] ?? 0,
                          title:
                              'D3\n%${(factoryRates['D3'] ?? 0).toStringAsFixed(2)}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.grey,
                          value: factoryRates['FRENBU'] ?? 0,
                          title:
                              'FRENBU\n%${(factoryRates['FRENBU'] ?? 0).toStringAsFixed(2)}',
                          radius: 80,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Legend
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('D2 Fabrika', Colors.blue),
                    const SizedBox(height: 8),
                    _buildLegendItem('D3 Fabrika', AppColors.reworkOrange),
                    const SizedBox(height: 8),
                    _buildLegendItem('FRENBU', Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
