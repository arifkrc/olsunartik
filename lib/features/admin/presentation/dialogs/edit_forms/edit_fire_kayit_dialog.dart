import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/forms/sarj_no_picker.dart';
import '../../../providers/audit_providers.dart';
import '../../../../forms/presentation/providers/fire_kayit_providers.dart';
import '../../../providers/master_data_provider.dart';

class EditFireKayitDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const EditFireKayitDialog({super.key, required this.data});

  @override
  ConsumerState<EditFireKayitDialog> createState() => _EditFireKayitDialogState();
}

class _EditFireKayitDialogState extends ConsumerState<EditFireKayitDialog> {
  late TextEditingController _productCodeController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;

  int? _selectedRejectId;
  String _batchNo = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productCodeController = TextEditingController(
      text: widget.data['urunKodu'] ?? widget.data['productCode'] ?? '',
    );
    _quantityController = TextEditingController(
      text: (widget.data['miktar'] ?? widget.data['quantity'])?.toString() ?? '1',
    );
    _descriptionController = TextEditingController(
      text: widget.data['aciklama'] ?? widget.data['description'] ?? '',
    );
    _selectedRejectId = widget.data['retKoduId'] ?? widget.data['reasonId'];
    _batchNo = widget.data['sarjNo'] ?? widget.data['batchNo'] ?? '';
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rejectCodesAsync = ref.watch(rejectCodesProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.glassBorder),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.flame,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fire Kaydı Düzenle',
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${widget.data['id']}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Product Code
                        _buildTextField(
                          label: 'Ürün Kodu',
                          controller: _productCodeController,
                          icon: LucideIcons.box,
                        ),
                        const SizedBox(height: 12),

                        // Şarj No Picker
                        SarjNoPicker(
                          initialValue: _batchNo,
                          onChanged: (value) {
                            setState(() => _batchNo = value);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Error Reason (Reject Codes)
                        rejectCodesAsync.when(
                          data: (codes) {
                            // Ensure selected ID is still in the list or null
                            if (_selectedRejectId != null && !codes.any((c) => c.id == _selectedRejectId)) {
                               // If the current ID isn't in the list (e.g. old data), we might want to try mapping by name or just keeping it
                            }

                            return _buildDropdown(
                              label: 'Hata Nedeni',
                              value: _selectedRejectId,
                              items: codes.map((c) => DropdownMenuItem<int>(
                                value: c.id,
                                child: Text('${c.code} - ${c.description ?? ""}'),
                              )).toList(),
                              icon: LucideIcons.alertTriangle,
                              onChanged: (val) => setState(() => _selectedRejectId = val),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Text('Hata: $e', style: const TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(height: 12),

                        // Quantity
                        _buildTextField(
                          label: 'Miktar',
                          controller: _quantityController,
                          icon: LucideIcons.hash,
                        ),
                        const SizedBox(height: 12),

                        // Description
                        _buildTextField(
                          label: 'Açıklama',
                          controller: _descriptionController,
                          icon: LucideIcons.fileText,
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

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                border: Border(top: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'İptal',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveChanges,
                      icon: _isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(LucideIcons.save, size: 16),
                      label: const Text(
                        'Kaydet',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
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

  Widget _buildDropdown({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required IconData icon,
    required Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: value,
                    hint: const Text(
                      'Seçin',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceLight,
                    icon: const Icon(
                      LucideIcons.chevronDown,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                    items: items,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    if (_productCodeController.text.isEmpty || _selectedRejectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm zorunlu alanları doldurun'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final id = widget.data['id'] as int;
      final payload = {
        "id": id,
        "urunKodu": _productCodeController.text,
        "sarjNo": _batchNo,
        "retKoduIds": [_selectedRejectId],
        "miktar": int.tryParse(_quantityController.text) ?? 0,
        "aciklama": _descriptionController.text,
        "islemTarihi": DateTime.now().toIso8601String(),
      };

      await ref.read(fireKayitRepositoryProvider).updateForm(id, payload);
      
      ref.invalidate(auditStateProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fire kaydı başarıyla güncellendi (ID: $id)'),
            backgroundColor: AppColors.success,
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
