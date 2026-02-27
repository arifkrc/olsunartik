import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import 'package:collection/collection.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../forms/presentation/forms_screen.dart';
import '../../admin/presentation/providers/master_data_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final personellerAsync = ref.watch(personnelListProvider);

    // Tarih formatı için ilk harfi büyük yapmak gerekebilir
    initializeDateFormatting('tr_TR', null);
    final dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');

    return currentUserAsync.when(
      data: (currentUser) {
        // If no user, redirect to login
        if (currentUser == null) {
          return const LoginScreen();
        }

        final operatorName = currentUser.fullName;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Arka Plan
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
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  SidebarNavigation(
                    selectedIndex: 4, // Profil sekmesi
                    onItemSelected: (index) {
                      if (index == 0) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      } else if (index == 1) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const FormsScreen(),
                          ),
                        );
                      } else if (index == 2) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      } else if (index == 3) {
                        Navigator.of(context).pushReplacement(
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
                                  'Profilim',
                                  style: TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    LucideIcons.user,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Content
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 600,
                                  ),
                                  child: Column(
                                    children: [
                                      // Profil Avatarı
                                      Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primary,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            operatorName.isNotEmpty
                                                ? operatorName[0]
                                                : 'O',
                                            style: TextStyle(
                                              fontSize: 56,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        currentUser.fullName,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textMain,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: currentUser.isAdmin
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.2,
                                                )
                                              : AppColors.duzceGreen.withValues(
                                                  alpha: 0.2,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: currentUser.isAdmin
                                                ? AppColors.primary
                                                : AppColors.duzceGreen,
                                          ),
                                        ),
                                          child: Text(
                                            currentUser.roleLabel,
                                            style: TextStyle(
                                              color: currentUser.isAdmin
                                                  ? AppColors.primary
                                                  : AppColors.duzceGreen,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                      ),
                                      const SizedBox(height: 48),

                                      // Bilgi Kartları
                                      Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          border: Border.all(
                                            color: AppColors.glassBorder,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildInfoRow(
                                              icon: LucideIcons.user,
                                              label: 'Kullanıcı Adı',
                                              value: currentUser.username,
                                            ),
                                            const Divider(
                                              height: 32,
                                              color: AppColors.border,
                                            ),
                                            personellerAsync.when(
                                              data: (personeller) {
                                                final personel = personeller.firstWhereOrNull((p) => p.id == currentUser.personelId);
                                                
                                                return Column(
                                                  children: [
                                                    _buildInfoRow(
                                                      icon: LucideIcons.badgeCheck,
                                                      label: 'Personel Sicil No / Kod',
                                                      value: personel?.code ?? '-',
                                                    ),
                                                    const Divider(
                                                      height: 32,
                                                      color: AppColors.border,
                                                    ),
                                                    _buildInfoRow(
                                                      icon: LucideIcons.phone,
                                                      label: 'Telefon Numarası',
                                                      value: personel?.description ?? '-',
                                                    ),
                                                    const Divider(
                                                      height: 32,
                                                      color: AppColors.border,
                                                    ),
                                                    _buildInfoRow(
                                                      icon: LucideIcons.calendar,
                                                      label: 'Doğum Tarihi',
                                                      value: personel?.dogumTarihi != null
                                                          ? dateFormat.format(personel!.dogumTarihi!)
                                                          : '-',
                                                    ),
                                                    const Divider(
                                                      height: 32,
                                                      color: AppColors.border,
                                                    ),
                                                    _buildInfoRow(
                                                      icon: LucideIcons.heartPulse,
                                                      label: 'Acil Durum Yakını',
                                                      value: personel?.yakinTelefonNo ?? '-',
                                                    ),
                                                    const Divider(
                                                      height: 32,
                                                      color: AppColors.border,
                                                    ),
                                                    _buildInfoRow(
                                                      icon: LucideIcons.info,
                                                      label: 'Yakınlık Derecesi',
                                                      value: personel?.yakinlikDerecesi ?? '-',
                                                    ),
                                                  ],
                                                );
                                              },
                                              loading: () => const Center(child: Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )),
                                              error: (error, stack) => _buildInfoRow(
                                                icon: LucideIcons.alertTriangle,
                                                label: 'Personel Bilgisi',
                                                value: 'Yüklenemedi',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 40),

                                      // Şifre Değiştir Butonu
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Yetkili ile iletişime geçiniz.',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(LucideIcons.lock),
                                          label: const Text('Şifre Değiştir'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.surfaceLight,
                                            foregroundColor: AppColors.textMain,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20,
                                            ),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              side: BorderSide(
                                                color: AppColors.border,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Hata: $error', style: TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
