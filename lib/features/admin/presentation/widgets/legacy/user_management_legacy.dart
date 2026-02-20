import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';

// Mock UserModel
class UserModel {
  final String id;
  final String username;
  final String fullName;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.isAdmin,
  });
}

class UserManagementLegacy {
  // Static helper methods or a mixin could work, but since it was just code blocks
  // in the main file, we'll keep them here as static widgets or methods
  // for reference if needed.
  //
  // However, since the goal is to CLEAN the main file, we'll just put the
  // code that WAS in the main file here, wrapped in a class.

  static Widget buildUserItem(
    BuildContext context,
    UserModel user,
    Function(UserModel) onEdit,
    Function(UserModel) onChangePassword,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: user.isAdmin
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.duzceGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                user.fullName[0].toUpperCase(),
                style: TextStyle(
                  color: user.isAdmin
                      ? AppColors.primary
                      : AppColors.duzceGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: user.isAdmin
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.duzceGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.isAdmin ? 'Admin' : 'Operatör',
                        style: TextStyle(
                          color: user.isAdmin
                              ? AppColors.primary
                              : AppColors.duzceGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Kullanıcı adı: ${user.username}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.edit,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => onEdit(user),
          ),
          IconButton(
            icon: const Icon(LucideIcons.key, color: Colors.orange, size: 20),
            onPressed: () => onChangePassword(user),
          ),
        ],
      ),
    );
  }

  static void showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Kaydı Sil',
          style: TextStyle(color: AppColors.textMain),
        ),
        content: const Text(
          'Bu kaydı silmek istediğinizden emin misiniz?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kayıt silindi (Simülasyon)'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
