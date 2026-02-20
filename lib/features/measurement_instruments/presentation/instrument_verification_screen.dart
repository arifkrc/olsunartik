import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../domain/measurement_instrument.dart';
import '../domain/instrument_verification.dart';

class InstrumentVerificationScreen extends StatefulWidget {
  const InstrumentVerificationScreen({super.key});

  @override
  State<InstrumentVerificationScreen> createState() =>
      _InstrumentVerificationScreenState();
}

class _InstrumentVerificationScreenState
    extends State<InstrumentVerificationScreen> {
  final String _operatorName = 'Furkan Yılmaz';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Seçilen ölçü aletleri
  final List<InstrumentVerificationEntry> _selectedEntries = [];
  // Her entry için ölçüm controller'ları: instrumentId -> List<TextEditingController>
  final Map<String, List<TextEditingController>> _measurementControllers = {};

  // Mock data - ölçü aletleri listesi
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
    MeasurementInstrument(
      id: '3',
      brand: 'Starrett',
      name: 'Cetvel',
      measurementRange: '0-300mm',
      precision: '0.5mm',
      serialNumber: 'SN345678',
      instrumentNumber: 'CT-01',
      calibrationValidDate: DateTime.now().add(const Duration(days: 60)),
    ),
    MeasurementInstrument(
      id: '4',
      brand: 'Fowler',
      name: 'Açı Ölçer',
      measurementRange: '0-360°',
      precision: '0.1°',
      serialNumber: 'SN901234',
      instrumentNumber: 'AO-01',
      calibrationValidDate: DateTime.now().add(const Duration(days: 90)),
    ),
  ];

  List<MeasurementInstrument> get _filteredInstruments {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    return _instruments.where((instrument) {
      final isSelected = _selectedEntries.any(
        (e) => e.instrument.id == instrument.id,
      );
      if (isSelected) return false;

      return instrument.name.toLowerCase().contains(query) ||
          instrument.brand.toLowerCase().contains(query) ||
          instrument.instrumentNumber.toLowerCase().contains(query) ||
          instrument.serialNumber.toLowerCase().contains(query) ||
          instrument.measurementRange.toLowerCase().contains(query) ||
          instrument.precision.toLowerCase().contains(query);
    }).toList();
  }

  void _addInstrument(MeasurementInstrument instrument) {
    setState(() {
      final entry = InstrumentVerificationEntry(instrument: instrument);
      _selectedEntries.add(entry);
      _measurementControllers[instrument.id] = List.generate(
        3,
        (_) => TextEditingController(),
      );
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _removeInstrument(String instrumentId) {
    setState(() {
      _selectedEntries.removeWhere((e) => e.instrument.id == instrumentId);
      final controllers = _measurementControllers[instrumentId];
      if (controllers != null) {
        for (var c in controllers) {
          c.dispose();
        }
      }
      _measurementControllers.remove(instrumentId);
    });
  }

  void _addMeasurement(String instrumentId) {
    setState(() {
      final entry = _selectedEntries.firstWhere(
        (e) => e.instrument.id == instrumentId,
      );
      entry.addMeasurement();
      _measurementControllers[instrumentId]?.add(TextEditingController());
    });
  }

  void _removeMeasurement(String instrumentId) {
    final controllers = _measurementControllers[instrumentId];
    if (controllers != null && controllers.length > 1) {
      setState(() {
        final entry = _selectedEntries.firstWhere(
          (e) => e.instrument.id == instrumentId,
        );
        entry.removeMeasurement(entry.measurements.length - 1);
        controllers.last.dispose();
        controllers.removeLast();
      });
    }
  }

  void _saveVerification() {
    for (var entry in _selectedEntries) {
      final controllers = _measurementControllers[entry.instrument.id];
      if (controllers != null) {
        entry.measurements = controllers.map((c) => c.text).toList();
      }
    }

    bool hasEmptyMeasurement = false;
    for (var entry in _selectedEntries) {
      if (entry.measurements.every((m) => m.isEmpty)) {
        hasEmptyMeasurement = true;
        break;
      }
    }

    if (hasEmptyMeasurement) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen her alet için en az bir ölçüm giriniz.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir ölçü aleti seçiniz.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedEntries.length} adet doğrulama kaydedildi!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      for (var controllers in _measurementControllers.values) {
        for (var c in controllers) {
          c.dispose();
        }
      }
      _measurementControllers.clear();
      _selectedEntries.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (var controllers in _measurementControllers.values) {
      for (var c in controllers) {
        c.dispose();
      }
    }
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
                              'Ölçü Aleti Doğrulama Formu',
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
                                      // Search Results
                                      if (_filteredInstruments.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          constraints: const BoxConstraints(
                                            maxHeight: 200,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceLight,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppColors.border,
                                            ),
                                          ),
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            itemCount:
                                                _filteredInstruments.length,
                                            separatorBuilder: (_, index) =>
                                                Divider(
                                                  height: 1,
                                                  color: AppColors.border,
                                                ),
                                            itemBuilder: (context, index) {
                                              final instrument =
                                                  _filteredInstruments[index];
                                              return ListTile(
                                                title: Text(
                                                  '${instrument.name} (${instrument.instrumentNumber})',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textMain,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  '${instrument.brand} • ${instrument.measurementRange}',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                trailing: IconButton(
                                                  icon: Icon(
                                                    LucideIcons.plusCircle,
                                                    color: AppColors.primary,
                                                  ),
                                                  onPressed: () =>
                                                      _addInstrument(
                                                        instrument,
                                                      ),
                                                ),
                                                onTap: () =>
                                                    _addInstrument(instrument),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Selected Instruments
                                if (_selectedEntries.isNotEmpty)
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
                                              LucideIcons.clipboardList,
                                              color: AppColors.textSecondary,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Seçilen Ölçü Aletleri (${_selectedEntries.length})',
                                              style: TextStyle(
                                                color: AppColors.textMain,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ...(_selectedEntries.map(
                                          (entry) =>
                                              _buildInstrumentCard(entry),
                                        )),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: _saveVerification,
                                          icon: const Icon(
                                            LucideIcons.save,
                                            size: 20,
                                          ),
                                          label: const Text(
                                            'KAYDET',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.duzceGreen,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                              horizontal: 32,
                                            ),
                                            minimumSize: const Size(
                                              double.infinity,
                                              56,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Empty State
                                if (_selectedEntries.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(40),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.glassBorder,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          LucideIcons.ruler,
                                          size: 48,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Doğrulama yapılacak ölçü aletlerini\narama yaparak ekleyiniz',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
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

  Widget _buildInstrumentCard(InstrumentVerificationEntry entry) {
    final instrument = entry.instrument;
    final controllers = _measurementControllers[instrument.id] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${instrument.name} (${instrument.instrumentNumber})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${instrument.brand} • ${instrument.measurementRange} • ${instrument.precision}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.minusCircle, color: AppColors.error),
                onPressed: () => _removeInstrument(instrument.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(controllers.length, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i < controllers.length - 1 ? 8 : 0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${i + 1}. Ölçüm',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: controllers[i],
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'mm',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  children: [
                    const Text('', style: TextStyle(fontSize: 11)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (controllers.length > 1)
                          InkWell(
                            onTap: () => _removeMeasurement(instrument.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(
                                LucideIcons.minus,
                                color: AppColors.error,
                                size: 16,
                              ),
                            ),
                          ),
                        if (controllers.length > 1) const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _addMeasurement(instrument.id),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              LucideIcons.plus,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
