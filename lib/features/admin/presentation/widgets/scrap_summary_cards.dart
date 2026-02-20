import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../logic/cubits/scrap_analysis_cubit.dart'; // Import ScrapData via Cubit

class ScrapSummaryCards extends StatelessWidget {
  final List<ScrapData> data;

  const ScrapSummaryCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    int totalProd = data.fold(0, (sum, item) => sum + item.productionQty);
    int totalScrap = data.fold(0, (sum, item) => sum + item.scrapQty);
    double avgRate = totalProd > 0 ? (totalScrap / totalProd) * 100 : 0;

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Toplam Üretim',
            '$totalProd',
            LucideIcons.package,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            'Toplam Fire',
            '$totalScrap',
            LucideIcons.trash2,
            AppColors.error,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            'Genel Fire Oranı',
            '%${avgRate.toStringAsFixed(2)}',
            LucideIcons.percent,
            AppColors.reworkOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
