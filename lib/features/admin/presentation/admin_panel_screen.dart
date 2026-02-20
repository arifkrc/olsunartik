import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../auth/presentation/login_screen.dart';
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

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _operatorName = 'Admin';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this); // Increased length
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          Row(
            children: [
              SidebarNavigation(
                selectedIndex: -1, // Admin panel
                onItemSelected: (index) {
                  if (index == 0) {
                    Navigator.of(context).pop();
                  } else if (index == 1) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FormsScreen()),
                    );
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
                  } else if (index == 4) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }
                },
                operatorInitial: _operatorName.isNotEmpty
                    ? _operatorName[0]
                    : 'A',
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
                              icon: const Icon(
                                LucideIcons.arrowLeft,
                                color: AppColors.textMain,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
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
                            if (Theme.of(context).brightness == Brightness.dark)
                              Image.asset('assets/images/logo.png', height: 48)
                            else
                              const SizedBox(), // Or light mode logo
                          ],
                        ),
                      ),

                      // Tab Bar
                      Container(
                        color: AppColors.surface,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          isScrollable: true,
                          tabs: const [
                            Tab(
                              icon: Icon(LucideIcons.barChart2),
                              text: 'Rapor Özetleri',
                            ),
                            Tab(
                              icon: Icon(LucideIcons.fileEdit),
                              text: 'Rapor Düzenleme',
                            ),
                            Tab(
                              // Text
                              icon: Icon(LucideIcons.listPlus),
                              text: 'Üretim Verisi Girişi',
                            ),
                            Tab(
                              icon: Icon(LucideIcons.pieChart),
                              text: 'Fire Analizi',
                            ),
                            Tab(
                              icon: Icon(LucideIcons.search),
                              text: 'Fire Ara',
                            ),
                            Tab(
                              icon: Icon(LucideIcons.checkCheck),
                              text: 'Final Ara',
                            ),
                            Tab(
                              icon: Icon(LucideIcons.fileCheck),
                              text: 'Kalite Onay Ara',
                            ),
                            Tab(
                              icon: Icon(LucideIcons.users),
                              text: 'Kullanıcı Yönetimi',
                            ),
                            Tab(
                              icon: Icon(LucideIcons.database),
                              text: 'Sabit Veriler',
                            ),
                          ],
                        ),
                      ),

                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: const [
                            ReportSummaryTab(),
                            ReportEditTab(),
                            ProductionEntryAdminTab(), // Content
                            AnalysisScreen(),
                            FireSearchTab(),
                            FinalSearchTab(),
                            QualityApprovalSearchTab(),
                            UserManagementTab(),
                            MasterDataTab(),
                          ],
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
