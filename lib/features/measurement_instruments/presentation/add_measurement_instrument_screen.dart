import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../domain/measurement_instrument.dart';

class AddMeasurementInstrumentScreen extends StatefulWidget {
  final MeasurementInstrument? instrument;

  const AddMeasurementInstrumentScreen({super.key, this.instrument});

  @override
  State<AddMeasurementInstrumentScreen> createState() =>
      _AddMeasurementInstrumentScreenState();
}

class _AddMeasurementInstrumentScreenState
    extends State<AddMeasurementInstrumentScreen> {
  final String _operatorName = 'Furkan Yılmaz';
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _nameController = TextEditingController();
  final _rangeController = TextEditingController();
  final _precisionController = TextEditingController();
  final _serialController = TextEditingController();
  final _instrumentNoController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  bool get _isEditing => widget.instrument != null;

  @override
  void initState() {
    super.initState();
    if (widget.instrument != null) {
      final inst = widget.instrument!;
      _brandController.text = inst.brand;
      _nameController.text = inst.name;
      _rangeController.text = inst.measurementRange;
      _precisionController.text = inst.precision;
      _serialController.text = inst.serialNumber;
      _instrumentNoController.text = inst.instrumentNumber;
      _selectedDate = inst.calibrationValidDate;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _nameController.dispose();
    _rangeController.dispose();
    _precisionController.dispose();
    _serialController.dispose();
    _instrumentNoController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveInstrument() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen kalibrasyon tarihi seçiniz'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ölçü aleti kaydedildi'),
          backgroundColor: AppColors.duzceGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              SidebarNavigation(
                selectedIndex: 1,
                onItemSelected: (index) {
                  if (index == 0) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (index == 1) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } else if (index == 3) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShiftNotesScreen(),
                      ),
                    );
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
                      Container(
                        height: 72,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
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
                                  color: AppColors.surfaceLight,
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
                            Text(
                              _isEditing
                                  ? 'Ölçü Aleti Düzenle'
                                  : 'Yeni Ölçü Aleti Ekle',
                              style: TextStyle(
                                color: AppColors.textMain,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Image.asset('assets/images/logo.png', height: 40),
                          ],
                        ),
                      ),
                      // Form Content
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 32, top: 16),
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
                                    Text(
                                      'Ölçü Aleti Bilgileri',
                                      style: TextStyle(
                                        color: AppColors.textMain,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInputField(
                                            label: 'Marka',
                                            controller: _brandController,
                                            icon: LucideIcons.tag,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildInputField(
                                            label: 'Ölçü Aleti Adı',
                                            controller: _nameController,
                                            icon: LucideIcons.info,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInputField(
                                            label: 'Ölçüm Aralığı',
                                            controller: _rangeController,
                                            icon: LucideIcons.ruler,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildInputField(
                                            label: 'Hassasiyet',
                                            controller: _precisionController,
                                            icon: LucideIcons.activity,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInputField(
                                            label: 'Seri No',
                                            controller: _serialController,
                                            icon: LucideIcons.hash,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildInputField(
                                            label: 'Ölçü Aleti No',
                                            controller: _instrumentNoController,
                                            icon: LucideIcons.binary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Kalibrasyon Tarihi
                                    _buildDateField(),
                                    const SizedBox(height: 12),
                                    _buildInputField(
                                      label: 'Açıklama (Opsiyonel)',
                                      controller: _descriptionController,
                                      icon: LucideIcons.fileText,
                                      maxLines: 3,
                                      isRequired: false,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: _saveInstrument,
                                      icon: const Icon(
                                        LucideIcons.save,
                                        size: 18,
                                      ),
                                      label: const Text('KAYDET'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.duzceGreen,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
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

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kalibrasyon Tarihi',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null
                      ? 'Tarih seçiniz'
                      : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                  style: TextStyle(
                    color: _selectedDate == null
                        ? AppColors.textSecondary
                        : AppColors.textMain,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.textMain, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
            filled: true,
            fillColor: AppColors.surfaceLight.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return '$label zorunlu';
            }
            return null;
          },
        ),
      ],
    );
  }
}
