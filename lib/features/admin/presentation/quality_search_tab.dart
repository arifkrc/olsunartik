import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/forms/searchable_product_field.dart';
import 'providers/quality_search_providers.dart';

/// Kalite Onay Arama Tab
/// Ürün koduna ve tarihe göre kalite onay kayıtlarını arar
class QualityApprovalSearchTab extends ConsumerStatefulWidget {
  const QualityApprovalSearchTab({super.key});

  @override
  ConsumerState<QualityApprovalSearchTab> createState() =>
      _QualityApprovalSearchTabState();
}

class _QualityApprovalSearchTabState
    extends ConsumerState<QualityApprovalSearchTab> {
  final TextEditingController _productCodeController = TextEditingController();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void dispose() {
    _productCodeController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final productCode = _productCodeController.text.trim();

    ref
        .read(qualityApprovalSearchStateProvider.notifier)
        .searchQualityRecords(
          productCode: productCode,
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  void _clearSearch() {
    setState(() {
      _productCodeController.clear();
      _startDate = DateTime.now().subtract(const Duration(days: 7));
      _endDate = DateTime.now();
    });
    ref.read(qualityApprovalSearchStateProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(qualityApprovalSearchStateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Form Card
          _buildSearchForm(),
          const SizedBox(height: 24),

          // Results
          searchState.when(
            data: (results) {
              if (results.isEmpty) {
                return _buildEmptyState();
              }
              return Column(
                children: [
                  // Statistics Cards
                  _buildStatisticsCards(results),
                  const SizedBox(height: 24),

                  // Results Table
                  _buildResultsTable(results),
                ],
              );
            },
            loading: () => _buildLoadingState(),
            error: (error, _) => _buildErrorState(error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.search,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Arama Kriterleri',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Product Search Field
          SearchableProductField(
            controller: _productCodeController,
            onProductSelected: (product) {
              // Product selected, code is already in controller
            },
          ),
          const SizedBox(height: 20),

          // Date Range
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  'Başlangıç Tarihi',
                  _startDate,
                  (date) => setState(() => _startDate = date),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDatePicker(
                  'Bitiş Tarihi',
                  _endDate,
                  (date) => setState(() => _endDate = date),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(LucideIcons.search, size: 18),
                  label: const Text('ARA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearSearch,
                  icon: const Icon(LucideIcons.x, size: 18),
                  label: const Text('TEMİZLE'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    Function(DateTime) onSelect,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppColors.primary,
                  surface: AppColors.surface,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onSelect(picked);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd.MM.yyyy').format(date),
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(List results) {
    // Toplam Kayıt
    final totalRecords = results.length;
    // Toplam Onay
    final totalApproved = results
        .where((r) => r.approvalStatus == 'Onay')
        .length;
    // Toplam Ret (veya Şartlı)
    final totalRejected = results
        .where((r) => r.approvalStatus == 'Ret')
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Toplam Onay',
            totalApproved.toString(),
            LucideIcons.checkCircle,
            AppColors.duzceGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Toplam Ret',
            totalRejected.toString(),
            LucideIcons.alertCircle,
            AppColors.error,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Toplam Kayıt',
            totalRecords.toString(),
            LucideIcons.files,
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTable(List results) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.table,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Kalite Onay Kayıtları',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${results.length} kayıt',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Table Content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: WidgetStateProperty.all(AppColors.background),
              dataRowColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.hovered)
                    ? AppColors.surfaceLight
                    : AppColors.surface,
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'Ürün Kodu',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Ürün Adı',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                DataColumn(
                  label: Text(
                    'Operatör',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Durum',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Vardiya',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tarih',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              rows: results.map((result) {
                // Status Color Logic
                Color statusColor = AppColors.textMain;
                if (result.approvalStatus == 'Onay') {
                  statusColor = AppColors.duzceGreen;
                } else if (result.approvalStatus == 'Ret') {
                  statusColor = AppColors.error;
                } else if (result.approvalStatus == 'Şartlı Kabul') {
                  statusColor = AppColors.reworkOrange;
                }

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        result.productCode,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        result.productName,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),

                    DataCell(
                      Text(
                        result.operator,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          result.approvalStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        result.shift,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    DataCell(
                      Text(
                        DateFormat('dd.MM.yyyy').format(result.date),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.searchX,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Arama yapmak için ürün kodu girin ve tarih seçin',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Aranıyor...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Hata Oluştu',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
