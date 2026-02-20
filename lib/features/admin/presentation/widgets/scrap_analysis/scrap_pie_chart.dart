import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Scrap Pie Chart Widget
/// Beautiful pie chart showing scrap distribution by factory
class ScrapPieChart extends StatelessWidget {
  final Map<String, int> factoryData;

  const ScrapPieChart({super.key, required this.factoryData});

  @override
  Widget build(BuildContext context) {
    final total = factoryData.values.fold(0, (sum, val) => sum + val);
    if (total == 0) {
      return const Center(
        child: Text(
          'Veri bulunamadı',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        // Pie Chart
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: _buildSections(factoryData, total),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Legend
        Wrap(
          spacing: 20,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: factoryData.entries.map((entry) {
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            final color = _getFactoryColor(entry.key);
            return _buildLegendItem('${entry.key} ($percentage%)', color);
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(Map<String, int> data, int total) {
    return data.entries.map((entry) {
      final percentage = entry.value / total * 100;
      return PieChartSectionData(
        color: _getFactoryColor(entry.key),
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(color: AppColors.textMain, fontSize: 13),
        ),
      ],
    );
  }

  Color _getFactoryColor(String factory) {
    switch (factory.toUpperCase()) {
      case 'FRENBU':
        return const Color(0xFFE74C3C);
      case 'D2':
        return const Color(0xFF3498DB);
      case 'D3':
        return const Color(0xFFF39C12);
      default:
        return AppColors.textSecondary;
    }
  }
}
