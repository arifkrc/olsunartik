import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/analytics_range_dto.dart';

class ReworkAnalysisCard extends StatelessWidget {
  final ReworkAnalizAnalyticsDto data;
  final ReworkFormAnalyticsDto reworkForm;
  const ReworkAnalysisCard({super.key, required this.data, required this.reworkForm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toplam
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.reworkOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.reworkOrange.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                'Toplam Rework: ${reworkForm.toplamAdet} adet',
                style: const TextStyle(
                  color: AppColors.reworkOrange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Tür bazında
          if (data.tureGoreToplam.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'İşlem Türüne Göre',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ...data.tureGoreToplam.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(color: AppColors.textMain)),
                    Text(
                      '${e.value} adet',
                      style: const TextStyle(
                        color: AppColors.reworkOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Hata nedeni
          if (data.hataNedenleriVeAdetler.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Hata Nedenlerine Göre',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ...data.hataNedenleriVeAdetler.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        style: const TextStyle(color: AppColors.textMain),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${e.value} adet',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (reworkForm.toplamAdet == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Bu tarihte rework kaydı yok',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
