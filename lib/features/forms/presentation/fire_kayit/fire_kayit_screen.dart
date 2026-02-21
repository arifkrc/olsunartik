import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/form_options.dart';
import '../../../../core/widgets/sidebar_navigation.dart';
import '../../../../core/widgets/forms/form_section_title.dart';
import '../../../../core/widgets/forms/date_time_form_field.dart';
import '../../../../core/widgets/forms/product_info_card.dart';
import '../../../../core/widgets/forms/custom_text_field.dart';
import '../../../../core/providers/user_permission_provider.dart';
import '../../../auth/presentation/login_screen.dart';
import '../../../chat/presentation/shift_notes_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fire_kayit_providers.dart';
import '../../data/models/fire_kayit_formu_dto.dart';
import '../../../../core/providers/ret_kod_providers.dart';
import '../../../../core/providers/lookup_providers.dart' hide retKodlariProvider;
import '../../../../core/domain/entities/tezgah.dart';
import '../../../../core/domain/entities/operasyon.dart';
import '../../../../core/domain/entities/ret_kod.dart';
import '../../../../core/widgets/forms/custom_object_dropdown.dart';

// Section Widgets
import 'widgets/machine_zone_selection.dart';
import 'widgets/error_details_section.dart';
import 'widgets/operator_autocomplete.dart';
import 'widgets/photo_upload_section.dart';
import 'widgets/quantity_input.dart';

class FireKayitScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const FireKayitScreen({super.key, this.initialDate});

  @override
  ConsumerState<FireKayitScreen> createState() => _FireKayitScreenState();
}

// Entry model for batch recording
class FireEntry {
  final int errorReasonId;
  final String errorReason;
  final int quantity;
  final String? description;
  final XFile? image;

  FireEntry({
    required this.errorReasonId,
    required this.errorReason,
    required this.quantity,
    this.description,
    this.image,
  });
}

class _FireKayitScreenState extends ConsumerState<FireKayitScreen> {
  // Form Controllers
  final _productCodeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _aciklamaController = TextEditingController();

  // Batch number from BatchNumberPicker
  String _batchNo = '';

  // State Variables
  DateTime _selectedDateTime = DateTime.now();
  int? _selectedProductId;
  String? _productName;
  String? _productType;
  Tezgah? _selectedProcessedMachine;
  Tezgah? _selectedDetectedMachine;
  String? _selectedZone;
  Operasyon? _selectedOperation;
  String _productState = 'İşlenmiş';
  RetKod? _selectedRetKod;
  String? _selectedOperator;
  XFile? _selectedImage;

  // Multi-entry list
  final List<FireEntry> _entries = [];

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

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  void _addEntry() {
    // Validation
    if (_selectedRetKod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen hata nedeni (Ret Kodu) seçin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli bir adet girin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _entries.add(
        FireEntry(
          errorReasonId: _selectedRetKod!.id,
          errorReason: '${_selectedRetKod!.kod} - ${_selectedRetKod!.aciklama}',
          quantity: quantity,
          description: _aciklamaController.text.isNotEmpty
              ? _aciklamaController.text
              : null,
          image: _selectedImage,
        ),
      );
      // Clear entry-specific fields
      _quantityController.text = '1';
      _selectedRetKod = null;
      _aciklamaController.clear();
      _selectedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kayıt eklendi'),
        backgroundColor: AppColors.duzceGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background with blur
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
              // Sidebar
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
                operatorInitial: _selectedOperator?.isNotEmpty == true
                    ? _selectedOperator![0].toUpperCase()
                    : 'O',
                onLogout: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              // Main Content
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      _buildHeader(),
                      // Form Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: _buildFormCard(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textMain,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fire Kayıt Ekranı',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Fire işlem kaydı oluşturma',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Image.asset('assets/images/logo.png', height: 32),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Info Section
          const FormSectionTitle(
            title: 'Giriş Bilgileri',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 16),
          // Date and Time Field
          DateTimeFormField(
            initialDateTime: _selectedDateTime,
            onChanged: (newDateTime) {
              setState(() => _selectedDateTime = newDateTime);
            },
            isEnabled: ref
                .watch(userPermissionProvider.notifier)
                .canEditForms(),
            label: 'Tarih ve Saat',
          ),
          const SizedBox(height: 16),

          // Product Code (full width now)
          ProductInfoCard(
            productCodeController: _productCodeController,
            productName: _productName,
            productType: _productType,
            onProductCodeChanged: (code) {
              setState(() {
                if (code.isEmpty) {
                  _selectedProductId = null;
                  _productName = null;
                  _productType = null;
                }
              });
            },
            onProductSelected: (product) {
              setState(() {
                _selectedProductId = product.id;
                _productName = product.urunAdi;
                _productType = product.urunTuru;
              });
            },
          ),
          const SizedBox(height: 16),

          // Machine & Zone & Operation & Product State (2 rows)
          Builder(builder: (context) {
            final tezgahlarAsync = ref.watch(tezgahlarProvider);
            final operasyonlarAsync = ref.watch(operasyonlarProvider);

            if (tezgahlarAsync.isLoading || operasyonlarAsync.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final machineOptions = tezgahlarAsync.value ?? [];
            final operationOptions = operasyonlarAsync.value ?? [];

            return MachineZoneSelection(
              selectedProcessedMachine: _selectedProcessedMachine,
              selectedDetectedMachine: _selectedDetectedMachine,
              selectedZone: _selectedZone,
              selectedOperation: _selectedOperation,
              machineOptions: machineOptions,
              zoneOptions: FormOptions.zones,
              operationOptions: operationOptions,
              productState: _productState,
              onProcessedMachineChanged: (val) =>
                  setState(() => _selectedProcessedMachine = val),
              onDetectedMachineChanged: (val) =>
                  setState(() => _selectedDetectedMachine = val),
              onZoneChanged: (val) => setState(() => _selectedZone = val),
              onOperationChanged: (val) =>
                  setState(() => _selectedOperation = val),
              onProductStateChanged: (val) =>
                  setState(() => _productState = val!),
            );
          }),
          const SizedBox(height: 16),

          // Şarj No + Adet (side by side)
          Row(
            children: [
              // Şarj No (60%)
              Expanded(
                flex: 6,
                child: SarjNoSection(
                  initialDate: widget.initialDate,
                  onBatchNoChanged: (batchNo) {
                    setState(() => _batchNo = batchNo);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Adet (40%) with +/- buttons
              Expanded(
                flex: 4,
                child: QuantityInput(
                  controller: _quantityController,
                  onIncrement: () {
                    final current = int.tryParse(_quantityController.text) ?? 1;
                    _quantityController.text = (current + 1).toString();
                  },
                  onDecrement: () {
                    final current = int.tryParse(_quantityController.text) ?? 1;
                    if (current > 1) {
                      _quantityController.text = (current - 1).toString();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Operatör + Hata Kodu (side by side)
          Row(
            children: [
              // Operatör (50%)
              Expanded(
                child: OperatorAutocomplete(
                  selectedOperator: _selectedOperator,
                  onOperatorChanged: (val) =>
                      setState(() => _selectedOperator = val),
                ),
              ),
              const SizedBox(width: 12),
              // Hata Kodu (50%)
              Expanded(
                child: Builder(
                  builder: (context) {
                    final retKodAsync = ref.watch(retKodlariProvider);
                    return retKodAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Ret kodları yüklenemedi',
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ),
                      data: (retKodlar) => CustomObjectDropdown<RetKod>(
                        label: 'Hata Nedeni',
                        value: _selectedRetKod,
                        items: retKodlar,
                        icon: Icons.error_outline,
                        displayStringForOption: (kod) => kod.displayLabel,
                        onChanged: (val) {
                          setState(() {
                            _selectedRetKod = val;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Açıklama
          CustomTextField(
            label: 'Açıklama (İsteğe Bağlı)',
            controller: _aciklamaController,
            icon: Icons.description_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          // Photo Upload Section
          const FormSectionTitle(
            title: 'Fotoğraf Ekle',
            icon: Icons.photo_camera_outlined,
          ),
          const SizedBox(height: 16),
          PhotoUploadSection(
            selectedImage: _selectedImage,
            onPickImage: _pickImage,
            onRemoveImage: () => setState(() => _selectedImage = null),
          ),
          const SizedBox(height: 24),

          // Add Entry Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addEntry,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('LİSTEYE EKLE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.almanyaBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),

          // Entry List Section
          if (_entries.isNotEmpty) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(
                  Icons.list_alt,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Eklenen Kayıtlar (${_entries.length})',
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._entries.asMap().entries.map((entry) {
              final index = entry.key;
              final fireEntry = entry.value;
              return _buildEntryCard(fireEntry, index);
            }),
          ],

          const SizedBox(height: 32),

          // Submit Button (only enabled if entries exist)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _entries.isNotEmpty ? _submitAllEntries : null,
              icon: const Icon(Icons.save, size: 20),
              label: Text(
                _entries.isNotEmpty
                    ? 'TÜMÜNÜ KAYDET (${_entries.length})'
                    : 'KAYIT EKLE',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _entries.isNotEmpty
                    ? AppColors.primary
                    : AppColors.border,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(FireEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.errorReason} - ${entry.quantity} adet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (entry.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (entry.image != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.image,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Fotoğraf eklendi',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeEntry(index),
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAllEntries() async {
    if (_entries.isEmpty) return;

    // Validate common fields
    if (_productCodeController.text.isEmpty ||
        _selectedProductId == null ||
        _selectedProcessedMachine == null ||
        _selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ürün, tezgah ve bölge bilgilerini doldurun'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Show Loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      // Map UI values to IDs
      final tezgahId = _selectedProcessedMachine!.id;
      final tespitEdilenTezgahId = _selectedDetectedMachine?.id ?? tezgahId;

      final bolgeId = FormOptions.zones.indexOf(_selectedZone!) + 1;
      final operasyonId = _selectedOperation?.id ?? 1;
      final tespitEdilenOperasyonId = operasyonId; // UI'da ayrı alan yoksa operasyonla aynı alınır

      final malzemeDurumuId = _productState == 'Ham' ? 1 : 2;

      // Submit each entry
      for (final entry in _entries) {
        final retKoduId = entry.errorReasonId; // Use explicit id instead of parsing mock array

        final requestDto = FireKayitRequestDto(
          islemTarihi: _selectedDateTime,
          urunId: _selectedProductId!,
          sarjNo: _batchNo.isNotEmpty ? _batchNo : null,
          tezgahId: tezgahId,
          tespitEdilenTezgahId: tespitEdilenTezgahId,
          tespitEdilenOperasyonId: tespitEdilenOperasyonId,
          malzemeDurumu: malzemeDurumuId,
          adet: entry.quantity,
          operasyonId: operasyonId,
          bolgeId: bolgeId,
          retKoduIds: [retKoduId], // List of Ids expected by JSON
          operatorAdi: _selectedOperator ?? '',
          aciklama: entry.description ?? '',
        );

        final id = await ref
            .read(createFireKayitFormUseCaseProvider)
            .call(requestDto);

        // Upload photo if exists for this entry
        if (entry.image != null) {
          await ref
              .read(fireKayitRepositoryProvider)
              .uploadPhoto(id, File(entry.image!.path));
        }
      }

      // Hide Loading
      if (mounted) Navigator.of(context).pop();

      // Success Message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_entries.length} kayıt başarıyla oluşturuldu'),
            backgroundColor: AppColors.duzceGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Reset Form - KEEP Context Fields, Clear Entry Specifics
      setState(() {
        _entries.clear();
        // _productCodeController.clear(); // KEPT
        // _productName = null; // KEPT
        // _productType = null; // KEPT
        // _selectedProcessedMachine = null; // KEPT
        // _selectedDetectedMachine = null; // KEPT (Optional context)
        // _selectedZone = null; // KEPT
        // _selectedOperation = null; // KEPT
        _quantityController.text = '1';
        _selectedRetKod = null;
        _aciklamaController.clear();
        // _selectedOperator = null; // KEPT
        _selectedImage = null;
      });
    } catch (e) {
      // Hide Loading
      if (mounted) Navigator.of(context).pop();

      // Error Message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
