import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/user_management_dtos.dart';
import '../../providers/user_management_provider.dart';

class DeleteUserDialog extends ConsumerStatefulWidget {
  final KullaniciDto user;

  const DeleteUserDialog({super.key, required this.user});

  @override
  ConsumerState<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends ConsumerState<DeleteUserDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    String fullName = widget.user.personelAdi ?? widget.user.kullaniciAdi;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.trash2,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Kullanıcı Sil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.alertTriangle,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bu işlem geri alınamaz!',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(text: ''),
                        TextSpan(
                          text: fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const TextSpan(text: ' ('),
                        TextSpan(
                          text: widget.user.kullaniciAdi,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                        const TextSpan(
                          text:
                              ') kullanıcısını\nsilmek istediğinizden emin misiniz?',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppColors.border),
                    ),
                    child: const Text(
                      'İptal',
                      style: TextStyle(color: AppColors.textMain),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _deleteUser(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Sil'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context) async {
    setState(() => _isLoading = true);

    final repository = ref.read(userManagementRepositoryProvider);
    final result = await repository.deleteUser(widget.user);

    if (!context.mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      ref.invalidate(usersListProvider);
      Navigator.of(context).pop();

      String fullName = widget.user.personelAdi ?? widget.user.kullaniciAdi;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fullName silindi'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Silme işlemi hatalı'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
