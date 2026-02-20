import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../auth/presentation/login_screen.dart';
import '../../../core/widgets/premium_menu_button.dart';
import '../../chat/presentation/shift_notes_screen.dart'; // Eklendi
import 'quality_approval_form_screen.dart';
import 'saf_b9_counter_screen.dart';
import 'final_kontrol_screen.dart';
import 'giris_kalite_menu_screen.dart';
import 'rework_screen.dart';
import 'fire_kayit/fire_kayit_screen.dart';
import 'numune_screen.dart';
import '../../measurement_instruments/presentation/measurement_instruments_screen.dart';
import '../../history/presentation/history_screen.dart';

class FormsScreen extends ConsumerWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String operatorName = 'Furkan Yılmaz';

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
          // Ön Plan İçerik
          Row(
            children: [
              SidebarNavigation(
                selectedIndex: 1, // Formlar sekmesi aktif
                onItemSelected: (index) {
                  if (index == 0) {
                    Navigator.of(context).pop(); // Ana sayfaya dön
                  } else if (index == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  } else if (index == 3) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShiftNotesScreen(),
                      ),
                    );
                  }
                },
                operatorInitial: operatorName.isNotEmpty
                    ? operatorName[0]
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
                              'Formlar',
                              style: TextStyle(
                                color: AppColors.textMain,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Image.asset('assets/images/logo.png', height: 48),
                          ],
                        ),
                      ),
                      // Form Listesi (GridView)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: GridView.extent(
                            maxCrossAxisExtent: 220,
                            childAspectRatio: 0.9,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: [
                              Center(
                                child: PremiumMenuButton(
                                  icon: LucideIcons.clipboardCheck,
                                  label: 'Kalite Onay',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const QualityApprovalFormScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: PremiumMenuButton(
                                  icon: LucideIcons.fileCheck,
                                  label: 'SAF B9',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SafB9CounterScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: PremiumMenuButton(
                                  icon: LucideIcons.minusCircle,
                                  label: 'Fire Kayıt',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const FireKayitScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: PremiumMenuButton(
                                  icon: LucideIcons.checkCircle,
                                  label: 'Final Kontrol',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const FinalKontrolScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: PremiumMenuButton(
                                  icon: LucideIcons.boxes,
                                  label: 'Giriş Kalite',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const GirisKaliteMenuScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: PremiumMenuButton(
                                  icon: LucideIcons.refreshCw,
                                  label: 'Rework',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ReworkScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              Center(
                                child: PremiumMenuButton(
                                  icon: LucideIcons.ruler,
                                  label: 'Ölçü Aleti',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MeasurementInstrumentsScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: PremiumMenuButton(
                                  icon: LucideIcons.fileBarChart,
                                  label: 'Numune',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const NumuneScreen(),
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
