import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../providers/master_data_provider.dart';
import '../../../../auth/presentation/providers/auth_providers.dart';


class AddUserDialog extends ConsumerStatefulWidget {
  const AddUserDialog({super.key});

  @override
  ConsumerState<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  int? _selectedPersonelId;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.userPlus,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Yeni Kullanıcı Ekle',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Personel Seçimi
                Consumer(
                  builder: (context, ref, child) {
                    final personellerAsyncValue = ref.watch(personnelListProvider);

                    return personellerAsyncValue.when(
                      data: (items) {
                        return DropdownButtonFormField<int>(
                          initialValue: _selectedPersonelId,
                          style: const TextStyle(color: AppColors.textMain),
                          dropdownColor: AppColors.surface,
                          decoration: InputDecoration(
                            labelText: 'Personel Seçimi',
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            prefixIcon: const Icon(LucideIcons.user, size: 18),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                          ),
                          items: items.map((person) {
                            return DropdownMenuItem<int>(
                              value: person.id,
                              child: Text(person.code),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPersonelId = value;
                            });
                          },
                          validator: (value) => value == null ? 'Lütfen personel seçin' : null,
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Hata: $err', style: TextStyle(color: Colors.red)),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Kullanıcı Adı
                TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.userCheck, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Kullanıcı adı gerekli'
                      : null,
                ),
                const SizedBox(height: 16),

                // Şifre
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(color: AppColors.textMain),
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.lock, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                  validator: (value) => value != null && value.length < 6
                      ? 'En az 6 karakter'
                      : null,
                ),
                const SizedBox(height: 16),

                // Yetki Seviyesi
                DropdownButtonFormField<int>(
                  initialValue: _selectedRole,
                  style: const TextStyle(color: AppColors.textMain),
                  dropdownColor: AppColors.surface,
                  decoration: InputDecoration(
                    labelText: 'Yetki Seviyesi',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.shield, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Süper Admin')),
                    DropdownMenuItem(value: 1, child: Text('Admin')),
                    DropdownMenuItem(value: 2, child: Text('Yönetici')),
                    DropdownMenuItem(value: 3, child: Text('Kullanıcı')),
                    DropdownMenuItem(value: 4, child: Text('Misafir')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
                        onPressed: _isLoading ? null : _addUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Ekle'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;
  int _selectedRole = 3; // Default to Kullanıcı

  void _addUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final authRepo = ref.read(authRepositoryProvider);
        await authRepo.register(
          kullaniciAdi: _usernameController.text,
          parola: _passwordController.text,
          hesapSeviyesi: _selectedRole.toString(),
          personelId: _selectedPersonelId,
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_usernameController.text} başarıyla eklendi'),
              backgroundColor: AppColors.duzceGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
