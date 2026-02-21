import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../forms/presentation/forms_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'scrap_analysis/analysis_screen.dart';
import 'fire_search_tab.dart';
import 'final_search_tab.dart'; // Restore
import 'quality_search_tab.dart'; // Correct file name
import 'tabs/report_summary_tab.dart';
import 'tabs/report_edit_tab.dart';
import 'widgets/user_management_tab.dart';
import 'widgets/master_data_tab.dart';

import 'tabs/production_entry_admin_tab.dart'; // Import

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Hata oluştu: $error',
              style: const TextStyle(color: AppColors.error)),
        ),
      ),
      data: (user) {
        final isAdmin = user?.isAdmin ?? false;
        final operatorName = user?.kullaniciAdi ?? 'Admin';

        final tabs = <Tab>[
          const Tab(
            icon: Icon(LucideIcons.barChart2),
            text: 'Rapor Özetleri',
          ),
          const Tab(
            icon: Icon(LucideIcons.fileEdit),
            text: 'Rapor Düzenleme',
          ),
          const Tab(
            icon: Icon(LucideIcons.listPlus),
            text: 'Üretim Verisi Girişi',
          ),
          const Tab(
            icon: Icon(LucideIcons.pieChart),
            text: 'Fire Analizi',
          ),
          const Tab(
            icon: Icon(LucideIcons.search),
            text: 'Fire Ara',
          ),
          const Tab(
            icon: Icon(LucideIcons.checkCheck),
            text: 'Final Ara',
          ),
          const Tab(
            icon: Icon(LucideIcons.fileCheck),
            text: 'Kalite Onay Ara',
          ),
          if (isAdmin)
            const Tab(
              icon: Icon(LucideIcons.users),
              text: 'Kullanıcı Yönetimi',
            ),
          const Tab(
            icon: Icon(LucideIcons.database),
            text: 'Sabit Veriler',
          ),
        ];

        final views = <Widget>[
          const ReportSummaryTab(),
          const ReportEditTab(),
          const ProductionEntryAdminTab(),
          const AnalysisScreen(),
          const FireSearchTab(),
          const FinalSearchTab(),
          const QualityApprovalSearchTab(),
          if (isAdmin) const UserManagementTab(),
          const MasterDataTab(),
        ];

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
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
                      child: Container(
                          color: Colors.black.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SidebarNavigation(
                      selectedIndex: -1, // Admin panel
                      onItemSelected: (index) {
                        if (index == 0) {
                          Navigator.of(context).pop();
                        } else if (index == 1) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const FormsScreen()),
                          );
                        } else if (index == 2) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const HistoryScreen()),
                          );
                        } else if (index == 3) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ShiftNotesScreen(),
                            ),
                          );
                        } else if (index == 4) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen()),
                          );
                        }
                      },
                      operatorInitial:
                          operatorName.isNotEmpty ? operatorName[0] : 'A',
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              decoration: const BoxDecoration(
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
                                    icon: const Icon(
                                      LucideIcons.arrowLeft,
                                      color: AppColors.textMain,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    LucideIcons.shield,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Yönetici Paneli',
                                    style: TextStyle(
                                      color: AppColors.textMain,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (Theme.of(context).brightness ==
                                      Brightness.dark)
                                    Image.asset('assets/images/logo.png',
                                        height: 48)
                                  else
                                    const SizedBox(), // Or light mode logo
                                ],
                              ),
                            ),

                            // Tab Bar
                            Container(
                              color: AppColors.surface,
                              child: TabBar(
                                labelColor: AppColors.primary,
                                unselectedLabelColor: AppColors.textSecondary,
                                indicatorColor: AppColors.primary,
                                isScrollable: true,
                                tabs: tabs,
                              ),
                            ),

                            // Tab Content
                            Expanded(
                              child: TabBarView(
                                children: views,
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
          ),
        );
      },
    );
  }
}
