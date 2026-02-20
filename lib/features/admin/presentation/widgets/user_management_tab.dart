import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/user.dart';
import '../providers/user_management_provider.dart';
import 'dialogs/add_user_dialog.dart';
import 'dialogs/edit_user_dialog.dart';
import 'dialogs/change_password_dialog.dart';
import 'dialogs/delete_user_dialog.dart';

class UserManagementTab extends ConsumerStatefulWidget {
  const UserManagementTab({super.key});

  @override
  ConsumerState<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends ConsumerState<UserManagementTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userManagementProvider);
    final filteredUsers = users.where((user) {
      if (_searchQuery.isEmpty) return true;
      return user.kullaniciAdi.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (user.personelAdi?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);
    }).toList();

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.users, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Kullanıcı Yönetimi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const Spacer(),
              // Search
              Container(
                width: 300,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: const InputDecoration(
                    hintText: 'Kullanıcı ara...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(
                      LucideIcons.search,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Add button
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(context),
                icon: const Icon(LucideIcons.userPlus, size: 18),
                label: const Text('Yeni Kullanıcı'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // User list
        Expanded(
          child: filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.users,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Kullanıcı bulunamadı'
                            : 'Arama sonucu bulunamadı',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(context, user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: user.isAdmin
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.duzceGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: user.isAdmin
                      ? AppColors.primary
                      : AppColors.duzceGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPermissionColor(
                          user.hesapSeviyesi,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPermissionLabel(user.hesapSeviyesi),
                        style: TextStyle(
                          color: _getPermissionColor(user.hesapSeviyesi),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _buildInfoItem(LucideIcons.atSign, user.kullaniciAdi),
                    if (user.telefon?.isNotEmpty == true)
                      _buildInfoItem(LucideIcons.phone, user.telefon!),
                    if (user.dogumTarihi != null)
                      _buildInfoItem(
                        LucideIcons.calendar,
                        DateFormat('dd.MM.yyyy').format(user.dogumTarihi!),
                        tooltip: 'Doğum Tarihi',
                      ),
                    if (user.yakiniTelefon?.isNotEmpty == true)
                      _buildInfoItem(
                        LucideIcons.contact,
                        'Yakın: ${user.yakiniTelefon!}',
                        color: AppColors.error,
                      ),
                    _buildInfoItem(
                      LucideIcons.clock,
                      'Kayıt: ${DateFormat('dd.MM.yyyy').format(user.kayitTarihi)}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.edit2, size: 18),
                color: AppColors.primary,
                tooltip: 'Düzenle',
                onPressed: () => _showEditUserDialog(context, user),
              ),
              IconButton(
                icon: const Icon(LucideIcons.key, size: 18),
                color: AppColors.textSecondary,
                tooltip: 'Şifre Değiştir',
                onPressed: () => _showChangePasswordDialog(context, user),
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 18),
                color: AppColors.error,
                tooltip: 'Sil',
                onPressed: () => _showDeleteUserDialog(context, user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPermissionColor(String permission) {
    switch (permission) {
      case 'Admin':
        return AppColors.primary;
      case 'Manager':
        return AppColors.duzceGreen;
      case 'User':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPermissionLabel(String permission) {
    switch (permission) {
      case 'Admin':
        return 'Yönetici (Admin)';
      case 'Manager':
        return 'Yönetici (Manager)';
      case 'User':
        return 'Kullanıcı';
      default:
        return permission;
    }
  }

  Widget _buildInfoItem(
    IconData icon,
    String text, {
    Color? color,
    String? tooltip,
  }) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color ?? AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: content);
    }
    return content;
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddUserDialog());
  }

  void _showEditUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );
  }

  void _showChangePasswordDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(user: user),
    );
  }

  void _showDeleteUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => DeleteUserDialog(user: user),
    );
  }
}
