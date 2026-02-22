import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/forms/sarj_no_picker.dart';
import '../../../providers/audit_providers.dart';
import '../../../providers/master_data_provider.dart';
import '../../../../forms/presentation/providers/rework_providers.dart';

class EditReworkDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const EditReworkDialog({super.key, required this.data});

  @override
  ConsumerState<EditReworkDialog> createState() => _EditReworkDialogState();
}

class _EditReworkDialogState extends ConsumerState<EditReworkDialog> {
  late TextEditingController _productCodeController;
  late TextEditingController _productNameController;
  late TextEditingController _productTypeController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;

  int? _selectedRejectCodeId;
  String? _selectedResult;
  String _batchNo = '';
  bool _isLoading = false;

  final List<String> _results = ['Tamir Edildi', 'Hurda', 'İade', 'Beklemede'];

  @override
  void initState() {
    super.initState();
    _productCodeController = TextEditingController(
      text: widget.data['urunKodu'] ?? widget.data['productCode'] ?? '',
    );
    _productNameController = TextEditingController(
      text: widget.data['urunAdi'] ?? widget.data['productName'] ?? '',
    );
    _productTypeController = TextEditingController(
      text: widget.data['urunTuru'] ?? widget.data['productType'] ?? '',
    );
    _quantityController = TextEditingController(
      text: (widget.data['adet'] ?? widget.data['quantity'] ?? 1).toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.data['aciklama'] ?? widget.data['description'] ?? '',
    );
    _selectedRejectCodeId = widget.data['retKoduId'];
    _selectedResult = widget.data['sonuc'] ?? widget.data['result'];
    _batchNo = widget.data['sarjNo'] ?? widget.data['batchNo'] ?? '';
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _productNameController.dispose();
    _productTypeController.dispose();
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
        constraints: const BoxConstraints(maxHeight: 700),
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
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.refreshCw,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rework Kaydı Düzenle',
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: 16,
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

                        // Product Name & Type (Read-only)
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Ürün Adı',
                                controller: _productNameController,
                                icon: LucideIcons.tag,
                                enabled: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                label: 'Ürün Türü',
                                controller: _productTypeController,
                                icon: LucideIcons.package,
                                enabled: false,
                              ),
                            ),
                          ],
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

                        // Error Reason & Result
                        Row(
                          children: [
                            Expanded(
                              child: rejectCodesAsync.when(
                                data: (codes) => _buildRejectCodeDropdown(
                                  label: 'Hata Nedeni',
                                  value: _selectedRejectCodeId,
                                  items: codes,
                                  onChanged: (val) => setState(() => _selectedRejectCodeId = val),
                                ),
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (e, s) => Text('Hata: $e', style: const TextStyle(color: Colors.red)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildResultDropdown(
                                label: 'Sonuç',
                                value: _selectedResult,
                                items: _results,
                                icon: LucideIcons.checkCircle,
                                onChanged: (val) =>
                                    setState(() => _selectedResult = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Quantity
                        _buildTextField(
                          label: 'Adet',
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
                      child: Text(
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
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
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
            style: TextStyle(color: AppColors.textMain, fontSize: 13),
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

  Widget _buildRejectCodeDropdown({
    required String label,
    required int? value,
    required List<MasterDataItem> items,
    required Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
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
              const Icon(LucideIcons.alertCircle, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: value,
                    hint: Text(
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
                    style: TextStyle(color: AppColors.textMain, fontSize: 13),
                    items: items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id, 
                            child: Text('${item.code} - ${item.description ?? ''}')
                          ),
                        )
                        .toList(),
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

  Widget _buildResultDropdown({
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
          style: TextStyle(
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
                  child: DropdownButton<String>(
                    value: value,
                    hint: Text(
                      'Seçin',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceLight,
                    icon: Icon(
                      LucideIcons.chevronDown,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    style: TextStyle(color: AppColors.textMain, fontSize: 13),
                    items: items
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
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
    if (_productCodeController.text.isEmpty ||
        _selectedRejectCodeId == null ||
        _selectedResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm zorunlu alanları doldurun'),
          backgroundColor: AppColors.reworkOrange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final id = widget.data['id'] as int;
      final payload = {
        "id": id,
        "urunId": widget.data['urunId'],
        "urunKodu": _productCodeController.text,
        "adet": int.tryParse(_quantityController.text) ?? 1,
        "retKoduId": _selectedRejectCodeId,
        "sarjNo": _batchNo,
        "sonuc": _selectedResult,
        "aciklama": _descriptionController.text,
        "islemTarihi": DateTime.now().toIso8601String(),
      };

      await ref.read(reworkRepositoryProvider).update(id, payload);
      
      ref.invalidate(auditStateProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rework kaydı başarıyla güncellendi (ID: $id)'),
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
