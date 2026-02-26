
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/dialogs/delete_confirmation_dialog.dart';
import '../../../forms/presentation/fire_kayit/fire_kayit_screen.dart';
import '../../../forms/presentation/giris_kalite_kontrol_screen.dart';
import '../../../forms/presentation/final_kontrol_screen.dart';
import '../../../forms/presentation/rework_screen.dart';
import '../../../forms/presentation/saf_b9_counter_screen.dart';
import '../../../forms/presentation/quality_approval_form_screen.dart';
import '../dialogs/edit_forms/edit_quality_approval_dialog.dart';
import '../dialogs/edit_forms/edit_final_control_dialog.dart';
import '../dialogs/edit_forms/edit_fire_kayit_dialog.dart';
import '../dialogs/edit_forms/edit_rework_dialog.dart';
import '../dialogs/edit_forms/edit_giris_kalite_dialog.dart';
import '../dialogs/edit_forms/edit_palet_giris_dialog.dart';
import '../dialogs/edit_forms/edit_saf_b9_dialog.dart';
import '../../../forms/presentation/palet_giris_kalite_screen.dart';
import '../providers/report_edit_providers.dart';

import '../../../forms/domain/entities/quality_approval_form.dart';
import '../../../forms/domain/entities/final_kontrol_form.dart';
import '../../../forms/domain/entities/fire_kayit_formu.dart';
import '../../../forms/domain/entities/rework_form.dart';
import '../../../forms/domain/entities/giris_kalite_kontrol_form.dart';
import '../../../forms/domain/entities/palet_giris_form.dart';
import '../../../forms/data/models/saf_b9_counter_entry_dto.dart';
import '../../../forms/presentation/providers/quality_approval_providers.dart';
import '../../../forms/presentation/providers/final_kontrol_providers.dart';
import '../../../forms/presentation/providers/fire_kayit_providers.dart';
import '../../../forms/presentation/providers/rework_providers.dart';
import '../../../forms/presentation/providers/giris_kalite_kontrol_providers.dart';
import '../../../forms/presentation/providers/palet_giris_providers.dart';
import '../../../forms/presentation/providers/saf_b9_counter_providers.dart';

class ReportEditTab extends ConsumerStatefulWidget {
  const ReportEditTab({super.key});

  @override
  ConsumerState<ReportEditTab> createState() => _ReportEditTabState();
}

class _ReportEditTabState extends ConsumerState<ReportEditTab> {
  final List<Map<String, dynamic>> _forms = [
    {
      'title': 'Kalite Onay',
      'icon': LucideIcons.checkCircle,
      'color': Colors.blue,
      'type': 'KaliteOnay',
    },
    {
      'title': 'Final Kontrol',
      'icon': LucideIcons.packageCheck,
      'color': Colors.green,
      'type': 'FinalKontrol',
    },
    {
      'title': 'Fire Kayıt',
      'icon': LucideIcons.flame,
      'color': Colors.red,
      'type': 'FireKayitFormu',
    },
    {
      'title': 'Rework Takip',
      'icon': LucideIcons.refreshCw,
      'color': AppColors.reworkOrange,
      'type': 'Rework',
    },
    {
      'title': 'Giriş Kalite',
      'icon': LucideIcons.clipboardCheck,
      'color': Colors.purple,
      'type': 'GirisKalite',
    },
    {
      'title': 'Palet Giriş',
      'icon': LucideIcons.packageCheck,
      'color': Colors.teal,
      'type': 'PaletGiris',
    },
    {
      'title': 'SAF B9',
      'icon': LucideIcons.factory,
      'color': Colors.blueGrey,
      'type': 'SafB9',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(reportFilterProvider);
    final selectedIndex = _forms.indexWhere((f) => f['type'] == filter.type);

    return Column(
      children: [
        // 1. Header with Title and Create Button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rapor Düzenleme',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              // "Geçmiş Kayıt" Button - Visible for all
              Tooltip(
                message: 'Geçmişe Yönelik Kayıt Oluştur',
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToForm(selectedIndex),
                  icon: const Icon(
                    LucideIcons.history,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Geçmiş Kayıt',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Form Selection (Horizontal List)
        Container(
          height: 90,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _forms.length,
            itemBuilder: (context, index) {
              final form = _forms[index];
              final isSelected = selectedIndex == index;
              final color = form['color'] as Color;

              return GestureDetector(
                onTap: () {
                  ref.read(reportFilterProvider.notifier).update(
                        (s) => s.copyWith(type: form['type'], pageNumber: 1),
                      );
                },
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.15)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : AppColors.glassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        form['icon'] as IconData,
                        color: isSelected ? color : AppColors.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        form['title'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.textMain
                              : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const Divider(color: AppColors.glassBorder, height: 1),

        // 3. Filter Bar
        _buildFilterBar(),

        const Divider(color: AppColors.glassBorder, height: 1),

        // 4. History List (Vertical)
        Expanded(child: _buildHistoryList()),
        
        // 5. Pagination Controls
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildPaginationControls() {
    final listAsync = ref.watch(reportListProvider);

    return listAsync.maybeWhen(
      data: (paged) {
        if (paged.totalPages <= 1) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam ${paged.totalCount} kayıt',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.chevronLeft),
                    onPressed: paged.hasPreviousPage
                        ? () => ref.read(reportFilterProvider.notifier).update(
                              (s) => s.copyWith(pageNumber: s.pageNumber - 1),
                            )
                        : null,
                  ),
                  Text(
                    '${paged.pageNumber} / ${paged.totalPages}',
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.chevronRight),
                    onPressed: paged.hasNextPage
                        ? () => ref.read(reportFilterProvider.notifier).update(
                              (s) => s.copyWith(pageNumber: s.pageNumber + 1),
                            )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildFilterBar() {
    final filter = ref.watch(reportFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface.withValues(alpha: 0.3),
      child: Row(
        children: [
          // Date Filter
          Expanded(
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: filter.date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: AppColors.primary,
                          surface: AppColors.surface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  ref.read(reportFilterProvider.notifier).update(
                    (s) => s.copyWith(date: date, pageNumber: 1),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd.MM.yyyy').format(filter.date),
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Shift Filter
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: filter.vardiyaId,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceLight,
                  icon: Icon(
                    LucideIcons.chevronDown,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text('Tüm Vardiyalar'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(LucideIcons.sun, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          const Text('08:00 - 16:00'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.sunset,
                            color: Colors.deepOrange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text('16:00 - 00:00'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.moon,
                            color: Colors.indigo,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text('00:00 - 08:00'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    ref.read(reportFilterProvider.notifier).update(
                      (s) => s.copyWith(vardiyaId: value, pageNumber: 1),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final listAsync = ref.watch(reportListProvider);
    final filter = ref.watch(reportFilterProvider);
    final currentForm = _forms.firstWhere((f) => f['type'] == filter.type);
    final color = currentForm['color'] as Color;

    return listAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Hata: $e')),
      data: (paged) {
        if (paged.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.inbox,
                  size: 48,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bu tarih ve form için kayıt bulunamadı',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: paged.items.length,
          itemBuilder: (context, index) {
            final item = paged.items[index];
            final int? recordId = _getRecordId(item);
            final DateTime? timestamp = _getTimestamp(item);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      currentForm['icon'] as IconData,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${currentForm['title']} Kaydı',
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (timestamp != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: Text(
                                  DateFormat('HH:mm').format(timestamp),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSummaryText(filter.type, item),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        _buildSubInfo(filter.type, item),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit, size: 18, color: AppColors.primary),
                        tooltip: 'Düzenle',
                        onPressed: () => _openEditDialog(filter.type, item, recordId),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                        tooltip: 'Sil',
                        onPressed: () => _showDeleteDialog(filter.type, item, recordId),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.error.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int? _getRecordId(dynamic item) {
    if (item is QualityApprovalForm) return item.id;
    if (item is FinalKontrolRecord) return item.id;
    if (item is FireKayitFormu) return item.id;
    if (item is ReworkForm) return item.id; // Check if ReworkForm has id
    if (item is GirisKaliteKontrolForm) return item.id;
    if (item is PaletGirisForm) return item.id;
    if (item is SAFBResponseDto) return item.id;
    return null;
  }

  DateTime? _getTimestamp(dynamic item) {
    if (item is QualityApprovalForm) return item.islemTarihi;
    if (item is FinalKontrolRecord) return item.islemTarihi;
    if (item is FireKayitFormu) return item.islemTarihi;
    if (item is ReworkForm) return item.kayitTarihi; // ReworkForm has kayitTarihi
    if (item is GirisKaliteKontrolForm) return item.kayitTarihi;
    if (item is PaletGirisForm) return item.kayitTarihi;
    if (item is SAFBResponseDto) return item.islemTarihi;
    return null;
  }

  Widget _buildSubInfo(String type, dynamic item) {
    String? user;
    if (item is FinalKontrolRecord) user = item.kullaniciAdi;
    if (item is FireKayitFormu) user = item.kullaniciAdi;
    if (item is SAFBResponseDto) user = item.kullaniciAdi;

    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        'Yapan: $user',
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          fontSize: 11,
        ),
      ),
    );
  }

  String _getSummaryText(String type, dynamic item) {
    try {
      if (item is QualityApprovalForm) {
        final decision = item.isUygun ? 'Kabul' : 'Ret';
        return '${item.urunKodu} | ${item.adet} Adet - $decision';
      }
      if (item is FinalKontrolRecord) {
        return '${item.urunKodu ?? '-'} | Paket: ${item.paketAdet} | Red: ${item.retAdet}';
      }
      if (item is FireKayitFormu) {
        return '${item.urunKodu} | ${item.adet} Adet - ${item.aciklama ?? '-'}';
      }
      if (item is ReworkForm) {
        return '${item.urunKodu ?? '-'} | ${item.adet} Adet - Sonuç: ${item.sonuc}';
      }
      if (item is GirisKaliteKontrolForm) {
        final status = item.kabul ? 'Kabul' : 'Ret';
        return '${item.urunKodu} | ${item.miktar} ${item.birim} - $status';
      }
      if (item is PaletGirisForm) {
        return '${item.tedarikciAdi} | İrsaliye: ${item.irsaliyeNo} | Ürün: ${item.urunAdi}';
      }
      if (item is SAFBResponseDto) {
        return '${item.urunKodu ?? '-'} | D: ${item.duzceSayac} | A: ${item.almanyaSayac} | Hurda: ${item.retAdet}';
      }
      return 'Veri detayı görüntülenemiyor';
    } catch (_) {
      return 'Veri formatı uyumsuz';
    }
  }

  void _showDeleteDialog(String type, dynamic item, int? id) {
    if (id == null) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        formType: type,
        recordId: id.toString(),
        onConfirm: () async {
          try {
            switch (type) {
              case 'KaliteOnay':
                await ref.read(qualityApprovalRepositoryProvider).delete(id);
                break;
              case 'FinalKontrol':
                await ref.read(finalKontrolRepositoryProvider).delete(id);
                break;
              case 'FireKayitFormu':
                await ref.read(fireKayitRepositoryProvider).deleteForm(id);
                break;
              case 'Rework':
                await ref.read(reworkRepositoryProvider).delete(id);
                break;
              case 'GirisKalite':
                await ref.read(girisKaliteKontrolRepositoryProvider).delete(id);
                break;
              case 'PaletGiris':
                await ref.read(paletGirisRepositoryProvider).delete(id);
                break;
              case 'SafB9':
                await ref.read(safB9CounterRepositoryProvider).delete(id);
                break;
            }

            ref.invalidate(reportListProvider);

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Kayıt başarıyla silindi (ID: $id)'),
                backgroundColor: AppColors.success,
              ),
            );
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('Silme hatası: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _openEditDialog(String type, dynamic item, int? id) {
    if (id == null) return;
    
    final editData = _entityToMap(type, item);
    editData['id'] = id;

    Widget? dialog;
    switch (type) {
      case 'KaliteOnay':
        dialog = EditQualityApprovalDialog(data: editData); 
        break;
      case 'FinalKontrol':
        dialog = EditFinalControlDialog(data: editData);
        break;
      case 'FireKayitFormu':
        dialog = EditFireKayitDialog(data: editData);
        break;
      case 'Rework':
        dialog = EditReworkDialog(data: editData);
        break;
      case 'GirisKalite':
        dialog = EditGirisKaliteDialog(data: editData);
        break;
      case 'PaletGiris':
        dialog = EditPaletGirisDialog(data: editData);
        break;
      case 'SafB9':
        dialog = EditSafB9Dialog(data: editData);
        break;
    }

    if (dialog != null) {
      showDialog(context: context, builder: (context) => dialog!);
    }
  }

  Map<String, dynamic> _entityToMap(String type, dynamic item) {
    if (item is QualityApprovalForm) {
      return {
        'id': item.id,
        'urunId': item.urunId,
        'urunKodu': item.urunKodu,
        'urunAdi': item.urunAdi,
        'urunTuru': item.urunTuru,
        'adet': item.adet,
        'isUygun': item.isUygun,
        'retKoduId': item.retKoduId,
        'aciklama': item.aciklama,
        'islemTarihi': item.islemTarihi.toIso8601String(),
      };
    }
    if (item is FinalKontrolRecord) {
      return {
        'id': item.id,
        'urunId': item.urunId,
        'urunKodu': item.urunKodu,
        'musteriAdi': item.musteriAdi,
        'paletNo': item.paletNo,
        'paketAdet': item.paketAdet,
        'retAdet': item.retAdet,
        'reworkAdet': item.reworkAdet,
        'aciklama': item.aciklama,
        'islemTarihi': item.islemTarihi.toIso8601String(),
        'izlenebilirlikBarkod': item.paletIzlenebilirlikNo,
      };
    }
    if (item is FireKayitFormu) {
      return {
        'id': item.id,
        'urunId': item.urunId,
        'urunKodu': item.urunKodu,
        'adet': item.adet,
        'retKoduIds': item.retKoduIds,
        'aciklama': item.aciklama,
        'islemTarihi': item.islemTarihi.toIso8601String(),
        'materialDurumu': item.malzemeDurumu,
      };
    }
    if (item is ReworkForm) {
      return {
        'id': item.id,
        'urunId': item.urunId,
        'urunKodu': item.urunKodu,
        'adet': item.adet,
        'retKoduId': item.retKoduId,
        'sarjNo': item.sarjNo,
        'sonuc': item.sonuc,
        'aciklama': item.aciklama,
        'kayitTarihi': item.kayitTarihi?.toIso8601String(),
      };
    }
    if (item is GirisKaliteKontrolForm) {
      return {
        'id': item.id,
        'tedarikci': item.tedarikci,
        'urunKodu': item.urunKodu,
        'lotNo': item.lotNo,
        'miktar': item.miktar,
        'kabul': item.kabul ? 'Kabul' : 'Red', 
        'aciklama': item.aciklama,
      };
    }
    if (item is PaletGirisForm) {
      return {
        'id': item.id,
        'tedarikciAdi': item.tedarikciAdi,
        'irsaliyeNo': item.irsaliyeNo,
        'urunAdi': item.urunAdi,
        'nemOlcumleri': item.nemOlcumleri,
        'fizikiYapiKontrol': item.fizikiYapiKontrol,
        'muhurKontrol': item.muhurKontrol,
        'irsaliyeEslestirme': item.irsaliyeEslestirme,
        'aciklama': item.aciklama,
      };
    }
    if (item is SAFBResponseDto) {
      return {
        'id': item.id,
        'tezgah': 'Tezgah 1',
        'duzce': item.duzceSayac,
        'almanya': item.almanyaSayac,
        'hurda': item.retAdet,
        'aciklama': item.aciklama,
      };
    }
    return {};
  }

  void _navigateToForm(int index) {
    Widget? screen;
    final initialDate = DateTime.now();

    switch (index) {
      case 0:
        screen = QualityApprovalFormScreen(
          initialDate: initialDate,
        );
        break;
      case 1:
        screen = FinalKontrolScreen(initialDate: initialDate);
        break;
      case 2:
        screen = FireKayitScreen(initialDate: initialDate);
        break;
      case 3:
        screen = ReworkScreen(initialDate: initialDate);
        break;
      case 4:
        screen = GirisKaliteKontrolScreen(initialDate: initialDate);
        break;
      case 5:
        screen = PaletGirisKaliteScreen(initialDate: initialDate);
        break;
      case 6:
        screen = SafB9CounterScreen(initialDate: initialDate);
        break;
    }

    if (screen != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen!)).then((_) {
        ref.invalidate(reportListProvider);
      });
    }
  }
}
