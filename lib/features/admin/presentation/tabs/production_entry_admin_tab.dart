import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../scrap_analysis/analysis_provider.dart';

import 'package:intl/intl.dart';
import '../../../../core/providers/product_providers.dart';
import '../../data/models/uretim_bilgisi_bulk_dto.dart';
import '../providers/uretim_bilgisi_providers.dart';
import '../scrap_analysis/models.dart';
import '../dialogs/excel_preview_dialog.dart';

class ProductionEntryAdminTab extends ConsumerStatefulWidget {
  const ProductionEntryAdminTab({super.key});

  @override
  ConsumerState<ProductionEntryAdminTab> createState() =>
      _ProductionEntryAdminTabState();
}

class _ProductionEntryAdminTabState
    extends ConsumerState<ProductionEntryAdminTab> {
  final TextEditingController _productionController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _productionController.dispose();
    super.dispose();
  }

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result != null) {
        List<int>? bytes = result.files.single.bytes;

        if (bytes == null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          bytes = await file.readAsBytes();
        }

        if (bytes != null) {
          setState(() {
            _isUploading = true;
          });

          // 1. Parse Excel
          final List<ScrapUploadItem> parsedItems =
              await ref.read(scrapAnalysisProvider.notifier).parseExcel(bytes);

          if (parsedItems.isEmpty) {
            _showError('Excel dosyasında geçerli veri bulunamadı.');
            setState(() {
              _isUploading = false;
            });
            return;
          }

          // 2. Load DB Products
          final allProductsAsync = await ref.read(allProductsProvider.future);
          final productMap = {for (var p in allProductsAsync) p.urunKodu: p.id};

          // 3. Validate and Aggregate Production Items
        final List<String> missingCodes = [];
        final Map<String, UretimBilgisiBulkItemDto> bulkItemsMap = {};
        final Set<DateTime> uniqueDates = {};
        
        DateTime? lastValidDate;

        for (var item in parsedItems) {
          if (!productMap.containsKey(item.productCode)) {
            if (!missingCodes.contains(item.productCode)) {
              missingCodes.add(item.productCode);
            }
          } else {
            final urunId = productMap[item.productCode]!;
            
            // Priority: Use Excel date (Column A). Forward Fill: Use last seen valid date. Fallback: today.
            if (item.date != null) {
              lastValidDate = item.date;
            }
            
            final itemDate = lastValidDate ?? DateTime.now();
            final tarih = DateFormat('yyyy-MM-dd').format(itemDate);
            uniqueDates.add(DateTime(itemDate.year, itemDate.month, itemDate.day));

            final fabrika = item.factory.isEmpty ? "BELIRTILMEDI" : item.factory;
            
            final key = "$urunId-$tarih-$fabrika";

            if (bulkItemsMap.containsKey(key)) {
              final existing = bulkItemsMap[key]!;
              bulkItemsMap[key] = existing.copyWith(
                tornaAdeti: existing.tornaAdeti + item.quantity,
                delikAdeti: (existing.delikAdeti ?? 0) + item.holeQty,
              );
            } else {
              bulkItemsMap[key] = UretimBilgisiBulkItemDto(
                uretimTarihi: tarih,
                urunId: urunId,
                dokumhaneAdi: fabrika,
                tornaAdeti: item.quantity,
                delikAdeti: item.holeQty,
              );
            }
          }
        }

        final bulkItems = bulkItemsMap.values.toList();

        if (missingCodes.isNotEmpty) {
          setState(() {
            _isUploading = false;
          });
          _showMissingProductsDialog(missingCodes);
          return;
        }

        // 4. All Valid -> Show Preview Dialog
        if (!mounted) return;
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => ExcelPreviewDialog(items: bulkItems),
        );

        if (confirmed != true) {
          setState(() {
            _isUploading = false;
          });
          return;
        }

        // 5. All Valid & Confirmed -> Submit to API
        try {
          await ref.read(bulkInsertUretimBilgisiUseCaseProvider).call(
                UretimBilgisiBulkRequestDto(kayitlar: bulkItems),
              );

          // 6. Fetch updated Dashboard Data from Backend (Force Recalculation for all updated dates)
          for (var date in uniqueDates) {
            await ref.read(scrapAnalysisProvider.notifier).fetchDashboardData(date, forceCalculate: true);
          }

            _showSuccess('Excel verileri başarıyla sisteme kaydedildi ve analiz güncellendi.');
          } catch (e) {
            _showError('Veriler kaydedilirken hata oluştu: $e');
          }

          setState(() {
            _isUploading = false;
          });

        } else {
          _showError('Dosya okunamadı: İçerik boş.');
        }
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showError('Dosya işleme hatası: $e');
    }
  }

  void _showMissingProductsDialog(List<String> missingCodes) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: AppColors.error),
            SizedBox(width: 8),
            Text('Kayıt Bulunamadı'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aşağıdaki ürün kodları sistemde (veri tabanında) bulunamadı. Lütfen ürünlerin sistemde olduğundan emin olup tekrar deneyin:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var code in missingCodes)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.xCircle, color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                code,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat', style: TextStyle(color: AppColors.textMain)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.listPlus,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Üretim Verisi Girişi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Excel tablosu yükleyerek üretim verilerini sisteme işleyebilirsiniz. (Excel ortamında A sütunu veriye ait tarihi B sütunu Ürün Kodunu C sütunu dökümhaneyi D sütunu üretim adetini temsil eder)',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Excel Upload Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      LucideIcons.fileSpreadsheet,
                      color: Colors.green,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Excel İle Toplu Yükleme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fire analiz raporu oluşturmak için üretim takip Excel dosyasını yükleyiniz.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickExcelFile,
                    icon: _isUploading 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          ) 
                        : const Icon(LucideIcons.upload, size: 20),
                    label: Text(_isUploading ? 'Yükleniyor...' : 'Excel Dosyası Seç ve Yükle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Manual Production Entry Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      LucideIcons.packagePlus,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Manuel Üretim Adeti Girişi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _productionController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textMain),
                        decoration: InputDecoration(
                          labelText: 'FRENBU Üretim Adeti',
                          hintText: 'Örn: 1500',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          prefixIcon: const Icon(
                            LucideIcons.hash,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final value = int.tryParse(_productionController.text);
                        if (value != null && value >= 0) {
                          setState(() {
                            _isUploading = true;
                          });
                          try {
                            // Call fetchDashboardData with forceCalculate=true and the manual production count
                            await ref.read(scrapAnalysisProvider.notifier).fetchDashboardData(
                              DateTime.now(),
                              forceCalculate: true,
                              frenbuUretimAdeti: value,
                            );
                            _showSuccess('FRENBU Üretim adeti kaydedildi ve analiz güncellendi: $value');
                            _productionController.clear();
                          } catch (e) {
                            _showError('Analiz güncellenirken hata oluştu: $e');
                          } finally {
                            setState(() {
                              _isUploading = false;
                            });
                          }
                        } else {
                          _showError('Geçerli bir adet giriniz.');
                        }
                      },
                      icon: const Icon(LucideIcons.save, size: 18),
                      label: const Text('Kaydet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
