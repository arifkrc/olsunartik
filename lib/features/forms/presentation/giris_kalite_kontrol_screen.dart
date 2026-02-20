import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/forms/product_info_card.dart';
import '../../../core/widgets/forms/batch_number_picker.dart';
import '../../../core/widgets/forms/input_field_widget.dart';
import '../../../core/widgets/forms/quantity_field_widget.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';

class GirisKaliteKontrolScreen extends StatefulWidget {
  final DateTime? initialDate;
  const GirisKaliteKontrolScreen({super.key, this.initialDate});

  @override
  State<GirisKaliteKontrolScreen> createState() =>
      _GirisKaliteKontrolScreenState();
}

class _GirisKaliteKontrolScreenState extends State<GirisKaliteKontrolScreen> {
  // Form Controllers
  final _supplierController = TextEditingController();
  final _invoiceNoController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productTypeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _aciklamaController = TextEditingController();

  // Batch number from BatchNumberPicker
  // ignore: unused_field
  String _batchNo = '';

  // State
  String? _selectedStatus; // Kabul, Red, Şartlı Kabul
  final List<String> _statusOptions = ['Kabul', 'Red', 'Şartlı Kabul'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _invoiceNoController.dispose();
    _productCodeController.dispose();
    _productNameController.dispose();
    _productTypeController.dispose();
    _quantityController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    // Validation
    if (_supplierController.text.isEmpty ||
        _productCodeController.text.isEmpty ||
        _productNameController.text.isEmpty ||
        _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen gerekli alanları doldurun'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Success Simulation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Giriş Kalite Kontrol kaydı oluşturuldu'),
        backgroundColor: AppColors.duzceGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    // Reset Form
    setState(() {
      _supplierController.clear();
      _invoiceNoController.clear();
      _productCodeController.clear();
      _productNameController.clear();
      _productTypeController.clear();
      _quantityController.text = '1';
      _aciklamaController.clear();
      _selectedStatus = null;
      // Keep Operator and date/batch info
    });
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
                  image: AssetImage('assets/images/frenbu_bg.jpg'),
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
                selectedIndex: 1,
                onItemSelected: (index) {
                  if (index == 0) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (index == 3) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShiftNotesScreen(),
                      ),
                    );
                  } else if (index == 1) {
                    Navigator.of(context).pop();
                  }
                },
                operatorInitial: 'O',
                onLogout: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
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
                                  'Giriş Kalite Kontrol',
                                  style: TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Malzeme/Hammadde giriş kontrolleri',
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
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildSectionTitle('Giriş Bilgileri'),
                                const SizedBox(height: 16),

                                // Tedarikçi, İrsaliye
                                Row(
                                  children: [
                                    Expanded(
                                      child: InputFieldWidget(
                                        label: 'Tedarikçi Firma',
                                        controller: _supplierController,
                                        icon: LucideIcons.truck,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: InputFieldWidget(
                                        label: 'İrsaliye / Fatura No',
                                        controller: _invoiceNoController,
                                        icon: LucideIcons.fileText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Ürün Bilgisi
                                ProductInfoCard(
                                  productCodeController: _productCodeController,
                                  productName: _productNameController.text,
                                  productType: _productTypeController.text,
                                  onProductCodeChanged: (code) {
                                    setState(() {
                                      if (code.isEmpty) {
                                        _productNameController.clear();
                                        _productTypeController.clear();
                                      }
                                    });
                                  },
                                  onProductSelected: (product) {
                                    setState(() {
                                      _productNameController.text =
                                          product.urunAdi;
                                      _productTypeController.text =
                                          product.urunTuru;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Adet
                                QuantityFieldWidget(
                                  label: 'Gelen Miktar',
                                  controller: _quantityController,
                                ),
                                const SizedBox(height: 24),

                                _buildSectionTitle('Kontrol Detayları'),
                                const SizedBox(height: 16),

                                // Şarj No
                                BatchNumberPicker(
                                  initialDate: widget.initialDate,
                                  onBatchNoChanged: (batchNo) {
                                    setState(() => _batchNo = batchNo);
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Kontrol Sonucu (Status)
                                Text(
                                  'Kontrol Sonucu',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: _statusOptions.map((status) {
                                    return Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: _buildRadioOption(
                                          val: status,
                                          groupVal: _selectedStatus,
                                          onChanged: (val) => setState(
                                            () => _selectedStatus = val,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),

                                // Açıklama
                                InputFieldWidget(
                                  label: 'Açıklama / Notlar',
                                  controller: _aciklamaController,
                                  icon: LucideIcons.fileText,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 32),

                                // Save Button
                                ElevatedButton.icon(
                                  onPressed: _saveEntry,
                                  icon: const Icon(LucideIcons.save, size: 20),
                                  label: const Text(
                                    'KAYDET',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.duzceGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ],
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

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.duzceGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String val,
    required String? groupVal,
    required Function(String?) onChanged,
  }) {
    bool isSelected = val == groupVal;

    // Custom color logic based on status
    Color activeColor = AppColors.primary;
    if (val == 'Kabul') activeColor = AppColors.duzceGreen;
    if (val == 'Red') activeColor = AppColors.error;
    if (val == 'Şartlı Kabul') activeColor = AppColors.reworkOrange;

    return GestureDetector(
      onTap: () => onChanged(val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : AppColors.surfaceLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle : LucideIcons.circle,
              color: isSelected ? activeColor : AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              val,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
