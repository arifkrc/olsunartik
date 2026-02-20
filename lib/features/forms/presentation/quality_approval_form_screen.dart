import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/domain/entities/product.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/forms/product_info_card.dart';
import '../../../core/widgets/forms/date_time_form_field.dart';
import '../../../core/widgets/forms/amount_button.dart';
import '../../../core/widgets/forms/custom_text_field.dart';
import '../../../core/providers/user_permission_provider.dart'; // UserPermission class
import '../../../core/providers/product_providers.dart';
import '../../../core/providers/ret_kod_providers.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../domain/entities/quality_approval_form.dart';
import '../presentation/providers/quality_approval_providers.dart';

class QualityApprovalFormScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const QualityApprovalFormScreen({super.key, this.initialDate});

  @override
  ConsumerState<QualityApprovalFormScreen> createState() =>
      _QualityApprovalFormScreenState();
}

class _QualityApprovalFormScreenState
    extends ConsumerState<QualityApprovalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _productCodeController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form State
  DateTime _selectedDateTime = DateTime.now();
  String? _productName;
  String? _productType;
  Product? _selectedProduct; // Seçilen ürün (id dahil)
  String _complianceStatus = 'Uygun';
  int? _rejectCodeId; // Backend'e gönderilecek ret kodu ID
  bool _isSubmitting = false;
  Key _productCardKey = UniqueKey(); // Autocomplete reset için

  @override
  void dispose() {
    _productCodeController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateAmount(int change) {
    int current = int.tryParse(_amountController.text) ?? 0;
    int newValue = current + change;
    if (newValue < 0) newValue = 0;
    _amountController.text = newValue.toString();
  }

  /// Formu backend'e gönderir
  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Ürün seçimi zorunlu
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen listeden bir ürün seçin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // RET seçiliyse ret kodu zorunlu
    if (_complianceStatus == 'RET' && _rejectCodeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RET durumu için ret kodu seçmelisiniz'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final form = QualityApprovalForm(
        urunId: _selectedProduct!.id!,
        adet: int.tryParse(_amountController.text) ?? 0,
        isUygun: _complianceStatus == 'Uygun',
        retKoduId: _complianceStatus == 'RET' ? _rejectCodeId : null,
        aciklama: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        islemTarihi: _selectedDateTime,
      );

      final message = await ref.read(submitQualityApprovalFormUseCaseProvider).call(form);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _productCodeController.clear();
    _amountController.clear();
    _descriptionController.clear();
    // Autocomplete iç state'ini sıfırlamak için productSearch temizlenir
    ref.read(productSearchProvider.notifier).clear();
    setState(() {
      _complianceStatus = 'Uygun';
      _rejectCodeId = null;
      _productName = null;
      _productType = null;
      _selectedProduct = null;
      _selectedDateTime = DateTime.now();
      // Autocomplete widget'ını yeniden oluştur
      _productCardKey = UniqueKey();
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    // Get current user for operator name
    final userAsync = ref.watch(currentUserProvider);
    final operatorName = userAsync.value?.fullName ?? 'Operatör';

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
              // Sidebar
              SidebarNavigation(
                selectedIndex: 1, // Formlar altındayız
                onItemSelected: (index) {
                  if (index == 0) {
                    Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst); // Home'a dön
                  } else if (index == 3) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShiftNotesScreen(),
                      ),
                    );
                  } else if (index == 1) {
                    Navigator.of(context).pop(); // Geri dön (Formlar listesine)
                  }
                },
                operatorInitial: operatorName.isNotEmpty
                    ? operatorName[0]
                    : 'O',
                onLogout: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              // Ana İçerik
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.glassBorder,
                                  ),
                                ),
                                child: const Icon(
                                  LucideIcons.arrowLeft,
                                  color: AppColors.textMain,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kalite Onay Takip Formu',
                                  style: TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Ürün kalite onayı',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Image.asset('assets/images/logo.png', height: 32),
                          ],
                        ),
                      ),

                      // Form Content
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Date and Time Field
                                     DateTimeFormField(
                                      initialDateTime: _selectedDateTime,
                                      onChanged: (newDateTime) {
                                        setState(
                                          () => _selectedDateTime = newDateTime,
                                        );
                                      },
                                      // Sadece admin ve manager tarih düzenleyebilir
                                      isEnabled: UserPermission.fromHesapSeviyesi(
                                        ref.watch(currentUserProvider).value?.hesapSeviyesi,
                                      ).canEditDate,
                                      label: 'Tarih ve Saat',
                                    ),
                                    const SizedBox(height: 16),

                                     ProductInfoCard(
                                      key: _productCardKey,
                                      productCodeController:
                                          _productCodeController,
                                      productName: _productName,
                                      productType: _productType,
                                      onProductCodeChanged: (code) {
                                        setState(() {
                                          if (code.isEmpty) {
                                            _productName = null;
                                            _productType = null;
                                            _selectedProduct = null;
                                          }
                                        });
                                      },
                                      onProductSelected: (product) {
                                        setState(() {
                                          _selectedProduct = product;
                                          _productName = product.urunAdi;
                                          _productType = product.urunTuru;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    // Status and Amount Row
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Left: Compliance Status (Flex 3)
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Uygunluk Durumu',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _buildStatusRadio(
                                                      true,
                                                      'Uygun',
                                                      AppColors.success,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: _buildStatusRadio(
                                                      false,
                                                      'RET',
                                                      AppColors.error,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Right: Amount (Flex 2)
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'Adet',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  AmountButton(
                                                    icon: LucideIcons.minus,
                                                    onTap: () =>
                                                        _updateAmount(-1),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: TextField(
                                                      controller:
                                                          _amountController,
                                                      textAlign:
                                                          TextAlign.center,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.textMain,
                                                        fontSize: 14,
                                                      ),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                      ],
                                                      decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 12,
                                                            ),
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color: AppColors
                                                                    .border,
                                                              ),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color: AppColors
                                                                    .border,
                                                              ),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color: AppColors
                                                                    .primary,
                                                                width: 2,
                                                              ),
                                                        ),
                                                        filled: true,
                                                        fillColor: AppColors
                                                            .surfaceLight,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  AmountButton(
                                                    icon: LucideIcons.plus,
                                                    onTap: () =>
                                                        _updateAmount(1),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 24),

                                     if (_complianceStatus == 'RET') ...[
                                      Builder(
                                        builder: (context) {
                                          final retKodAsync = ref.watch(retKodlariProvider);
                                          return retKodAsync.when(
                                            loading: () => const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 8),
                                              child: LinearProgressIndicator(),
                                            ),
                                            error: (err, _) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              child: Text(
                                                'Ret kodları yüklenemedi',
                                                style: const TextStyle(color: AppColors.error, fontSize: 13),
                                              ),
                                            ),
                                            data: (retKodlar) => DropdownButtonFormField<int>(
                                              initialValue: _rejectCodeId,
                                              dropdownColor: AppColors.surfaceLight,
                                              style: const TextStyle(
                                                color: AppColors.textMain,
                                                fontSize: 14,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: 'Ret Kodu',
                                                labelStyle: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                ),
                                                prefixIcon: const Icon(
                                                  LucideIcons.alertTriangle,
                                                  color: AppColors.textSecondary,
                                                  size: 18,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(color: AppColors.border),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(color: AppColors.border),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                                ),
                                                filled: true,
                                                fillColor: AppColors.surfaceLight,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                              ),
                                              items: retKodlar.map((rk) {
                                                return DropdownMenuItem<int>(
                                                  value: rk.id,
                                                  child: Text(rk.displayLabel),
                                                );
                                              }).toList(),
                                              onChanged: (selectedId) {
                                                setState(() {
                                                  _rejectCodeId = selectedId;
                                                });
                                              },
                                              validator: (_) {
                                                if (_complianceStatus == 'RET' && _rejectCodeId == null) {
                                                  return 'Ret kodu seçmelisiniz';
                                                }
                                                return null;
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                    ],


                                    CustomTextField(
                                      label: 'Açıklama',
                                      controller: _descriptionController,
                                      icon: LucideIcons.fileText,
                                      maxLines: 3,
                                    ),

                                    const SizedBox(height: 32),
                                    ElevatedButton(
                                      onPressed: _isSubmitting ? null : _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'KAYDET',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
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
  }

  Widget _buildStatusRadio(bool value, String label, Color color) {
    final isSelected = (_complianceStatus == 'Uygun') == value;

    return InkWell(
      onTap: () {
        setState(() {
          _complianceStatus = value ? 'Uygun' : 'RET';
          if (value) _rejectCodeId = null; // Uygun seçilince ret kodunu sıfırla
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surfaceLight,
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
