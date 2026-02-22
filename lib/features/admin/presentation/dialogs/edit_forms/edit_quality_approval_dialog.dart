import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../providers/audit_providers.dart';
import '../../../providers/master_data_provider.dart';
import '../../../../forms/presentation/providers/quality_approval_providers.dart';

class EditQualityApprovalDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;

  const EditQualityApprovalDialog({super.key, required this.data});

  @override
  ConsumerState<EditQualityApprovalDialog> createState() =>
      _EditQualityApprovalDialogState();
}

class _EditQualityApprovalDialogState extends ConsumerState<EditQualityApprovalDialog> {
  late TextEditingController _productCodeController;
  late TextEditingController _productNameController;
  late TextEditingController _productTypeController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  late String _complianceStatus; // 'Uygun' or 'RET'
  int? _selectedRejectCodeId;
  bool _isLoading = false;

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
    _amountController = TextEditingController(
      text: (widget.data['adet'] ?? widget.data['amount'] ?? 1).toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.data['aciklama'] ?? widget.data['description'] ?? '',
    );
    _complianceStatus = (widget.data['isUygun'] ?? true) ? 'Uygun' : 'RET';
    _selectedRejectCodeId = widget.data['retKoduId'];
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _productNameController.dispose();
    _productTypeController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateAmount(int change) {
    int current = int.tryParse(_amountController.text) ?? 0;
    int newValue = current + change;
    if (newValue < 0) newValue = 0;
    _amountController.text = newValue.toString();
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
          mainAxisSize: MapAxisSize.min,
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
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.checkCircle,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kalite Onay Düzenle',
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

                        // Amount with +/- buttons
                        _buildAmountField(),
                        const SizedBox(height: 12),

                        // Compliance Status (Uygun/RET)
                        _buildComplianceRadio(),
                        const SizedBox(height: 12),

                        // Reject Code (conditional)
                        if (_complianceStatus == 'RET') ...[
                          rejectCodesAsync.when(
                            data: (codes) => _buildRejectCodeDropdown(codes),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, s) => Text('Hata: $e', style: const TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(height: 12),
                        ],

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

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adet',
          style: TextStyle(
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
          child: Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.minus, size: 18),
                onPressed: () => setState(() => _updateAmount(-1)),
                color: AppColors.textSecondary,
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.plus, size: 18),
                onPressed: () => setState(() => _updateAmount(1)),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplianceRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uygunluk Durumu',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() {
                  _complianceStatus = 'Uygun';
                  _selectedRejectCodeId = null;
                }),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _complianceStatus == 'Uygun'
                        ? AppColors.success
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _complianceStatus == 'Uygun'
                          ? AppColors.success
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _complianceStatus == 'Uygun'
                            ? LucideIcons.checkCircle2
                            : LucideIcons.circle,
                        color: _complianceStatus == 'Uygun'
                            ? Colors.white
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Uygun',
                        style: TextStyle(
                          color: _complianceStatus == 'Uygun'
                              ? Colors.white
                              ? AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _complianceStatus = 'RET'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _complianceStatus == 'RET'
                        ? AppColors.error.withValues(alpha: 0.15)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _complianceStatus == 'RET'
                          ? AppColors.error
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _complianceStatus == 'RET'
                            ? LucideIcons.xCircle
                            : LucideIcons.circle,
                        color: _complianceStatus == 'RET'
                            ? AppColors.error
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RET',
                        style: TextStyle(
                          color: _complianceStatus == 'RET'
                              ? AppColors.error
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRejectCodeDropdown(List<MasterDataItem> codes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ret Kodu',
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
            border: Border.all(color: AppColors.error),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedRejectCodeId,
              hint: Text(
                'Ret kodu seçin',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              isExpanded: true,
              dropdownColor: AppColors.surfaceLight,
              icon: Icon(
                LucideIcons.chevronDown,
                color: AppColors.textSecondary,
                size: 18,
              ),
              style: TextStyle(color: AppColors.textMain, fontSize: 13),
              items: codes
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id, 
                      child: Text('${item.code} - ${item.description ?? ''}')
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedRejectCodeId = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    if (_productCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ürün kodu boş olamaz'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_complianceStatus == 'RET' && _selectedRejectCodeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RET durumunda ret kodu seçilmelidir'),
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
        "urunId": widget.data['urunId'],
        "urunKodu": _productCodeController.text,
        "adet": int.tryParse(_amountController.text) ?? 1,
        "isUygun": _complianceStatus == 'Uygun',
        "retKoduId": _selectedRejectCodeId,
        "aciklama": _descriptionController.text,
        "islemTarihi": DateTime.now().toIso8601String(),
      };

      await ref.read(qualityApprovalRepositoryProvider).update(id, payload);
      
      ref.invalidate(auditStateProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kalite onay kaydı başarıyla güncellendi (ID: $id)'),
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
