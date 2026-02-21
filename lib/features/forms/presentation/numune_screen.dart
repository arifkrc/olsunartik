import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
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
import '../domain/entities/numune_form.dart';
import 'providers/numune_providers.dart';

/// Numune/Deneme kayıt modeli
class NumuneEntry {
  final String id;
  final int urunId;
  final String productCode;
  final String batchNo;
  final String title;
  final String? generalResult;
  final int quantity;
  final List<String> imagePaths;
  final DateTime timestamp;

  NumuneEntry({
    required this.id,
    required this.urunId,
    required this.productCode,
    required this.batchNo,
    required this.title,
    this.generalResult,
    required this.quantity,
    required this.imagePaths,
    required this.timestamp,
  });
}

class NumuneScreen extends ConsumerStatefulWidget {
  const NumuneScreen({super.key});

  @override
  ConsumerState<NumuneScreen> createState() => _NumuneScreenState();
}

class _NumuneScreenState extends ConsumerState<NumuneScreen> {
  final String _operatorName = 'Furkan Yılmaz';
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;

  // Date Time
  DateTime _selectedDateTime = DateTime.now();

  // Product Info
  int? _productId;
  String? _productName;
  String? _productType;

  // Kayıtlar listesi
  final List<NumuneEntry> _entries = [];

  // Mevcut giriş için controller'lar
  final _productCodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productTypeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _titleController = TextEditingController();
  final _generalResultController = TextEditingController();

  // Batch number from BatchNumberPicker
  String _batchNo = '';
  Key _batchNumberPickerKey = UniqueKey();

  // Seçilen görseller
  final List<String> _currentImages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _productNameController.dispose();
    _productTypeController.dispose();
    _quantityController.dispose();
    _titleController.dispose();
    _generalResultController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      setState(() => _currentImages.add(image.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() => _currentImages.add(image.path));
    }
  }

  void _removeImage(int index) {
    setState(() => _currentImages.removeAt(index));
  }

  void _addEntry() {
    if (_productCodeController.text.isEmpty || _titleController.text.isEmpty || _productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir ürün seçin, ürün kodu ve numune başlığı girin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _entries.insert(
        0,
        NumuneEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          urunId: _productId!,
          productCode: _productCodeController.text,
          batchNo: _batchNo,
          title: _titleController.text,
          generalResult: _generalResultController.text.isNotEmpty
              ? _generalResultController.text
              : null,
          quantity: int.tryParse(_quantityController.text) ?? 1,
          imagePaths: List.from(_currentImages),
          timestamp: DateTime.now(),
        ),
      );
      _quantityController.text = '1';
      _titleController.clear();
      _generalResultController.clear();
      _currentImages.clear();
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
    setState(() => _entries.removeWhere((e) => e.id == id));
  }

  Future<void> _saveAll() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kaydedilecek giriş yok'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final useCase = ref.read(submitNumuneFormUseCaseProvider);

      for (var entry in _entries) {
        final form = NumuneForm(
          urunId: entry.urunId,
          urunKodu: entry.productCode,
          urunAdi: _productName,
          urunTuru: _productType,
          adet: entry.quantity,
          sarjNo: entry.batchNo,
          numuneBasligi: entry.title,
          genelSonuc: entry.generalResult ?? '-',
          gorsel: entry.imagePaths.isNotEmpty ? entry.imagePaths.first : '', // Base64 encoding required if sending real image
        );
        await useCase.call(form);
      }

      if (mounted) {
        setState(() {
          _entries.clear();
          _productCodeController.clear();
          _productId = null;
          _productName = null;
          _productType = null;
          _quantityController.text = '1';
          _titleController.clear();
          _generalResultController.clear();
          _currentImages.clear();
          _batchNo = '';
          _batchNumberPickerKey = UniqueKey();
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tüm kayıtlar başarıyla kaydedildi'),
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
                                  'Deneme / Numune Formu',
                                  style: TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Numune ve deneme kayıtları',
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
                                        'Yeni Numune Kaydı',
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
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: QuantityFieldWidget(
                                              label: 'Adet',
                                              controller: _quantityController,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 6,
                                              ),
                                              child: BatchNumberPicker(
                                                key: _batchNumberPickerKey,
                                                onBatchNoChanged: (batchNo) {
                                                  setState(
                                                    () => _batchNo = batchNo,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Deneme/Numune Başlığı
                                      InputFieldWidget(
                                        label: 'Deneme / Numune Başlığı',
                                        controller: _titleController,
                                        icon: LucideIcons.tag,
                                      ),
                                      const SizedBox(height: 12),
                                      // Genel Sonuç
                                      InputFieldWidget(
                                        label: 'Genel Sonuç',
                                        controller: _generalResultController,
                                        icon: LucideIcons.fileText,
                                        maxLines: 3,
                                      ),
                                      const SizedBox(height: 16),
                                      // Görsel Ekleme
                                      _buildImageSection(),
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
                                              AppColors.almanyaBlue,
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Görseller',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Kamera butonu
            InkWell(
              onTap: _pickImageFromCamera,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.camera,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kamera',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Galeri butonu
            InkWell(
              onTap: _pickImageFromGallery,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.image,
                      color: AppColors.almanyaBlue,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Galeri',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Seçilen görseller
            Expanded(
              child: SizedBox(
                height: 60,
                child: _currentImages.isEmpty
                    ? Center(
                        child: Text(
                          'Görsel eklenmedi',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _currentImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.network(
                                          _currentImages[index],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_currentImages[index]),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: InkWell(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.x,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntryCard(NumuneEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: AppColors.almanyaBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${entry.quantity} adet',
                        style: TextStyle(
                          color: AppColors.almanyaBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.title,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (entry.generalResult != null &&
                    entry.generalResult!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.generalResult!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (entry.imagePaths.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.imagePaths.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: kIsWeb
                                ? Image.network(
                                    entry.imagePaths[index],
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(entry.imagePaths[index]),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        );
                      },
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
