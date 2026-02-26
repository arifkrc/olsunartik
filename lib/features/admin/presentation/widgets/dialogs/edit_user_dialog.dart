import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/user_management_dtos.dart';
import '../../providers/user_management_provider.dart';

class EditUserDialog extends ConsumerStatefulWidget {
  final KullaniciDto user;

  const EditUserDialog({super.key, required this.user});

  @override
  ConsumerState<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends ConsumerState<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late int _selectedPermission;
  late bool _isActive;
  
  final _kullaniciAdiController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _yakinPhoneController = TextEditingController();
  final _yakinlikController = TextEditingController();
  DateTime? _selectedDate;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPermission = widget.user.hesapSeviyesi;
    _isActive = widget.user.isActive;
    
    _kullaniciAdiController.text = widget.user.kullaniciAdi;
    _fullNameController.text = widget.user.personelAdi ?? '';
    _phoneController.text = widget.user.telefonNo ?? '';
    _yakinPhoneController.text = widget.user.yakinTelefonNo ?? '';
    _yakinlikController.text = widget.user.yakinlikDerecesi ?? '';
    _selectedDate = widget.user.dogumTarihi;
  }

  @override
  void dispose() {
    _kullaniciAdiController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _yakinPhoneController.dispose();
    _yakinlikController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
                        LucideIcons.edit2,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Kullanıcı Düzenle',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // -- ACCOUNT SECTION --
                const Text('Hesap Bilgileri', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),

                // Username
                TextFormField(
                  controller: _kullaniciAdiController,
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.atSign, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Permission
                DropdownButtonFormField<int>(
                  initialValue: _selectedPermission,
                  dropdownColor: AppColors.surface,
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: InputDecoration(
                    labelText: 'Yetki Seviyesi',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.shield, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  items: permissionLevels.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPermission = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // IsActive
                SwitchListTile(
                  title: const Text('Aktif Hesap', style: TextStyle(color: AppColors.textMain)),
                  subtitle: const Text('Kullanıcının sisteme giriş yapabilmesini sağlar.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  value: _isActive,
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (bool value) {
                    setState(() => _isActive = value);
                  },
                ),
                const SizedBox(height: 24),

                // -- PERSONNEL SECTION --
                const Text('Personel Bilgileri', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(color: AppColors.border),
                const SizedBox(height: 12),

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  style: const TextStyle(color: AppColors.textMain),
                  validator: (value) => (value == null || value.isEmpty) ? 'Ad soyad zorunludur' : null,
                  decoration: InputDecoration(
                    labelText: 'Ad Soyad',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.user, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Telefon
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: AppColors.textMain),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefon Numarası',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.phone, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Doğum Tarihi Picker
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? 'Doğum Tarihi Seçiniz'
                              : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                          style: TextStyle(
                            color: _selectedDate == null
                                ? AppColors.textSecondary
                                : AppColors.textMain,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Yakın Telefon No
                TextFormField(
                  controller: _yakinPhoneController,
                  style: const TextStyle(color: AppColors.textMain),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Yakın Telefon Numarası',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.phoneCall, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Yakınlık Derecesi
                TextFormField(
                  controller: _yakinlikController,
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: InputDecoration(
                    labelText: 'Yakınlık Derecesi',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.heart, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
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
                          side: const BorderSide(color: AppColors.border),
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
                        onPressed: _isLoading ? null : _updateUser,
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
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Güncelle'),
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

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final repository = ref.read(userManagementRepositoryProvider);

    // 1. Update Account
    final accountRequest = UpdateAccountRequest(
      kullaniciAdi: _kullaniciAdiController.text,
      hesapSeviyesi: _selectedPermission,
      isActive: _isActive,
      personelId: widget.user.personelId,
    );

    // 2. Update Personnel
    final personnelRequest = UpdatePersonnelRequest(
      adSoyad: _fullNameController.text,
      telefonNo: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      dogumTarihi: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
      yakinTelefonNo: _yakinPhoneController.text.isNotEmpty ? _yakinPhoneController.text : null,
      yakinlikDerecesi: _yakinlikController.text.isNotEmpty ? _yakinlikController.text : null,
    );

    // Run both updates
    final accountResult = await repository.updateAccount(widget.user.id, accountRequest);
    
    // Personnel API may require careful chaining if account fails
    if (accountResult.success) {
      if (widget.user.personelId != null) {
        final personnelResult = await repository.updatePersonnel(widget.user.personelId!, personnelRequest);
        
        if (personnelResult.success) {
          if (!mounted) return;
          ref.invalidate(usersListProvider);
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kullanıcı ve personel bilgileri başarıyla güncellendi'),
              backgroundColor: AppColors.duzceGreen,
            ),
          );
        } else {
          _showError('Personel güncellenirken hata: ${personnelResult.message ?? 'Hata'}');
        }
      } else {
        // Only account updated
        if (!mounted) return;
        ref.invalidate(usersListProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesap bilgileri başarıyla güncellendi (Bağlı personel bulunamadı)'),
            backgroundColor: AppColors.duzceGreen,
          ),
        );
      }
    } else {
      _showError('Hesap güncellenirken hata: ${accountResult.message ?? 'Hata'}');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
