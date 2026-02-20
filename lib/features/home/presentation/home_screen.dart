import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../forms/presentation/forms_screen.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../../core/widgets/premium_menu_button.dart';
import '../../admin/presentation/admin_panel_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import 'about_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedNavIndex = 0;
  final String _operatorName = 'Furkan Yılmaz';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBirthday();
    });
  }

  void _checkBirthday() {
    final userAsync = ref.read(currentUserProvider);
    userAsync.whenData((user) {
      if (user?.birthDate != null) {
        final now = DateTime.now();
        // Yıl kontrolü olmadan sadece ay ve gün kontrolü
        if (user!.birthDate!.month == now.month &&
            user.birthDate!.day == now.day) {
          _showBirthdayCelebration(user.fullName);
        }
      }
    });
  }

  void _showBirthdayCelebration(String name) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.partyPopper, size: 60, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'İyi ki Doğdun!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mutlu yıllar $name! 🎂',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textMain),
            ),
            const SizedBox(height: 8),
            Text(
              'Frenbu ailesi olarak doğum gününü kutlarız.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Teşekkürler'),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavItemSelected(int index) {
    if (index == 3) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ShiftNotesScreen()));
      return;
    }
    setState(() => _selectedNavIndex = index);
    if (index == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const FormsScreen()))
          .then((_) => setState(() => _selectedNavIndex = 0));
    } else if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const HistoryScreen()))
          .then((_) => setState(() => _selectedNavIndex = 0));
    } else if (index == 4) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ProfileScreen()))
          .then((_) => setState(() => _selectedNavIndex = 0));
    }
  }

  // Yılın kaçıncı günü
  int _getDayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  // Hafta numarası
  int _getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(
      "${date.difference(DateTime(date.year, 1, 1)).inDays + 1}",
    );
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  // Türkçe gün adı
  String _getTurkishDayName(int weekday) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return days[weekday - 1];
  }

  // Türkçe ay adı
  String _getTurkishMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Arka Plan Görseli
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withValues(alpha: 0.6)),
              ),
            ),
          ),
          // İçerik
          Row(
            children: [
              SidebarNavigation(
                selectedIndex: _selectedNavIndex,
                onItemSelected: _onNavItemSelected,
                operatorInitial: _operatorName.isNotEmpty
                    ? _operatorName[0].toUpperCase()
                    : 'O',
                onLogout: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header - Sadeleştirilmiş
                      Container(
                        height: 72,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Kalite Kontrol Sistemi',
                              style: TextStyle(
                                color: AppColors.textMain,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(
                                LucideIcons.info,
                                color: AppColors.textMain,
                                size: 24,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AboutScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Image.asset('assets/images/logo.png', height: 48),
                          ],
                        ),
                      ),

                      // Ana içerik
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Büyük Hoşgeldin yazısı
                              Text(
                                'Hoşgeldin, Operatör',
                                style: TextStyle(
                                  color: AppColors.textMain,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Yapmak istediğiniz işlemi seçiniz',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Ana Menü - 4 Premium Buton
                              Expanded(
                                child: Center(
                                  child: Wrap(
                                    spacing: 20,
                                    runSpacing: 20,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      PremiumMenuButton(
                                        icon: LucideIcons.clipboardCheck,
                                        label: 'Formlar',
                                        onTap: () => _onNavItemSelected(1),
                                      ),
                                      PremiumMenuButton(
                                        icon: LucideIcons.history,
                                        label: 'Geçmiş',
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const HistoryScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      PremiumMenuButton(
                                        icon: LucideIcons.fileText,
                                        label: 'Vardiya Notları',
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ShiftNotesScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      PremiumMenuButton(
                                        icon: LucideIcons.shield,
                                        label: 'Yönetici',
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const AdminPanelScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Alt Widgetlar - Eşit Boyutlarda
                              // Alt Widgetlar - Eşit Boyutlarda (Sıralama: Takvim, Saat, Info)
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Sol - Mini Takvim
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: AppColors.glassBorder,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Ay başlığı
                                            Text(
                                              _getTurkishMonthName(
                                                now.month,
                                              ).toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textMain,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            // Takvim
                                            _buildMiniCalendar(now),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Orta - Saat ve Tarih
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: AppColors.glassBorder,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Büyük Saat
                                              Text(
                                                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                                                style: TextStyle(
                                                  fontSize: 56,
                                                  fontWeight: FontWeight.w300,
                                                  color: AppColors.primary,
                                                  letterSpacing: -2,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Gün ve Tarih
                                              Text(
                                                '${_getTurkishDayName(now.weekday)}, ${now.day} ${_getTurkishMonthName(now.month)}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Sağ - Info Chips
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        children: [
                                          _InfoChipBox(
                                            icon: LucideIcons.sun,
                                            label:
                                                'Bugün yılın ${_getDayOfYear(now)}. günü',
                                            subtitle: 'Yılın günü',
                                          ),
                                          const SizedBox(height: 12),
                                          _InfoChipBox(
                                            icon: LucideIcons.calendarDays,
                                            label:
                                                '${_getWeekNumber(now)}. Hafta',
                                            subtitle: 'Hafta sayısı',
                                          ),
                                          const SizedBox(height: 12),
                                          _InfoChipBox(
                                            icon: LucideIcons.timer,
                                            label:
                                                '${365 - _getDayOfYear(now)} gün',
                                            subtitle: 'Yıl sonuna kalan',
                                          ),
                                        ],
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Info Chip Box widget'ı - Ayrı kutu tasarımı
class _InfoChipBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _InfoChipBox({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Mini Takvim Builder (State'de kullanılmak üzere extension)
extension _MiniCalendarBuilder on _HomeScreenState {
  Widget _buildMiniCalendar(DateTime now) {
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday;

    List<Widget> rows = [];
    List<Widget> currentRow = [];

    // Başlık Satırı
    rows.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: ['P', 'S', 'Ç', 'P', 'C', 'C', 'P']
              .map(
                (day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );

    // Boş günler (ayın başlamadığı günler)
    for (int i = 1; i < startWeekday; i++) {
      currentRow.add(const Expanded(child: SizedBox()));
    }

    // Ayın günleri
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final isToday = day == now.day;

      currentRow.add(
        Expanded(
          child: Center(
            child: Container(
              width: 28,
              height: 28,
              decoration: isToday
                  ? BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    color: isToday ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      if (currentRow.length == 7) {
        rows.add(Row(children: currentRow));
        currentRow = [];
      }
    }

    // Son satır varsa ekle ve 7'ye tamamla
    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(const Expanded(child: SizedBox()));
      }
      rows.add(Row(children: currentRow));
    }

    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: row,
            ),
          )
          .toList(),
    );
  }
}
