import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/constants/production_constants.dart';
import '../../../forms/domain/entities/fire_kayit_formu.dart';

part 'scrap_analysis_state.dart';

class ScrapAnalysisCubit extends Cubit<ScrapAnalysisState> {
  ScrapAnalysisCubit() : super(ScrapAnalysisState.initial()) {
    _loadMockData();
  }

  void _loadMockData() {
    // Generate 55 Mock Items
    final List<ScrapData> mockData = [];
    final factories = ['FRENBU', 'D2', 'D3'];
    final products = ['Disk', 'Kampana', 'Porya', 'Volan'];

    for (int i = 0; i < 55; i++) {
      final factory = factories[i % 3];
      mockData.add(
        ScrapData(
          factory: factory,
          productType: products[i % 4],
          productCode: '${4000000 + i * 105}', // Unique-ish codes
          productionQty: 100 + (i * 12),
          scrapQty: (i % 10) == 0 ? 0 : (i % 5) + 1, // Varied scrap
          defectReason: (i % 7) == 0 ? 'Darbeye Bağlı Kırık' : '',
        ),
      );
    }
    emit(state.copyWith(scrapData: mockData, isLoading: false));
  }

  // Tarih Filtrelerini Güncelle
  void updateAnalysisDateRange(DateTime start, DateTime end) {
    emit(state.copyWith(analysisStartDate: start, analysisEndDate: end));
    // Not: Gerçek uygulamada burada verileri yeniden filtrelemek gerekebilir
  }

  void updateBackendDateRange(DateTime start, DateTime end) {
    emit(state.copyWith(backendStartDate: start, backendEndDate: end));
  }

  // Excel Verilerini İşle
  void importExcelData(String rawData) {
    emit(state.copyWith(isLoading: true));
    try {
      final List<ScrapData> newItems = [];
      final lines = rawData.split('\n');

      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        final parts = line.split('\t');
        if (parts.length >= 5) {
          newItems.add(
            ScrapData(
              factory: parts[0].trim(),
              productType: parts[1].trim(),
              productCode: parts[2].trim(),
              productionQty: int.tryParse(parts[3].replaceAll('.', '')) ?? 0,
              scrapQty: int.tryParse(parts[4].replaceAll('.', '')) ?? 0,
              defectReason: parts.length > 5 ? parts[5].trim() : '',
            ),
          );
        }
      }

      if (newItems.isNotEmpty) {
        emit(state.copyWith(scrapData: newItems, isLoading: false));
      } else {
        throw Exception('Formatı uygun veri bulunamadı');
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  // Backend Verilerini ScrapData'ya Dönüştür ve Ekle
  void processBackendData(List<FireKayitFormu> forms) {
    final backendData = convertFireFormsToScrapData(forms);
    // Backend verisi gelince mock veriyi eziyoruz (Şimdilik)
    if (backendData.isNotEmpty) {
      emit(state.copyWith(scrapData: backendData, isLoading: false));
    }
  }

  List<ScrapData> convertFireFormsToScrapData(List<FireKayitFormu> forms) {
    // Tarihe göre filtrele
    final filteredForms = forms.where((form) {
      final start = DateTime(
        state.analysisStartDate.year,
        state.analysisStartDate.month,
        state.analysisStartDate.day,
      );
      final end = DateTime(
        state.analysisEndDate.year,
        state.analysisEndDate.month,
        state.analysisEndDate.day,
        23,
        59,
        59,
      );
      return form.islemTarihi.isAfter(start) && form.islemTarihi.isBefore(end);
    }).toList();

    // Ürün bazında grupla
    final Map<String, List<FireKayitFormu>> groupedByProduct = {};
    for (final form in filteredForms) {
      groupedByProduct.putIfAbsent(form.urunKodu ?? 'Bilinmeyen Kod', () => []).add(form);
    }

    final List<ScrapData> scrapDataList = [];
    for (final entry in groupedByProduct.entries) {
      final productCode = entry.key;
      final records = entry.value;
      final scrapQty = records.length;
      final productionQty = scrapQty * 20; // Mock logic preserved

      scrapDataList.add(
        ScrapData(
          factory: ProductionConstants.defaultFactory,
          productType: ProductionConstants.defaultProductType,
          productCode: productCode,
          productionQty: productionQty,
          scrapQty: scrapQty,
          defectReason: records.first.retKoduIds.isNotEmpty 
              ? 'Kod ID: ${records.first.retKoduIds.first}' 
              : '',
        ),
      );
    }

    return scrapDataList;
  }
}
