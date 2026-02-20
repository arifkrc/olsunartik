import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/forms/sarj_no_picker.dart';

class EditGirisKaliteDialog extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditGirisKaliteDialog({super.key, required this.data});

  @override
  State<EditGirisKaliteDialog> createState() => _EditGirisKaliteDialogState();
}

class _EditGirisKaliteDialogState extends State<EditGirisKaliteDialog> {
  late TextEditingController _irsaliyeNoController;
  late TextEditingController _tedarikciController;
  late TextEditingController _productCodeController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;

  String? _selectedDecision;
  String _batchNo = '';

  final List<String> _decisions = ['Kabul', 'Red', 'Şartlı Kabul'];

  @override
  void initState() {
    super.initState();
    _irsaliyeNoController = TextEditingController(
      text: widget.data['irsaliyeNo'] ?? '',
    );
    _tedarikciController = TextEditingController(
      text: widget.data['tedarikci'] ?? '',
    );
    _productCodeController = TextEditingController(
      text: widget.data['productCode'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.data['description'] ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.data['quantity']?.toString() ?? '',
    );
    _selectedDecision = widget.data['decision'];
    _batchNo = widget.data['batchNo'] ?? '';
  }

  @override
  void dispose() {
    _irsaliyeNoController.dispose();
    _tedarikciController.dispose();
    _productCodeController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      color: Colors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.clipboardCheck,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giriş Kalite Düzenle',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // İrsaliye No & Tedarikçi
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'İrsaliye No',
                            controller: _irsaliyeNoController,
                            icon: LucideIcons.fileText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            label: 'Tedarikçi',
                            controller: _tedarikciController,
                            icon: LucideIcons.truck,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Product Code & Quantity
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            label: 'Ürün Kodu',
                            controller: _productCodeController,
                            icon: LucideIcons.box,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _buildTextField(
                            label: 'Adet',
                            controller: _quantityController,
                            icon: LucideIcons.hash,
                            keyboardType: TextInputType.number,
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

                    // Decision
                    _buildDropdown(
                      label: 'Karar',
                      value: _selectedDecision,
                      items: _decisions,
                      icon: LucideIcons.checkSquare,
                      onChanged: (val) =>
                          setState(() => _selectedDecision = val),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    _buildTextField(
                      label: 'Açıklama',
                      controller: _descriptionController,
                      icon: LucideIcons.messageSquare,
                      maxLines: 3,
                    ),
                  ],
                ),
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
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: _saveChanges,
                      icon: const Icon(LucideIcons.save, size: 16),
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
    TextInputType? keyboardType,
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
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
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

  Widget _buildDropdown({
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

  void _saveChanges() {
    if (_irsaliyeNoController.text.isEmpty ||
        _tedarikciController.text.isEmpty ||
        _productCodeController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedDecision == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm zorunlu alanları doldurun'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Giriş kalite kaydı güncellendi: ${widget.data['id']}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
