import 'dart:convert';
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
import '../../domain/entities/audit_action.dart';
import '../providers/audit_providers.dart';

class ReportEditTab extends ConsumerStatefulWidget {
  const ReportEditTab({super.key});

  @override
  ConsumerState<ReportEditTab> createState() => _ReportEditTabState();
}

class _ReportEditTabState extends ConsumerState<ReportEditTab> {
  int _selectedFormIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String? _selectedShift; // null = 'Tümü', 'Gündüz', 'Gece'

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
    /* 
       Updated Layout:
       1. Header Row: Title + "Create History Record" Button (Top Right)
       2. Form Selection List (Horizontal)
       3. History List (Vertical)
    */
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
                  onPressed: () => _navigateToForm(_selectedFormIndex),
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
              final isSelected = _selectedFormIndex == index;
              final color = form['color'] as Color;

              return GestureDetector(
                onTap: () => setState(() => _selectedFormIndex = index),
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
      ],
    );
  }

  Widget _buildFilterBar() {
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
                  initialDate: _selectedDate,
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
                  setState(() => _selectedDate = date);
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
                      DateFormat('dd.MM.yyyy').format(_selectedDate),
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
                child: DropdownButton<String?>(
                  value: _selectedShift,
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
                      value: '08:00 - 16:00',
                      child: Row(
                        children: [
                          Icon(LucideIcons.sun, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          const Text('08:00 - 16:00'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: '16:00 - 00:00',
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
                      value: '00:00 - 08:00',
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
                    setState(() => _selectedShift = value);
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
    final auditState = ref.watch(auditStateProvider);
    final currentForm = _forms[_selectedFormIndex];
    final formType = currentForm['type'] as String;
    final color = currentForm['color'] as Color;

    return auditState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Hata: $e')),
      data: (allActions) {
        // Filter actions:
        // 1. Matches varlikTipi
        // 2. Matches selectedDate
        // 3. Matches selectedShift (if not null)
        final filteredActions = allActions.where((action) {
          // Type filter
          if (action.varlikTipi != formType) return false;

          // Date filter (action.islemTarihi or similar field if available, 
          // but AuditAction might have its own timestamp)
          // Let's assume action.islemTarihi matches the form's creation date
          final actionDate = action.islemTarihi;
          final isSameDay = actionDate.year == _selectedDate.year &&
                            actionDate.month == _selectedDate.month &&
                            actionDate.day == _selectedDate.day;
          if (!isSameDay) return false;

          // Shift filter (this would require 'vardiya' to be in the JSON payload or a separate field)
          if (_selectedShift != null) {
            try {
              final data = jsonDecode(action.yeniDeger) as Map<String, dynamic>;
              if (data['vardiya'] != _selectedShift) return false;
            } catch (_) {
              return false;
            }
          }

          return true;
        }).toList();

        if (filteredActions.isEmpty) {
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
          itemCount: filteredActions.length,
          itemBuilder: (context, index) {
            final action = filteredActions[index];
            Map<String, dynamic> data = {};
            try {
              data = jsonDecode(action.yeniDeger) as Map<String, dynamic>;
            } catch (e) {
              return Text('Veri okuma hatası: $e');
            }

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
                                DateFormat('HH:mm').format(action.islemTarihi),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSummaryText(formType, data),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Yapan: ${action.kullaniciAdi}',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit, size: 18, color: AppColors.primary),
                        tooltip: 'Düzenle',
                        onPressed: () => _openEditDialog(formType, data, action.varlikId),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                        tooltip: 'Sil',
                        onPressed: () => _showDeleteDialog(formType, data, action.varlikId),
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

  String _getSummaryText(String type, Map<String, dynamic> data) {
    try {
      switch (type) {
        case 'KaliteOnay':
          final decision = data['isUygun'] == true ? 'Kabul' : 'Ret';
          return '${data['urunKodu'] ?? '-'} | ${data['adet'] ?? 0} Adet - $decision';
        case 'FinalKontrol':
          final p = data['paketAdet'] ?? data['toplamAdet'] ?? 0;
          final r = data['retAdet'] ?? data['toplamRed'] ?? 0;
          return '${data['urunKodu'] ?? '-'} | Paket: $p | Red: $r';
        case 'FireKayitFormu':
          return '${data['urunKodu'] ?? '-'} | ${data['miktar'] ?? 0} Adet - ID: ${data['retKoduId'] ?? '-'}';
        case 'Rework':
          return '${data['urunKodu'] ?? '-'} | ${data['adet'] ?? 0} Adet - Sonuç: ${data['sonuc'] ?? '-'}';
        case 'GirisKalite':
          final m = data['miktar'] ?? 0;
          final status = data['kabul'] == true ? 'Kabul' : 'Ret';
          return '${data['urunKodu'] ?? '-'} | $m Adet - $status';
        case 'PaletGiris':
          return '${data['tedarikciAdi'] ?? '-'} | İrsaliye: ${data['irsaliyeNo'] ?? '-'} | Ürün: ${data['urunAdi'] ?? '-'}';
        case 'SafB9':
          final d = data['duzce'] ?? data['duzceSayac'] ?? 0;
          final a = data['almanya'] ?? data['almanyaSayac'] ?? 0;
          return '${data['urunKodu'] ?? '-'} | D: $d | A: $a | Hurda: ${data['retAdet'] ?? 0}';
        default:
          return 'Veri detayı görüntülenemiyor';
      }
    } catch (_) {
      return 'Veri formatı uyumsuz';
    }
  }

  void _showDeleteDialog(String type, Map<String, dynamic> data, int? id) {
    if (id == null) return;
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

            ref.invalidate(auditStateProvider);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Kayıt başarıyla silindi (ID: $id)'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Silme hatası: $e'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _openEditDialog(String type, Map<String, dynamic> data, int? id) {
    if (id == null) return;
    
    // Ensure the data map has the 'id' for the dialogs to use
    final editData = Map<String, dynamic>.from(data);
    editData['id'] = id;

    Widget? dialog;
    switch (type) {
      case 'KaliteOnay':
        dialog = EditQualityApprovalDialog(data: editData); // Needs update to hit PUT
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

  void _navigateToForm(int index) {
    Widget? screen;
    final initialDate = DateTime.now();

    switch (index) {
      case 0:
        screen = QualityApprovalFormScreen(
          initialDate: initialDate,
        ); // Fixed parameter
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
        // Palet Giriş
        screen = PaletGirisKaliteScreen(initialDate: initialDate);
        break;
      case 6:
        // SAF B9
        screen = SafB9CounterScreen(initialDate: initialDate);
        break;
    }

    if (screen != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen!));
    }
  }
}
