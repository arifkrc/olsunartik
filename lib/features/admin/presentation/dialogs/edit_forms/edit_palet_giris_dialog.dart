import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';

class EditPaletGirisDialog extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditPaletGirisDialog({super.key, required this.data});

  @override
  State<EditPaletGirisDialog> createState() => _EditPaletGirisDialogState();
}

class _EditPaletGirisDialogState extends State<EditPaletGirisDialog> {
  late TextEditingController _supplierController;
  late TextEditingController _waybillController;
  late TextEditingController _notesController;

  // Nem değerleri
  List<int> _humidityValues = [];
  final TextEditingController _humidityInputController =
      TextEditingController();

  // Kontrol Kararları
  late String _fizikiKarar;
  late String _muhurKarar;
  late String _irsaliyeKarar;

  @override
  void initState() {
    super.initState();
    _supplierController = TextEditingController(
      text: widget.data['supplier'] ?? '',
    );
    _waybillController = TextEditingController(
      text: widget.data['waybill'] ?? '',
    );
    _notesController = TextEditingController(text: widget.data['notes'] ?? '');

    // Mock data might have logic for these, defaulting if not present
    _fizikiKarar = widget.data['fiziki'] ?? 'Kabul';
    _muhurKarar = widget.data['muhur'] ?? 'Kabul';
    _irsaliyeKarar = widget.data['irsaliye'] ?? 'Kabul';

    // Parse humidity if string or list
    if (widget.data['humidity'] is List) {
      _humidityValues = List<int>.from(widget.data['humidity']);
    } else if (widget.data['humidity'] is String) {
      // Try to parse "45, 50" etc
      try {
        _humidityValues = (widget.data['humidity'] as String)
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
                const Text(
                  'Palet Giriş Düzenle',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
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
              child: SingleChildScrollView(
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
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.teal,
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
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Save logic would go here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Değişiklikler kaydedildi'),
                        backgroundColor: AppColors.duzceGreen, // Green success
                      ),
                    );
                  },
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
                  child: const Text(
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
            final isSelected =
                currentVal == opt ||
                (opt == 'Şartlı' && currentVal == 'Şartlı Kabul');
            // Mock data might say 'Şartlı Kabul' but radio option is 'Şartlı' for brevity

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
                onTap: () => onChanged(opt == 'Şartlı' ? 'Şartlı Kabul' : opt),
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
}
