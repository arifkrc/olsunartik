import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../domain/measurement_instrument.dart';
import 'add_measurement_instrument_screen.dart';

class MeasurementInstrumentListScreen extends StatefulWidget {
  const MeasurementInstrumentListScreen({super.key});

  @override
  State<MeasurementInstrumentListScreen> createState() =>
      _MeasurementInstrumentListScreenState();
}

class _MeasurementInstrumentListScreenState
    extends State<MeasurementInstrumentListScreen> {
  final String _operatorName = 'Furkan Yılmaz';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data
  final List<MeasurementInstrument> _instruments = [
    MeasurementInstrument(
      id: '1',
      brand: 'Mitutoyo',
      name: 'Kumpas',
      measurementRange: '0-150mm',
      precision: '0.01mm',
      serialNumber: 'SN123456',
      instrumentNumber: 'KC-01',
      calibrationValidDate: DateTime.now().add(const Duration(days: 30)),
    ),
    MeasurementInstrument(
      id: '2',
      brand: 'Mitutoyo',
      name: 'Mikrometre',
      measurementRange: '0-25mm',
      precision: '0.001mm',
      serialNumber: 'SN789012',
      instrumentNumber: 'MK-01',
      calibrationValidDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<MeasurementInstrument> get _filteredInstruments {
    if (_searchQuery.isEmpty) return _instruments;
    final query = _searchQuery.toLowerCase();
    return _instruments.where((instrument) {
      return instrument.name.toLowerCase().contains(query) ||
          instrument.brand.toLowerCase().contains(query) ||
          instrument.instrumentNumber.toLowerCase().contains(query) ||
          instrument.serialNumber.toLowerCase().contains(query) ||
          instrument.measurementRange.toLowerCase().contains(query) ||
          instrument.precision.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                              'Ölçü Aleti Durum Listesi',
                              style: TextStyle(
                                color: AppColors.textMain,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            // Add Button
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AddMeasurementInstrumentScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.plus,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Yeni Ekle',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Search Section
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.glassBorder,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ölçü Aleti Ara',
                                        style: TextStyle(
                                          color: AppColors.textMain,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _searchController,
                                        onChanged: (value) => setState(
                                          () => _searchQuery = value,
                                        ),
                                        style: TextStyle(
                                          color: AppColors.textMain,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Ad, No, Seri, Marka...',
                                          hintStyle: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                          prefixIcon: Icon(
                                            LucideIcons.search,
                                            color: AppColors.textSecondary,
                                          ),
                                          suffixIcon: _searchQuery.isNotEmpty
                                              ? IconButton(
                                                  icon: Icon(
                                                    LucideIcons.x,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    setState(
                                                      () => _searchQuery = '',
                                                    );
                                                  },
                                                )
                                              : null,
                                          filled: true,
                                          fillColor: AppColors.surfaceLight
                                              .withValues(alpha: 0.5),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Instruments List
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.glassBorder,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.ruler,
                                            color: AppColors.textSecondary,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Ölçü Aletleri (${_filteredInstruments.length})',
                                            style: TextStyle(
                                              color: AppColors.textMain,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      if (_filteredInstruments.isEmpty)
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(32),
                                            child: Text(
                                              'Ölçü aleti bulunamadı',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        ...(_filteredInstruments.map(
                                          (instrument) =>
                                              _buildInstrumentCard(instrument),
                                        )),
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

  Widget _buildInstrumentCard(MeasurementInstrument instrument) {
    final isValid = instrument.isCalibrationValid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? AppColors.duzceGreen.withValues(alpha: 0.5)
              : AppColors.error.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${instrument.name} (${instrument.instrumentNumber})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      instrument.brand,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isValid
                      ? AppColors.duzceGreen.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isValid
                          ? LucideIcons.checkCircle
                          : LucideIcons.alertCircle,
                      size: 14,
                      color: isValid ? AppColors.duzceGreen : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isValid ? 'Geçerli' : 'Süresi Dolmuş',
                      style: TextStyle(
                        color: isValid ? AppColors.duzceGreen : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddMeasurementInstrumentScreen(
                        instrument: instrument,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    LucideIcons.edit2,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          _buildDetailRow('Ölçüm Aralığı:', instrument.measurementRange),
          const SizedBox(height: 6),
          _buildDetailRow('Hassasiyet:', instrument.precision),
          const SizedBox(height: 6),
          _buildDetailRow('Seri No:', instrument.serialNumber),
          const SizedBox(height: 6),
          _buildDetailRow(
            'Kalibrasyon Tarihi:',
            '${instrument.calibrationValidDate.day}.${instrument.calibrationValidDate.month}.${instrument.calibrationValidDate.year}',
            valueColor: isValid ? null : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? AppColors.textMain,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
