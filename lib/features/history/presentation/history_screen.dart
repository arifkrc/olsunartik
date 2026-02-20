import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../../forms/presentation/forms_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class HistoryModel {
  final String id;
  final String type; // Fire, Rework, Giriş K., Final K.
  final String title;
  final String subtitle;
  final String user;
  final DateTime date;
  final String status;

  HistoryModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.user,
    required this.date,
    required this.status,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final String _operatorName = 'Furkan Yılmaz';
  String _selectedFilter = 'Tümü';

  final List<String> _filters = [
    'Tümü',
    'Fire',
    'Rework',
    'Giriş Kalite',
    'Final Kontrol',
  ];

  // Mock Data
  final List<HistoryModel> _allHistory = [
    HistoryModel(
      id: '1',
      type: 'Fire',
      title: 'D-452 Fren Diski',
      subtitle: 'Hata: Yüzey Kalitesi - 3 Adet',
      user: 'Furkan Yılmaz',
      date: DateTime.now().subtract(const Duration(minutes: 15)),
      status: 'Onaylandı',
    ),
    HistoryModel(
      id: '2',
      type: 'Rework',
      title: 'K-120 Kaliper',
      subtitle: 'Düzeltme: Çapak Alma - 5 Adet',
      user: 'Ahmet Demir',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'Tamamlandı',
    ),
    HistoryModel(
      id: '3',
      type: 'Giriş Kalite',
      title: 'Hammadde Parti #224',
      subtitle: 'Kabul: 150 Adet',
      user: 'Mehmet Yılmaz',
      date: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'Kabul',
    ),
    HistoryModel(
      id: '4',
      type: 'Final Kontrol',
      title: 'P-900 Balata',
      subtitle: 'Palet No: P-23 - 500 Adet',
      user: 'Furkan Yılmaz',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Sevk Bekliyor',
    ),
    HistoryModel(
      id: '5',
      type: 'Fire',
      title: 'D-450 Fren Diski',
      subtitle: 'Hata: Boyut Hatası - 1 Adet',
      user: 'Ali Veli',
      date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      status: 'İnceleniyor',
    ),
  ];

  List<HistoryModel> get _filteredHistory {
    if (_selectedFilter == 'Tümü') return _allHistory;
    return _allHistory.where((item) => item.type == _selectedFilter).toList();
  }

  Color _getStatusColor(String type) {
    switch (type) {
      case 'Fire':
        return AppColors.reworkOrange;
      case 'Rework':
        return Colors.blue;
      case 'Giriş Kalite':
        return AppColors.duzceGreen;
      case 'Final Kontrol':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Fire':
        return LucideIcons.flame;
      case 'Rework':
        return LucideIcons.hammer;
      case 'Giriş Kalite':
        return LucideIcons.arrowDownCircle;
      case 'Final Kontrol':
        return LucideIcons.checkCircle;
      default:
        return LucideIcons.fileText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/frenbu_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withValues(alpha: 0.6)),
              ),
            ),
          ),
          Row(
            children: [
              SidebarNavigation(
                selectedIndex: 2, // Highlight History Icon? Or custom logic
                onItemSelected: (index) {
                  if (index == 0) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (index == 1) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const FormsScreen()),
                    );
                  } else if (index == 3) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShiftNotesScreen(),
                      ),
                    );
                  } else if (index == 4) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }
                },
                operatorInitial: _operatorName.isNotEmpty
                    ? _operatorName[0]
                    : 'O',
                onLogout: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.glassBorder,
                                  ),
                                ),
                                child: const Icon(
                                  LucideIcons.arrowLeft,
                                  color: AppColors.textMain,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Geçmiş İşlemler',
                                  style: TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Sistemdeki tüm kayıtların geçmişi',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.search,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ara...',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: _filters.map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: isSelected,
                                label: Text(filter),
                                onSelected: (bool selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                                backgroundColor: AppColors.surface,
                                selectedColor: AppColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                                checkmarkColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                showCheckmark: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _filteredHistory.length,
                          itemBuilder: (context, index) {
                            final item = _filteredHistory[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        item.type,
                                      ).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getTypeIcon(item.type),
                                      color: _getStatusColor(item.type),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              item.title,
                                              style: TextStyle(
                                                color: AppColors.textMain,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceLight,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                item.type,
                                                style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.subtitle,
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              LucideIcons.user,
                                              size: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.user,
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              LucideIcons.clock,
                                              size: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
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
                          },
                        ),
                      ),
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
}
