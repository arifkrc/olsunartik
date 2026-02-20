import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/premium_menu_button.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import 'giris_kalite_kontrol_screen.dart';

import 'palet_giris_info_screen.dart';

class GirisKaliteMenuScreen extends StatelessWidget {
  const GirisKaliteMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                selectedIndex: 1,
                onItemSelected: (index) {
                  if (index == 0) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } else if (index == 1) {
                    Navigator.of(context).pop();
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
                            IconButton(
                              icon: Icon(
                                LucideIcons.arrowLeft,
                                color: AppColors.textMain,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Giriş Kalite Kontrol',
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
                      // Menü Butonları
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PremiumMenuButton(
                                  icon: LucideIcons.clipboardCheck,
                                  label: 'Giriş Kalite\nKontrol Formu',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const GirisKaliteKontrolScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 32),
                                PremiumMenuButton(
                                  icon: LucideIcons.package,
                                  label: 'Palet Giriş\nKalite Kontrol',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PaletGirisInfoScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
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
