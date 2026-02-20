import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/analytics_range_dto.dart';

class IncomingQualityCard extends StatelessWidget {
  final GirisKaliteAnalyticsDto data;
  const IncomingQualityCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final onayOrani = data.toplamKontrol > 0
        ? (data.toplamOnay / data.toplamKontrol * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStat('Toplam Kontrol', '${data.toplamKontrol}', AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStat('Onay', '${data.toplamOnay}', AppColors.duzceGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStat('Ret', '${data.toplamRet}', AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.duzceGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Onay Oranı: %$onayOrani',
                style: const TextStyle(
                  color: AppColors.duzceGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
