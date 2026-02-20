import 'package:flutter/material.dart';
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

class ReportEditTab extends StatefulWidget {
  const ReportEditTab({super.key});

  @override
  State<ReportEditTab> createState() => _ReportEditTabState();
}

class _ReportEditTabState extends State<ReportEditTab> {
  int _selectedFormIndex = 0;
  DateTime _selectedDate = DateTime.now();
  String? _selectedShift; // null = 'Tümü', 'Gündüz', 'Gece'

  final List<Map<String, dynamic>> _forms = [
    {
      'title': 'Kalite Onay',
      'icon': LucideIcons.checkCircle,
      'color': Colors.blue,
      'type': 'quality_approval',
    },
    {
      'title': 'Final Kontrol',
      'icon': LucideIcons.packageCheck,
      'color': Colors.green,
      'type': 'final_control',
    },
    {
      'title': 'Fire Kayıt',
      'icon': LucideIcons.flame,
      'color': Colors.red,
      'type': 'fire_kayit',
    },
    {
      'title': 'Rework Takip',
      'icon': LucideIcons.refreshCw,
      'color': AppColors.reworkOrange,
      'type': 'rework',
    },
    {
      'title': 'Giriş Kalite',
      'icon': LucideIcons.clipboardCheck,
      'color': Colors.purple,
      'type': 'giris_kalite',
    },
    {
      'title': 'Palet Giriş',
      'icon': LucideIcons.packageCheck,
      'color': Colors.teal,
      'type': 'palet_giris',
    },
    {
      'title': 'SAF B9',
      'icon': LucideIcons.factory,
      'color': Colors.blueGrey,
      'type': 'saf_b9',
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
    final currentForm = _forms[_selectedFormIndex];
    final formType = currentForm['type'] as String;
    final color = currentForm['color'] as Color;

    // Generate mock data and filter
    final allRecords = List.generate(20, (index) {
      final daysAgo = index ~/ 3;
      final date = DateTime.now().subtract(Duration(days: daysAgo));
      final shiftIndex = index % 3;
      final shift = shiftIndex == 0
          ? '08:00 - 16:00'
          : shiftIndex == 1
          ? '16:00 - 00:00'
          : '00:00 - 08:00';
      final mockData = _getMockDataForType(formType, index);
      mockData['date'] = date;
      mockData['shift'] = shift;
      return mockData;
    });

    // Apply filters
    final filteredRecords = allRecords.where((record) {
      final recordDate = record['date'] as DateTime;
      final recordShift = record['shift'] as String;

      // Date filter (same day)
      final isSameDay =
          recordDate.year == _selectedDate.year &&
          recordDate.month == _selectedDate.month &&
          recordDate.day == _selectedDate.day;

      if (!isSameDay) return false;

      // Shift filter
      if (_selectedShift != null && recordShift != _selectedShift) {
        return false;
      }

      return true;
    }).toList();

    if (filteredRecords.isEmpty) {
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
              'Bu tarih ve vardiya için kayıt bulunamadı',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final mockData = filteredRecords[index];
        final date = mockData['date'] as DateTime;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12), // Reduced padding
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              // Icon Box
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

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${currentForm['title']} #${1900 + index}',
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
                            DateFormat('dd.MM.yyyy HH:mm').format(date),
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
                      _getSummaryText(formType, mockData),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Op: Ahmet Yılmaz',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.edit,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    tooltip: 'Düzenle',
                    onPressed: () => _openEditDialog(formType, mockData),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.trash2,
                      size: 18,
                      color: AppColors.error,
                    ),
                    tooltip: 'Sil',
                    onPressed: () => _showDeleteDialog(formType, mockData),
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
  }

  // --- Mock Data Helpers ---

  Map<String, dynamic> _getMockDataForType(String type, int index) {
    // Return appropriate mock data based on form type
    switch (type) {
      case 'quality_approval':
        return {
          'id': 'QA-${1000 + index}',
          'productGroup': index % 2 == 0 ? 'Fren Diski' : 'Poyra',
          'status': index % 5 == 0 ? 'RET' : 'Uygun', // Some rejections
          'notes': 'Yüzey kontrolü yapıldı.',
        };
      case 'final_control':
        return {
          'id': 'FC-${1000 + index}',
          'productCode': '6312011',
          'packaged': 150 + index,
          'scrap': index % 10,
          'rework': 0,
        };
      case 'fire_kayit':
        return {
          'id': 'FR-${1000 + index}',
          'productCode': 'HM-5050',
          'quantity': (index % 3) + 1,
          'reason': 'H001 - Yüzey Hatası',
          'zone': 'D2 Hattı',
        };
      case 'rework':
        return {
          'id': 'RW-${1000 + index}',
          'productGroup': 'Fren Kampanası',
          'process': 'Çapak Alma',
          'quantity': 10 + index,
        };
      case 'giris_kalite':
        return {
          'id': 'GK-${1000 + index}',
          'irsaliyeNo': 'IRS-2026-${100 + index}',
          'tedarikci': 'Tedarikçi A.Ş.',
          'productCode': 'TR-900',
          'quantity': 100 + (index * 10),
          'description': '',
          'batchNo': 'LOT-${202400 + index}',
          'decision': index % 3 == 0 ? 'Şartlı Kabul' : 'Kabul',
        };
      case 'palet_giris':
        return {
          'id': 'PG-${1000 + index}',
          'supplier': 'Tedarikçi B.Ş.',
          'waybill': 'IRS-2026-${200 + index}',
          'humidity': '45, 48', // string representation for mock
          'fiziki': 'Kabul',
          'muhur': 'Kabul',
          'irsaliye': 'Kabul',
          'notes': 'Palet sağlam.',
        };
      case 'saf_b9':
        return {
          'id': 'SAF-${1000 + index}',
          'productCode': 'SAF-B9-GEN2',
          'duzce': 50 + index,
          'almanya': 20,
          'hurda': 1,
        };
      default:
        return {};
    }
  }

  String _getSummaryText(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'quality_approval':
        return '${data['productGroup']} - ${data['status']}';
      case 'final_control':
        return 'Paket: ${data['packaged']} | Hurda: ${data['scrap']}';
      case 'fire_kayit':
        return '${data['productCode']} - ${data['quantity']} Adet - ${data['reason']}';
      case 'rework':
        return '${data['productGroup']} - ${data['process']} (${data['quantity']})';
      case 'giris_kalite':
        return '${data['tedarikci']} - ${data['decision']}';
      case 'palet_giris':
        return '${data['supplier']} - Nem: %${data['humidity'] ?? '-'}';
      case 'saf_b9':
        return 'Düzce: ${data['duzce']} | Almanya: ${data['almanya']}';
      default:
        return 'Detay bilgisi yok';
    }
  }

  void _showDeleteDialog(String type, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        formType: type,
        recordId: data['id'] ?? 'Unknown',
        onConfirm: () {
          setState(() {
            // In real app, this would call an API to delete
            // For now, just show success message
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Kayıt silindi: ${data['id']}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _openEditDialog(String type, Map<String, dynamic> data) {
    Widget? dialog;

    switch (type) {
      case 'quality_approval':
        dialog = EditQualityApprovalDialog(data: data);
        break;
      case 'final_control':
        dialog = EditFinalControlDialog(data: data);
        break;
      case 'fire_kayit':
        dialog = EditFireKayitDialog(data: data);
        break;
      case 'rework':
        dialog = EditReworkDialog(data: data);
        break;
      case 'giris_kalite':
        dialog = EditGirisKaliteDialog(data: data);
        break;
      case 'palet_giris':
        dialog = EditPaletGirisDialog(data: data);
        break;
      case 'saf_b9':
        dialog = EditSafB9Dialog(data: data);
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
