import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/analytics_providers.dart';
import '../widgets/dashboard/quality_approval_card.dart';
import '../widgets/dashboard/final_control_card.dart';
import '../widgets/dashboard/rework_analysis_card.dart';
import '../widgets/dashboard/scrap_analysis_card.dart';
import '../widgets/dashboard/incoming_quality_card.dart';
import '../widgets/dashboard/personnel_performance_table.dart';
import '../widgets/dashboard/sample_test_card.dart';

class ReportSummaryTab extends ConsumerStatefulWidget {
  const ReportSummaryTab({super.key});

  @override
  ConsumerState<ReportSummaryTab> createState() => _ReportSummaryTabState();
}

class _ReportSummaryTabState extends ConsumerState<ReportSummaryTab> {
  // Normalize a DateTime to local midnight to guarantee equality across picker results
  static DateTime _midnight(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  late DateTime _selectedDate;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _selectedDate = _midnight(DateTime.now().subtract(const Duration(days: 1)));
  }

  DateTime get _effectiveStart =>
      _customRange != null ? _midnight(_customRange!.start) : _selectedDate;
  DateTime get _effectiveEnd =>
      _customRange != null ? _midnight(_customRange!.end) : _selectedDate;

  AnalyticsQuery get _currentQuery => AnalyticsQuery(
        startDate: _effectiveStart,
        endDate: _effectiveEnd,
      );

  void _refresh() {
    ref.invalidate(analyticsRangeProvider(_currentQuery));
  }

  @override
  Widget build(BuildContext context) {
    final query = _currentQuery;
    final analyticsAsync = ref.watch(analyticsRangeProvider(query));

    // isLoading is true during refetch — show spinner badge on top of existing data
    final isLoading = analyticsAsync.isLoading;
    final data = analyticsAsync.value; // null if loading/error
    final hasError = analyticsAsync.hasError;
    final error = hasError ? analyticsAsync.error : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilterRow(isLoading: isLoading),
          const SizedBox(height: 24),

          // Error banner (non-blocking — shows on top of stale data)
          if (error != null && data == null)
            _buildErrorBanner(error.toString(), query),

          // First-time loading spinner (no data yet)
          if (isLoading && data == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: CircularProgressIndicator(),
              ),
            ),

          // Dashboard content — shown even while refreshing (isLoading == true)
          if (data != null) ...[
            // Son güncelleme zamanı + loading badge
            Row(
              children: [
                Text(
                  'Son hesaplama: ${DateFormat('dd.MM.yyyy HH:mm').format(data.lastCalculatedAt.toLocal())}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Yükleniyor...',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Row 1: Kalite Onay & Final Kontrol
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildSectionHeader('1. Kalite Onay', LucideIcons.checkCircle),
                      QualityApprovalCard(data: data.kaliteOnay),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildSectionHeader('2. Final Kontrol', LucideIcons.packageCheck),
                      FinalControlCard(data: data.finalKontrol),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Row 2: Giriş Kalite & Fire
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildSectionHeader('3. Giriş Kalite', LucideIcons.clipboardCheck),
                      IncomingQualityCard(data: data.girisKalite),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildSectionHeader('4. Fire Analizi', LucideIcons.flame),
                      ScrapAnalysisCard(data: data.fire),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Row 3: Rework & Numune
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildSectionHeader('5. Rework Analizi', LucideIcons.refreshCw),
                      ReworkAnalysisCard(
                        data: data.reworkAnaliz,
                        reworkForm: data.reworkFormu,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildSectionHeader('6. Numune/Deneme', LucideIcons.beaker),
                      SampleTestFormCard(records: data.numuneRecords),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('7. Personel Performansı', LucideIcons.users),
            const PersonnelPerformanceTable(),
            const SizedBox(height: 40),
          ],

          // Error state — also shown when there's already data (retry possible)
          if (error != null && data != null)
            _buildErrorBanner(error.toString(), query),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String errorMsg, AnalyticsQuery query) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Veriler yüklenemedi: $errorMsg',
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _refresh,
            icon: const Icon(LucideIcons.refreshCw, size: 14),
            label: const Text('Tekrar', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow({required bool isLoading}) {
    final fmt = DateFormat('dd.MM.yyyy');
    final dateLabel = _customRange != null
        ? '${fmt.format(_customRange!.start)} - ${fmt.format(_customRange!.end)}'
        : fmt.format(_selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.filter, color: AppColors.primary),
          const SizedBox(width: 16),

          // Önceki gün
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textMain),
            onPressed: isLoading
                ? null
                : () {
                    setState(() {
                      _customRange = null;
                      _selectedDate = _midnight(
                          _selectedDate.subtract(const Duration(days: 1)));
                    });
                  },
          ),

          // Tarih / Aralık butonu
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2025),
                        lastDate: DateTime.now(),
                        initialDateRange: DateTimeRange(
                          start: _effectiveStart,
                          end: _effectiveEnd,
                        ),
                        barrierColor: Colors.black.withValues(alpha: 0.5),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.primary,
                                surface: AppColors.surface,
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        final start = _midnight(picked.start);
                        final end = _midnight(picked.end);
                        setState(() {
                          // "start == end" → tek günlük seçim
                          if (start.isAtSameMomentAs(end)) {
                            _customRange = null;
                            _selectedDate = start;
                          } else {
                            _customRange = DateTimeRange(start: start, end: end);
                          }
                        });
                      }
                    },
              icon: const Icon(LucideIcons.calendar),
              label: Text(
                dateLabel,
                style: const TextStyle(color: AppColors.textMain),
              ),
            ),
          ),

          // Sonraki gün (bugünden ileri gitme)
          IconButton(
            icon: const Icon(LucideIcons.chevronRight, color: AppColors.textMain),
            onPressed:
                isLoading || !_selectedDate.isBefore(_midnight(DateTime.now()))
                    ? null
                    : () {
                        setState(() {
                          _customRange = null;
                          _selectedDate = _midnight(
                              _selectedDate.add(const Duration(days: 1)));
                        });
                      },
          ),

          const SizedBox(width: 4),

          // Manuel yenile
          IconButton(
            tooltip: 'Yenile',
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.refreshCw, size: 16),
            color: AppColors.primary,
            onPressed: isLoading ? null : _refresh,
          ),

          // Dünü sıfırla
          TextButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    final yesterday = _midnight(
                        DateTime.now().subtract(const Duration(days: 1)));
                    setState(() {
                      _customRange = null;
                      _selectedDate = yesterday;
                    });
                  },
            icon: const Icon(LucideIcons.rotateCcw, size: 14),
            label: const Text('Dün'),
          ),
        ],
      ),
    );
  }
}
