import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';

// Kayıt Modeli
class _GKKEntry {
  final String id;
  final String? imagePath;
  final List<int> humidityValues;
  final String fizikiKontrol;
  final String muhurKontrol;
  final String irsaliyeKontrol;
  final String note;
  final String productName;
  final DateTime timestamp;

  _GKKEntry({
    required this.id,
    this.imagePath,
    required this.humidityValues,
    required this.fizikiKontrol,
    required this.muhurKontrol,
    required this.irsaliyeKontrol,
    required this.note,
    this.productName = '',
    required this.timestamp,
  });
}

class PaletGirisKaliteScreen extends StatefulWidget {
  final String supplierName;
  final String invoiceNo;
  final DateTime? initialDate;

  const PaletGirisKaliteScreen({
    super.key,
    this.supplierName = '',
    this.invoiceNo = '',
    this.initialDate,
  });

  @override
  State<PaletGirisKaliteScreen> createState() => _PaletGirisKaliteScreenState();
}

class _PaletGirisKaliteScreenState extends State<PaletGirisKaliteScreen> {
  final List<_GKKEntry> _entries = [];
  final ImagePicker _picker = ImagePicker();
  final String _operatorName = 'Furkan Yılmaz';

  void _showAddEntryDialog() {
    String fiziki = 'Kabul';
    String muhur = 'Kabul';
    String irsaliye = 'Kabul';
    List<int> humidityList = [];
    final humidityController = TextEditingController();
    String? pickedImagePath;
    final noteController = TextEditingController();
    final productNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Yeni Kontrol Kaydı',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.pop(context),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fotoğraf Alanı
                        GestureDetector(
                          onTap: () async {
                            final XFile? image = await _picker.pickImage(
                              source: ImageSource.camera,
                            );
                            if (image != null) {
                              setSheetState(() => pickedImagePath = image.path);
                            }
                          },
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight.withValues(
                                alpha: 0.3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                              image: pickedImagePath != null
                                  ? DecorationImage(
                                      image: kIsWeb
                                          ? NetworkImage(pickedImagePath!)
                                          : FileImage(File(pickedImagePath!))
                                                as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: pickedImagePath == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        LucideIcons.camera,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Fotoğraf Ekle',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Ürün Adı
                        TextField(
                          controller: productNameController,
                          style: const TextStyle(color: AppColors.textMain),
                          decoration: InputDecoration(
                            labelText: 'Ürün Adı',
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceLight.withValues(
                              alpha: 0.3,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              LucideIcons.tag,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Nem Kontrolü
                        const Text(
                          'Nem Ölçümleri (%)',
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: humidityController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: AppColors.textMain,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Değer giriniz (örn: 45)',
                                  hintStyle: TextStyle(
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceLight.withValues(
                                    alpha: 0.3,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                if (humidityController.text.isNotEmpty) {
                                  final val = int.tryParse(
                                    humidityController.text,
                                  );
                                  if (val != null) {
                                    setSheetState(() {
                                      humidityList.add(val);
                                      humidityController.clear();
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Ekle'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (humidityList.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: humidityList.asMap().entries.map((entry) {
                              final index = entry.key;
                              final val = entry.value;
                              return Chip(
                                label: Text(
                                  '$val%',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: AppColors.duzceGreen,
                                deleteIcon: const Icon(
                                  LucideIcons.x,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                onDeleted: () {
                                  setSheetState(() {
                                    humidityList.removeAt(index);
                                  });
                                },
                              );
                            }).toList(),
                          )
                        else
                          const Text(
                            'Henüz ölçüm eklenmedi',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Kontrol Sonuçları
                        _buildRadioGroup(
                          'Fiziki Yapı Kontrolü',
                          fiziki,
                          (val) => setSheetState(() => fiziki = val),
                        ),
                        const SizedBox(height: 16),
                        _buildRadioGroup(
                          'Mühür Kontrolü',
                          muhur,
                          (val) => setSheetState(() => muhur = val),
                        ),
                        const SizedBox(height: 16),
                        _buildRadioGroup(
                          'İrsaliye Eşleşme',
                          irsaliye,
                          (val) => setSheetState(() => irsaliye = val),
                        ),

                        const SizedBox(height: 24),
                        TextField(
                          controller: noteController,
                          style: const TextStyle(color: AppColors.textMain),
                          decoration: InputDecoration(
                            labelText: 'Açıklama (Opsiyonel)',
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceLight.withValues(
                              alpha: 0.3,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      final newEntry = _GKKEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        imagePath: pickedImagePath,
                        humidityValues: List.from(humidityList),
                        fizikiKontrol: fiziki,
                        muhurKontrol: muhur,
                        irsaliyeKontrol: irsaliye,
                        note: noteController.text,
                        productName: productNameController.text,
                        timestamp: widget.initialDate ?? DateTime.now(),
                      );
                      setState(() => _entries.add(newEntry));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kayıt eklendi'),
                          backgroundColor: AppColors.duzceGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.duzceGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'KAYDET',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioGroup(
    String title,
    String currentVal,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Kabul', 'Şartlı Kabul', 'Ret'].map((opt) {
            final isSelected = currentVal == opt;
            Color color = AppColors.textSecondary;
            if (isSelected) {
              if (opt == 'Kabul') {
                color = AppColors.duzceGreen;
              } else if (opt == 'Ret') {
                color = AppColors.error;
              } else {
                color = AppColors.reworkOrange;
              }
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(opt),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.15)
                        : AppColors.surfaceLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? color : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected ? color : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryDialog,
        backgroundColor: AppColors.duzceGreen,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Kayıt Ekle'),
      ),
      body: Stack(
        children: [
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
                    Navigator.of(context).pop();
                  }
                },
                operatorInitial: _operatorName[0].toUpperCase(),
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
                            bottom: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                LucideIcons.arrowLeft,
                                color: AppColors.textMain,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Palet Giriş Kontrol',
                                  style: TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.supplierName.isNotEmpty)
                                  Text(
                                    '${widget.supplierName} - ${widget.invoiceNo}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Past Date Warning
                      if (widget.initialDate != null)
                        Container(
                          width: double.infinity,
                          color: AppColors.reworkOrange,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 24,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.calendarClock,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'GEÇMİŞ TARİHLİ KAYIT MODU: ${widget.initialDate!.day}.${widget.initialDate!.month}.${widget.initialDate!.year}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // List Content
                      Expanded(
                        child: _entries.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.clipboardList,
                                      size: 64,
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Henüz kayıt eklenmedi',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Sağ alttaki butona tıklayarak yeni kayıt ekleyin',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(24),
                                itemCount: _entries.length,
                                itemBuilder: (context, index) {
                                  final entry = _entries[index];
                                  final humidityStr =
                                      entry.humidityValues.isNotEmpty
                                      ? entry.humidityValues.join(', ')
                                      : '-';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.glassBorder,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Image Thumbnail
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceLight,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            image: entry.imagePath != null
                                                ? DecorationImage(
                                                    image: kIsWeb
                                                        ? NetworkImage(
                                                            entry.imagePath!,
                                                          )
                                                        : FileImage(
                                                                File(
                                                                  entry
                                                                      .imagePath!,
                                                                ),
                                                              )
                                                              as ImageProvider,
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: entry.imagePath == null
                                              ? const Icon(
                                                  LucideIcons.image,
                                                  color:
                                                      AppColors.textSecondary,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),

                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Kayıt #${index + 1}',
                                                    style: const TextStyle(
                                                      color: AppColors.textMain,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      'Nem: %$humidityStr',
                                                      textAlign: TextAlign.end,
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (entry
                                                  .productName
                                                  .isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  entry.productName,
                                                  style: const TextStyle(
                                                    color: AppColors.textMain,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 4,
                                                children: [
                                                  _buildStatusChip(
                                                    'Fiziki',
                                                    entry.fizikiKontrol,
                                                  ),
                                                  _buildStatusChip(
                                                    'Mühür',
                                                    entry.muhurKontrol,
                                                  ),
                                                  _buildStatusChip(
                                                    'İrsaliye',
                                                    entry.irsaliyeKontrol,
                                                  ),
                                                ],
                                              ),
                                              if (entry.note.isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  entry.note,
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 13,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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

  Widget _buildStatusChip(String label, String status) {
    Color color = AppColors.textSecondary;
    if (status == 'Kabul') {
      color = AppColors.duzceGreen;
    } else if (status == 'Ret') {
      color = AppColors.error;
    } else {
      color = AppColors.reworkOrange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '$label: $status',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
