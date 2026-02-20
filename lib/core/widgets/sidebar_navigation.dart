import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String operatorInitial;
  final VoidCallback? onLogout;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.operatorInitial = 'F',
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // Daha geniş sidebar - tablet için
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        border: Border(
          right: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Logo - Büyük
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    operatorInitial,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Divider(
                color: AppColors.border,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              const SizedBox(height: 16),
              // Nav Items
              _NavItem(
                icon: LucideIcons.home,
                label: 'Ana Sayfa',
                isSelected: selectedIndex == 0,
                onTap: () => onItemSelected(0),
              ),
              _NavItem(
                icon: LucideIcons.fileText,
                label: 'Formlar',
                isSelected: selectedIndex == 1,
                onTap: () => onItemSelected(1),
              ),
              _NavItem(
                icon: LucideIcons.history,
                label: 'Geçmiş',
                isSelected: selectedIndex == 2,
                onTap: () => onItemSelected(2),
              ),
              _NavItem(
                icon: LucideIcons.calendar,
                label: 'Vardiya',
                isSelected: selectedIndex == 3,
                onTap: () => onItemSelected(3),
              ),
              const Spacer(),
              Divider(
                color: AppColors.border,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              _NavItem(
                icon: LucideIcons.user,
                label: 'Profil',
                isSelected: selectedIndex == 4,
                onTap: () => onItemSelected(4),
              ),
              _NavItem(
                icon: LucideIcons.logOut,
                label: 'Çıkış',
                isSelected: false,
                onTap: onLogout ?? () {},
                isLogout: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLogout;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isLogout
        ? AppColors.error
        : (isSelected ? Colors.white : AppColors.textSecondary);
    final textColor = isLogout
        ? AppColors.error
        : (isSelected ? Colors.white : AppColors.textSecondary);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(left: BorderSide(color: AppColors.primary, width: 4))
              : null,
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: iconColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
