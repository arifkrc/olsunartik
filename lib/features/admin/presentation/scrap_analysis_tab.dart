import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../forms/presentation/providers/fire_kayit_providers.dart';
import '../logic/cubits/scrap_analysis_cubit.dart';
import 'widgets/scrap_factory_table.dart';
import 'widgets/scrap_pie_chart.dart';
import 'widgets/scrap_summary_cards.dart';

class ScrapAnalysisTab extends ConsumerStatefulWidget {
  const ScrapAnalysisTab({super.key});

  @override
  ConsumerState<ScrapAnalysisTab> createState() => _ScrapAnalysisTabState();
}

class _ScrapAnalysisTabState extends ConsumerState<ScrapAnalysisTab>
    with SingleTickerProviderStateMixin {
  late TabController _factoryTabController;
  late ScrapAnalysisCubit _cubit;

  @override
  void initState() {
    super.initState();
    _factoryTabController = TabController(length: 3, vsync: this);
    _cubit = ScrapAnalysisCubit();
  }

  @override
  void dispose() {
    _factoryTabController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _showExcelDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            'Excel\'den Yapıştır',
            style: TextStyle(color: AppColors.textMain),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Excel verilerini kopyalayıp (Ctrl+C) aşağıdaki alana yapıştırın (Ctrl+V).\nFormat: Fabrika | Ürün Tipi | Ürün Kodu | Üretim | Fire | Hata Nedeni (Opsiyonel)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 10,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'FRENBU\tDisk\t4210010\t254\t2\tElmas Kırması...',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.duzceGreen,
              ),
              child: const Text('Verileri İşle'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty && mounted) {
      _cubit.importExcelData(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Correct usage: ref.listen at the top level of the build method
    ref.listen(fireKayitFormsProvider, (previous, next) {
      next.whenData((forms) {
        if (forms.isNotEmpty) {
          _cubit.processBackendData(forms);
        }
      });
    });

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ScrapAnalysisCubit, ScrapAnalysisState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text('Hata: ${state.error}'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.zero, // Padding handled internally
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header & Actions (Now Scrollable)
                _buildHeader(context),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Toplam Özet Kartları
                      ScrapSummaryCards(data: state.scrapData),
                      const SizedBox(height: 24),

                      // Pasta Grafik
                      ScrapPieChart(data: state.scrapData),
                      const SizedBox(height: 32),

                      // Fabrika Detay Tabloları (Yan Yana)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ScrapFactoryTable(
                              data: state.scrapData,
                              factory: 'FRENBU',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ScrapFactoryTable(
                              data: state.scrapData,
                              factory: 'D2',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ScrapFactoryTable(
                              data: state.scrapData,
                              factory: 'D3',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // DETAY TABLOLARI (Frenbu Hata Dağılımı)
                      ScrapDefectDistributionTable(
                        data: state.scrapData,
                        factory: 'FRENBU',
                      ),
                      const SizedBox(height: 32),

                      // DETAY TABLOLARI (Firesiz Üretim) - D2 ve D3 Yan Yana
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: NonScrapProductionTable(
                              data: state.scrapData,
                              factory: 'D2',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: NonScrapProductionTable(
                              data: state.scrapData,
                              factory: 'D3',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48), // Bottom padding
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fire Analiz Sayfası',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Moved Date Filter Here
              _buildDateFilter(context),
              const SizedBox(width: 12),

              ElevatedButton.icon(
                onPressed: () => _showExcelDialog(context),
                icon: const Icon(LucideIcons.upload, size: 18),
                label: const Text('Excel Yükle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.duzceGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return BlocBuilder<ScrapAnalysisCubit, ScrapAnalysisState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Shrink to fit
            children: [
              const Icon(
                LucideIcons.calendar,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Periyot:',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              _buildDatePicker(context, state.analysisStartDate, (date) {
                context.read<ScrapAnalysisCubit>().updateAnalysisDateRange(
                  date,
                  state.analysisEndDate,
                );
              }),
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.arrowRight,
                color: AppColors.textSecondary,
                size: 12,
              ),
              const SizedBox(width: 8),
              _buildDatePicker(context, state.analysisEndDate, (date) {
                context.read<ScrapAnalysisCubit>().updateAnalysisDateRange(
                  state.analysisStartDate,
                  date,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    DateTime date,
    Function(DateTime) onSelect,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
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
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          DateFormat('dd.MM.yyyy').format(date),
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
