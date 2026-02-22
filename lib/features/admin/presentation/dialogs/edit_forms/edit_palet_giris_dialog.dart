import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../providers/audit_providers.dart';
import '../../../../forms/presentation/providers/palet_giris_providers.dart';

class EditPaletGirisDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const EditPaletGirisDialog({super.key, required this.data});

  @override
  ConsumerState<EditPaletGirisDialog> createState() => _EditPaletGirisDialogState();
}

class _EditPaletGirisDialogState extends ConsumerState<EditPaletGirisDialog> {
  late TextEditingController _supplierController;
  late TextEditingController _waybillController;
  late TextEditingController _productNameController;
  late TextEditingController _notesController;

  // Nem değerleri
  List<int> _humidityValues = [];
  final TextEditingController _humidityInputController =
      TextEditingController();

  // Kontrol Kararları
  late String _fizikiKarar;
  late String _muhurKarar;
  late String _irsaliyeKarar;
  bool _isLoading = false;

  int _mapStatusToInt(String status) {
    switch (status) {
      case 'Kabul':
        return 1;
      case 'Şartlı Kabul':
        return 2;
      case 'Ret':
        return 3;
      default:
        return 1;
    }
  }

  String _mapIntToStatus(int val) {
    switch (val) {
      case 1:
        return 'Kabul';
      case 2:
        return 'Şartlı Kabul';
      case 3:
        return 'Ret';
      default:
        return 'Kabul';
    }
  }

  @override
  void initState() {
    super.initState();
    _supplierController = TextEditingController(
      text: widget.data['tedarikciAdi'] ?? widget.data['supplier'] ?? '',
    );
    _waybillController = TextEditingController(
      text: widget.data['irsaliyeNo'] ?? widget.data['waybill'] ?? '',
    );
    _productNameController = TextEditingController(
      text: widget.data['urunAdi'] ?? widget.data['productName'] ?? '',
    );
    _notesController = TextEditingController(text: widget.data['aciklama'] ?? widget.data['notes'] ?? '');

    // Parse status from int or string
    final rawFiziki = widget.data['fizikiYapiKontrol'] ?? widget.data['fiziki'];
    _fizikiKarar = rawFiziki is int ? _mapIntToStatus(rawFiziki) : (rawFiziki ?? 'Kabul');

    final rawMuhur = widget.data['muhurKontrol'] ?? widget.data['muhur'];
    _muhurKarar = rawMuhur is int ? _mapIntToStatus(rawMuhur) : (rawMuhur ?? 'Kabul');

    final rawIrsaliye = widget.data['irsaliyeEslestirme'] ?? widget.data['irsaliye'];
    _irsaliyeKarar = rawIrsaliye is int ? _mapIntToStatus(rawIrsaliye) : (rawIrsaliye ?? 'Kabul');

    // Parse humidity if string or list
    final humData = widget.data['nemOlcumleri'] ?? widget.data['humidity'];
    if (humData is List) {
      _humidityValues = List<int>.from(humData);
    } else if (humData is String) {
      try {
        _humidityValues = humData
            .split(',')
            .map((e) => int.parse(e.trim()))
            .toList();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _waybillController.dispose();
    _productNameController.dispose();
    _notesController.dispose();
    _humidityInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.packageCheck,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Palet Giriş Düzenle',
                        style: TextStyle(
                          color: AppColors.textMain,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${widget.data['id']}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    LucideIcons.x,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Flexible(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Read-only info fields
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Tedarikçi Firma',
                                controller: _supplierController,
                                icon: LucideIcons.truck,
                                enabled: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                label: 'İrsaliye No',
                                controller: _waybillController,
                                icon: LucideIcons.fileText,
                                enabled: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          label: 'Ürün Adı',
                          controller: _productNameController,
                          icon: LucideIcons.box,
                        ),
                        const SizedBox(height: 16),

                        // Nem Değerleri Yönetimi
                        const Text(
                          'Nem Ölçümleri (%)',
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Değer Ekle',
                                controller: _humidityInputController,
                                icon: LucideIcons.droplets,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (_humidityInputController.text.isNotEmpty) {
                                  final val = int.tryParse(
                                    _humidityInputController.text,
                                  );
                                  if (val != null) {
                                    setState(() {
                                      _humidityValues.add(val);
                                      _humidityInputController.clear();
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Icon(LucideIcons.plus, size: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_humidityValues.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _humidityValues.asMap().entries.map((entry) {
                              return Chip(
                                label: Text(
                                  '${entry.value}%',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                                backgroundColor: Colors.teal,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                deleteIcon: const Icon(
                                  LucideIcons.x,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                onDeleted: () => setState(
                                  () => _humidityValues.removeAt(entry.key),
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 24),
                        const Divider(color: AppColors.glassBorder),
                        const SizedBox(height: 16),

                        // Kontrol Kararları (Radio Groups)
                        _buildDecisionGroup(
                          'Fiziki Yapı Kontrolü',
                          _fizikiKarar,
                          (val) => setState(() => _fizikiKarar = val),
                        ),
                        const SizedBox(height: 16),
                        _buildDecisionGroup(
                          'Mühür Kontrolü',
                          _muhurKarar,
                          (val) => setState(() => _muhurKarar = val),
                        ),
                        const SizedBox(height: 16),
                        _buildDecisionGroup(
                          'İrsaliye Eşleşme',
                          _irsaliyeKarar,
                          (val) => setState(() => _irsaliyeKarar = val),
                        ),

                        const SizedBox(height: 24),
                        _buildTextField(
                          label: 'Açıklama',
                          controller: _notesController,
                          icon: LucideIcons.stickyNote,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duzceGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text(
                        'Kaydet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (maxLines > 1) ...[
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.surfaceLight
                : AppColors.surfaceLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textMain, fontSize: 13),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionGroup(
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
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['Kabul', 'Şartlı', 'Ret'].map((opt) {
            final displayOpt = opt == 'Şartlı' ? 'Şartlı Kabul' : opt;
            final isSelected = currentVal == displayOpt;

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
                onTap: () => onChanged(displayOpt),
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

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      final id = widget.data['id'] as int;
      final payload = {
        "id": id,
        "tedarikciAdi": _supplierController.text,
        "irsaliyeNo": _waybillController.text,
        "urunAdi": _productNameController.text,
        "nemOlcumleri": _humidityValues,
        "fizikiYapiKontrol": _mapStatusToInt(_fizikiKarar),
        "muhurKontrol": _mapStatusToInt(_muhurKarar),
        "irsaliyeEslestirme": _mapStatusToInt(_irsaliyeKarar),
        "aciklama": _notesController.text,
        "fotografYolu": widget.data['fotografYolu'] ?? "",
      };

      await ref.read(paletGirisRepositoryProvider).update(id, payload);
      
      ref.invalidate(auditStateProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Palet giriş kaydı başarıyla güncellendi (ID: $id)'),
            backgroundColor: AppColors.duzceGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
