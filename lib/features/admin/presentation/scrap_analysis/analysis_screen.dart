import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/fire_analiz_providers.dart';
import 'analysis_provider.dart';
import 'models.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  DateTime? _selectedFilterDate;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(scrapAnalysisProvider);
      if (state.dashboardData == null) {
        ref.read(scrapAnalysisProvider.notifier).fetchDashboardData(DateTime.now());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scrapAnalysisProvider);
    final data = state.dashboardData;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    children: [
                      _buildHeader(data),
                      const SizedBox(height: 24),
                      const TabBar(
                        isScrollable: true,
                        indicatorColor: AppColors.primary,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        tabs: [
                          Tab(text: 'Genel Bakış'),
                          Tab(text: 'Frenbu Detay'),
                          Tab(text: 'D2 Detay'),
                          Tab(text: 'D3 Detay'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : data == null
              ? _buildEmptyState()
              : TabBarView(
                  children: [
                    _buildOverviewTab(data),
                    _buildDetailTab(
                      'Frenbu',
                      data.frenbuTable,
                      data.frenbuCleanProducts,
                      AppColors.primary,
                      shifts: data.frenbuShifts,
                    ),
                    _buildDetailTab(
                      'D2 Fabrika',
                      data.d2Table,
                      data.d2CleanProducts,
                      Colors.blue,
                    ),
                    _buildDetailTab(
                      'D3 Fabrika',
                      data.d3Table,
                      data.d3CleanProducts,
                      AppColors.reworkOrange,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(ScrapDashboardData? data) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.pieChart,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fire Analiz Paneli',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            if (data != null)
              Text(
                'Son Güncelleme: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const Spacer(),
        // Date Range Picker
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  LucideIcons.calendarDays,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _selectedFilterDate != null
                    ? DateFormat('dd.MM.yyyy').format(_selectedFilterDate!)
                    : 'Tarih Seçiniz',
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedFilterDate ?? DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: AppColors.surface,
                            onSurface: AppColors.textMain,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedFilterDate = picked;
                    });
                    ref.read(scrapAnalysisProvider.notifier).fetchDashboardData(picked);
                  }
                },
                icon: const Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Recalculate Button
        ElevatedButton.icon(
          onPressed: () async {
             final dateStr = DateFormat('yyyy-MM-dd').format(_selectedFilterDate ?? DateTime.now());
             try {
                // Trigger backend manual recalculation
                await ref.read(fireAnalizRepositoryProvider).hesapla(dateStr);
                // Fetch the new updated data
                await ref.read(scrapAnalysisProvider.notifier).fetchDashboardData(_selectedFilterDate ?? DateTime.now());
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analiz başarıyla yeniden hesaplandı ve güncellendi.')),
                );
             } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Analiz hesaplanırken hata oluştu: $e')),
                );
             }
          },
          icon: const Icon(LucideIcons.refreshCcw, size: 18, color: Colors.white),
          label: const Text(
            'Yeniden Hesapla',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileSpreadsheet,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Analiz sonucunu görüntülemek için \'Üretim Verisi Girişi\' sekmesinden veri yükleyiniz.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Date Picker in Empty State
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedFilterDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          surface: AppColors.surface,
                          onSurface: AppColors.textMain,
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
                  setState(() {
                    _selectedFilterDate = picked;
                  });
                  ref.read(scrapAnalysisProvider.notifier).fetchDashboardData(picked);
                }
              },
              icon: const Icon(
                LucideIcons.calendar,
                color: AppColors.textSecondary,
                size: 18,
              ),
              label: Text(
                _selectedFilterDate != null
                    ? 'Seçili Tarih: ${DateFormat('dd.MM.yyyy').format(_selectedFilterDate!)}'
                    : 'Veri Tarihi Seçiniz',
                style: const TextStyle(color: AppColors.textMain),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ScrapDashboardData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 1. KPI Cards (Row of 3)
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  'FRENBU',
                  data.summary.frenbuRate,
                  data.summary.frenbuScrapDto,
                  data.summary.frenbuTurned,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  'D2 FABRİKA',
                  data.summary.d2Rate,
                  data.summary.d2ScrapDto,
                  data.summary.d2Turned,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  'D3 FABRİKA',
                  data.summary.d3Rate,
                  data.summary.d3ScrapDto,
                  data.summary.d3Turned,
                  AppColors.reworkOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Charts Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donut Chart
              Expanded(flex: 4, child: _buildChartSection(data)),
              const SizedBox(width: 24),
              // Distribution Table (Frenbu Top Defects) in Overview?
              // Or maybe just general stats?
              // The user asked for "sağında ise özet istatistikler".
              Expanded(
                flex: 3,
                child: _buildDistributionTable(data.frenbuDefectDistribution),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    String title,
    double rate,
    int scrapQty,
    int totalQty,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Row 1: Title and Rate (Top)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (rate > 0)
                Text(
                  '${rate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // Row 2: Quantities (aligned)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fire Adeti (Left)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$scrapQty',
                    style: const TextStyle(
                      fontSize: 32, // Bigger
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain, // White
                    ),
                  ),
                  const Text(
                    'Fire Adeti',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Üretim Adeti (Right)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalQty',
                    style: const TextStyle(
                      fontSize: 20, // Slightly smaller than Fire
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain, // White
                    ),
                  ),
                  const Text(
                    'Üretim Adeti',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(ScrapDashboardData data) {
    // Chart 1: Daily Scrap Rates (Existing)
    final scrapRateSections = data.dailyScrapRates.map((item) {
      final color = item.factory == 'D2'
          ? Colors.blue
          : (item.factory == 'D3' ? AppColors.reworkOrange : AppColors.primary);
      return PieChartSectionData(
        color: color,
        value: item.rate,
        title: '${item.rate.toStringAsFixed(1)}%',
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    // Chart 2: Hole Production Quantities (New)
    // Calculate total hole production for percentage
    final totalHoles =
        (data.holeProductionStats['D2'] ?? 0) +
        (data.holeProductionStats['D3'] ?? 0) +
        (data.holeProductionStats['FRENBU'] ?? 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Scrap Rates Chart
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Fire Oranları',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140, // Reduced from 220
                      child: PieChart(
                        PieChartData(
                          sections: scrapRateSections,
                          centerSpaceRadius: 25,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 2. Hole Production Text (Replaced Chart)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Üretim Adeti',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Slightly larger title
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      totalHoles > 0 ? '$totalHoles' : '-',
                      style: const TextStyle(
                        fontSize: 36, // Large, prominent number
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    if (totalHoles > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Adet',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Legend (Shared) - Only for Scrap Rates now effectively, but keeps consistent look
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('FRENBU', AppColors.primary),
              _buildLegendItem('D2', Colors.blue),
              _buildLegendItem('D3', AppColors.reworkOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDistributionTable(List<DefectDistributionItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            width: double.infinity,
            child: const Text(
              'FRENBU FİRE DAĞILIMI',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1.5),
            columnWidths: const {
              0: FlexColumnWidth(3.0), // Hata Tanımı - wider
              1: FlexColumnWidth(1.0), // Disk - narrow
              2: FlexColumnWidth(1.2), // Kampana - narrow
              3: FlexColumnWidth(1.0), // Porya - narrow
              4: FlexColumnWidth(1.0), // Toplam
              5: FlexColumnWidth(1.0), // Oran - narrow
            },
            children: [
              const TableRow(
                decoration: BoxDecoration(color: AppColors.surfaceLight),
                children: [
                  _HeaderCell('Hata Tanımı', align: TextAlign.left),
                  _HeaderCell('Disk'),
                  _HeaderCell('Kamp.', fontSize: 11),
                  _HeaderCell('Porya'),
                  _HeaderCell('Top.', fontSize: 11),
                  _HeaderCell('Oran'),
                ],
              ),
              ...items.map(
                (item) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      child: Text(
                        item.defectName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _DataCell(item.diskScrap > 0 ? '${item.diskScrap}' : ''),
                    _DataCell(item.drumScrap > 0 ? '${item.drumScrap}' : ''),
                    _DataCell(item.hubScrap > 0 ? '${item.hubScrap}' : ''),
                    _DataCell('${item.total}', isBold: true),
                    _DataCell('${item.rate.toStringAsFixed(1)}%'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTab(
    String title,
    List<ScrapTableItem> scrapItems,
    List<ProductionEntry> cleanItems,
    Color color, {
    List<ShiftData>? shifts,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Shift Stats (Only for Frenbu)
          if (shifts != null && shifts.isNotEmpty) ...[
            _buildShiftStatsRow(shifts),
            const SizedBox(height: 24),
          ],

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FİRE LİSTESİ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSimpleScrapTable(scrapItems, color),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FİRESİZ ÜRÜNLER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSimpleCleanTable(cleanItems, color),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleScrapTable(List<ScrapTableItem> items, Color accentColor) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Kayıt bulunamadı.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.white.withValues(
            alpha: 0.1,
          ), // More visible white separator
          width: 1,
        ),
        verticalInside: BorderSide(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      columnWidths: const {
        0: FlexColumnWidth(1.2), // Kod
        1: FlexColumnWidth(1), // Üretim
        2: FlexColumnWidth(0.8), // Fire
        3: FlexColumnWidth(1), // Oran
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          children: const [
            _HeaderCell('Kod', align: TextAlign.right),
            _HeaderCell('Üretim Adeti'),
            _HeaderCell('Fire'),
            _HeaderCell('Oran'),
          ],
        ),
        ...items.map(
          (item) => TableRow(
            children: [
              // Product Code - Clickable
              TableRowInkWell(
                onTap: () => _showScrapDetailDialog(context, item),
                child: _DataCell(
                  item.productCode,
                  isBold: true,
                  align: TextAlign.right,
                ),
              ),
              _DataCell('${item.productionQty}'),
              _DataCell('${item.scrapQty}'),
              _DataCell('${item.scrapRate.toStringAsFixed(1)}%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleCleanTable(
    List<ProductionEntry> items,
    Color accentColor,
  ) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Kayıt bulunamadı.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.white.withValues(
            alpha: 0.1,
          ), // More visible white separator
          width: 1,
        ),
        verticalInside: BorderSide(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      columnWidths: const {
        0: FlexColumnWidth(0.8), // Kod - Narrower to reduce gap
        1: FlexColumnWidth(1), // Üretim
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          children: const [
            _HeaderCell('Kod', align: TextAlign.right),
            _HeaderCell('Üretim Adeti'),
          ],
        ),
        ...items.map(
          (item) => TableRow(
            children: [
              _DataCell(item.productCode, isBold: true, align: TextAlign.right),
              _DataCell('${item.quantity}'),
            ],
          ),
        ),
      ],
    );
  }

  void _showScrapDetailDialog(BuildContext context, ScrapTableItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HATA DETAYLARI - ${item.productCode}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (item.details.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Detay bulunamadı.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 400,
                    child: ListView.separated(
                      itemCount: item.details.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: AppColors.border, height: 32),
                      itemBuilder: (context, index) {
                        final detail = item.details[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Image (Mock)
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.border.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 2. Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        detail.defectName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.reworkOrange,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        child: Text(
                                          '${detail.quantity} Adet',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: AppColors.textMain,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Şarj No: ${detail.batchNo}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    detail.description ?? 'Açıklama yok.',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShiftStatsRow(List<ShiftData> shifts) {
    return Row(
      children: shifts.map((shift) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.shiftName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${shift.scrapQty} Adet',
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '%${shift.rate.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool isBold;
  final TextAlign align;
  const _DataCell(
    this.text, {
    this.isBold = false,
    this.align = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 8,
      ), // Reduced vertical padding
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: AppColors.textMain,
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final TextAlign align;
  final double? fontSize;
  const _HeaderCell(this.text, {this.align = TextAlign.center, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
