import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';

/// Date Range Picker Section
/// Modern date range selector for analysis period
class AnalysisDateRangeSection extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateTime) onStartDateSelect;
  final Function(DateTime) onEndDateSelect;

  const AnalysisDateRangeSection({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateSelect,
    required this.onEndDateSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.calendar, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          const Text(
            'Analiz Dönemi',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildDatePicker(
              label: 'Başlangıç',
              date: startDate,
              onSelect: onStartDateSelect,
              context: context,
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            LucideIcons.arrowRight,
            color: AppColors.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDatePicker(
              label: 'Bitiş',
              date: endDate,
              onSelect: onEndDateSelect,
              context: context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required Function(DateTime) onSelect,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  surface: AppColors.surface,
                ),
                dialogTheme: const DialogThemeData(
                  backgroundColor: AppColors.surface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onSelect(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
