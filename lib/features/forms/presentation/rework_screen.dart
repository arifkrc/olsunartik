import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/forms/date_time_form_field.dart';
import '../../../core/widgets/forms/product_info_card.dart';
import '../../../core/widgets/forms/batch_number_picker.dart';
import '../../../core/widgets/forms/quantity_field_widget.dart';
import '../../../core/widgets/forms/input_field_widget.dart';
import '../../../core/providers/user_permission_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../domain/entities/rework_form.dart';
import 'providers/rework_providers.dart';

/// Rework kayıt modeli (UI State için)
class ReworkEntry {
  final String id; // UI'da silmek için local id
  final int urunId;
  final String productCode;
  final String batchNo;
  final int retKoduId;
  final String errorReason; // Sadece UI gösterimi için
  final String result;
  final int quantity;
  final String? description;
  final DateTime timestamp;

  ReworkEntry({
    required this.id,
    required this.urunId,
    required this.productCode,
    required this.batchNo,
    required this.retKoduId,
    required this.errorReason,
    required this.result,
    required this.quantity,
    this.description,
    required this.timestamp,
  });
}

class ReworkScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const ReworkScreen({super.key, this.initialDate});

  @override
  ConsumerState<ReworkScreen> createState() => _ReworkScreenState();
}

class _ReworkScreenState extends ConsumerState<ReworkScreen> {
  final String _operatorName = 'Furkan Yılmaz';

  bool _isLoading = false;

  // Date Time
  DateTime _selectedDateTime = DateTime.now();

  // Product Info
  int? _productId;
  String? _productName;
  String? _productType;

  // Kayıtlar listesi
  final List<ReworkEntry> _entries = [];

  // Controllers
  final _productCodeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _aciklamaController = TextEditingController();

  // Batch number from BatchNumberPicker
  String _batchNo = '';
  Key _batchNumberPickerKey = UniqueKey();

  // Dropdown değerleri
  String? _selectedErrorReason;
  String? _selectedResult;

  // Dropdown seçenekleri ve Statik MAP
  final Map<String, int> _errorReasonToIdMap = {
    'İç Çap Hatası': 1,
    'Dış Çap Hatası': 2,
    'Profil Hatası': 3,
    'Yüzey Kalitesi': 4,
    'Çapak': 5,
    'Darbe/Çizik': 6,
    'Boyut Hatası': 7,
    'Montaj Uyumsuzluğu': 8,
    'Diğer': 9,
  };

  List<String> get _errorReasons => _errorReasonToIdMap.keys.toList();

  final List<String> _results = ['Tamir Edildi', 'Hurda', 'İade', 'Beklemede'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _quantityController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  void _addEntry() {
    if (_productCodeController.text.isEmpty ||
        _productId == null ||
        _selectedErrorReason == null ||
        _selectedResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir ürün seçin ve tüm alanları doldurun'),
          backgroundColor: AppColors.reworkOrange,
        ),
      );
      return;
    }

    final int retId = _errorReasonToIdMap[_selectedErrorReason] ?? 9;

    setState(() {
      _entries.insert(
        0,
        ReworkEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          urunId: _productId!,
          productCode: _productCodeController.text,
          batchNo: _batchNo,
          retKoduId: retId,
          errorReason: _selectedErrorReason!,
          result: _selectedResult!,
          quantity: int.tryParse(_quantityController.text) ?? 1,
          description: _aciklamaController.text.isNotEmpty
              ? _aciklamaController.text
              : null,
          timestamp: widget.initialDate ?? DateTime.now(),
        ),
      );
      _quantityController.text = '1';
      _selectedErrorReason = null;
      _selectedResult = null;
      _aciklamaController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Kayıt eklendi'),
        backgroundColor: AppColors.duzceGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeEntry(String id) {
    setState(() {
      _entries.removeWhere((e) => e.id == id);
    });
  }

  Future<void> _saveAll() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kaydedilecek giriş yok'),
          backgroundColor: AppColors.reworkOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. DTO'ya dönüştür
      final formsToSubmit = _entries.map((e) {
        return ReworkForm(
          urunId: e.urunId,
          adet: e.quantity,
          retKoduId: e.retKoduId,
          sarjNo: e.batchNo,
          sonuc: e.result,
        );
      }).toList();

      // 2. Provider'ı çağır
      final useCase = ref.read(submitReworkFormUseCaseProvider);
      await useCase.call(formsToSubmit);

      // 3. Başarılı ise temizle
      if (mounted) {
        setState(() {
          _entries.clear();
          _productCodeController.clear();
          _productId = null;
          _productName = null;
          _productType = null;
          _quantityController.text = '1';
          _aciklamaController.clear();
          _selectedErrorReason = null;
          _selectedResult = null;
          _batchNo = '';
          _batchNumberPickerKey = UniqueKey();
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tüm kayıtlar başarıyla kaydedildi.'),
            backgroundColor: AppColors.duzceGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata oluştu: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
                operatorInitial: _operatorName.isNotEmpty
                    ? _operatorName[0]
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
                                  'Rework Kayıt Ekranı',
                                  style: TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Rework işlem kayıtları',
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Giriş Formu
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.glassBorder,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Yeni Rework Kaydı',
                                        style: TextStyle(
                                          color: AppColors.textMain,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Date and Time Field
                                      DateTimeFormField(
                                        initialDateTime: _selectedDateTime,
                                        onChanged: (newDateTime) {
                                          setState(
                                            () =>
                                                _selectedDateTime = newDateTime,
                                          );
                                        },
                                        isEnabled: ref
                                            .watch(
                                              userPermissionProvider.notifier,
                                            )
                                            .canEditForms(),
                                        label: 'Tarih ve Saat',
                                      ),
                                      const SizedBox(height: 12),

                                      // Product Info Card
                                      ProductInfoCard(
                                        productCodeController:
                                            _productCodeController,
                                        productName: _productName,
                                        productType: _productType,
                                        onProductCodeChanged: (code) {
                                          setState(() {
                                            if (code.isEmpty) {
                                              _productId = null;
                                              _productName = null;
                                              _productType = null;
                                            }
                                          });
                                        },
                                        onProductSelected: (product) {
                                          setState(() {
                                            _productId = product.id;
                                            _productName = product.urunAdi;
                                            _productType = product.urunTuru;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 12),

                                      // Adet
                                      Row(
                                        children: [
                                          Expanded(
                                            child: QuantityFieldWidget(
                                              label: 'Adet',
                                              controller: _quantityController,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: BatchNumberPicker(
                                              key: _batchNumberPickerKey,
                                              onBatchNoChanged: (batchNo) {
                                                setState(
                                                  () => _batchNo = batchNo,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Hata Nedeni, Sonuç
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildDropdown(
                                              label: 'Hata Nedeni',
                                              value: _selectedErrorReason,
                                              items: _errorReasons,
                                              icon: LucideIcons.alertCircle,
                                              onChanged: (val) => setState(
                                                () =>
                                                    _selectedErrorReason = val,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildDropdown(
                                              label: 'Sonuç',
                                              value: _selectedResult,
                                              items: _results,
                                              icon: LucideIcons.checkCircle,
                                              onChanged: (val) => setState(
                                                () => _selectedResult = val,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Açıklama
                                      InputFieldWidget(
                                        label: 'Açıklama',
                                        controller: _aciklamaController,
                                        icon: LucideIcons.fileText,
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 16),

                                      // Add Button
                                      ElevatedButton.icon(
                                        onPressed: _addEntry,
                                        icon: const Icon(
                                          LucideIcons.plus,
                                          size: 18,
                                        ),
                                        label: const Text('KAYIT EKLE'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.reworkOrange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Eklenen Kayıtlar
                                if (_entries.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.glassBorder,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              LucideIcons.clipboardList,
                                              color: AppColors.textSecondary,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Eklenen Kayıtlar (${_entries.length})',
                                              style: TextStyle(
                                                color: AppColors.textMain,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ...(_entries.map(
                                          (entry) => _buildEntryCard(entry),
                                        )),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _isLoading ? null : _saveAll,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.duzceGreen,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      LucideIcons.save,
                                                      size: 18,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('TÜMÜNÜ KAYDET'),
                                                  ],
                                                ),
                                        ),
                                      ],
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Row(
                children: [
                  Icon(icon, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Seçiniz',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              dropdownColor: AppColors.surface,
              style: TextStyle(color: AppColors.textMain, fontSize: 14),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Row(
                        children: [
                          Icon(icon, color: AppColors.textSecondary, size: 18),
                          const SizedBox(width: 8),
                          Text(item),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(ReworkEntry entry) {
    Color resultColor;
    switch (entry.result) {
      case 'Tamir Edildi':
        resultColor = AppColors.duzceGreen;
        break;
      case 'Hurda':
        resultColor = AppColors.error;
        break;
      case 'İade':
        resultColor = AppColors.almanyaBlue;
        break;
      default:
        resultColor = AppColors.reworkOrange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.productCode,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Şarj: ${entry.batchNo}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.reworkOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${entry.quantity} adet',
                        style: TextStyle(
                          color: AppColors.reworkOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      size: 14,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.errorReason,
                      style: TextStyle(color: AppColors.textMain, fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      LucideIcons.arrowRight,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: resultColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.result,
                        style: TextStyle(
                          color: resultColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (entry.description != null &&
                    entry.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    entry.description!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: () => _removeEntry(entry.id),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
