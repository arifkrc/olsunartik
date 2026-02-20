import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/analytics_range_dto.dart';

class SampleTestFormCard extends StatelessWidget {
  final List<NumuneRecordDto> records;
  const SampleTestFormCard({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: const Center(
          child: Text(
            'Bu tarihte numune kaydı yok',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildHeaderCell('Ürün Kodu')),
                Expanded(child: _buildHeaderCell('Tarih')),
                Expanded(child: _buildHeaderCell('Sonuç')),
                Expanded(flex: 2, child: _buildHeaderCell('Personel')),
              ],
            ),
          ),
          ...records.map((record) {
            final isSuccess = record.sonuc == 'Geçti';
            final dateStr = DateFormat('dd.MM.yyyy').format(record.testTarihi);
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      record.urunKodu,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: const TextStyle(color: AppColors.textMain),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      record.sonuc,
                      style: TextStyle(
                        color: isSuccess ? AppColors.duzceGreen : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      record.personelAdi,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }
}
