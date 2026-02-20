import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';

class EditFinalControlDialog extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditFinalControlDialog({super.key, required this.data});

  @override
  State<EditFinalControlDialog> createState() => _EditFinalControlDialogState();
}

class _EditFinalControlDialogState extends State<EditFinalControlDialog> {
  late TextEditingController _productCodeController;
  late TextEditingController _customerNameController;
  late TextEditingController _productNameController;
  late TextEditingController _productTypeController;
  late TextEditingController _paletNoController;
  late TextEditingController _paketlenenController;
  late TextEditingController _hurdaController;
  late TextEditingController _reworkController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _productCodeController = TextEditingController(
      text: widget.data['productCode'] ?? '',
    );
    _customerNameController = TextEditingController(
      text: widget.data['customerName'] ?? '',
    );
    _productNameController = TextEditingController(
      text: widget.data['productName'] ?? '',
    );
    _productTypeController = TextEditingController(
      text: widget.data['productType'] ?? '',
    );
    _paletNoController = TextEditingController(
      text: widget.data['paletNo'] ?? '',
    );
    _paketlenenController = TextEditingController(
      text: widget.data['paketlenen']?.toString() ?? '0',
    );
    _hurdaController = TextEditingController(
      text: widget.data['hurda']?.toString() ?? '0',
    );
    _reworkController = TextEditingController(
      text: widget.data['rework']?.toString() ?? '0',
    );
    _descriptionController = TextEditingController(
      text: widget.data['description'] ?? '',
    );
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _customerNameController.dispose();
    _productNameController.dispose();
    _productTypeController.dispose();
    _paletNoController.dispose();
    _paketlenenController.dispose();
    _hurdaController.dispose();
    _reworkController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 750),
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
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.packageCheck,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Final Kontrol Düzenle',
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
                    // Product Code & Customer Name
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Ürün Kodu',
                            controller: _productCodeController,
                            icon: LucideIcons.box,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            label: 'Müşteri Adı',
                            controller: _customerNameController,
                            icon: LucideIcons.user,
                          ),
                        ),
                      ],
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

                    // Palet No
                    _buildTextField(
                      label: 'Palet İzlenebilirlik No',
                      controller: _paletNoController,
                      icon: LucideIcons.qrCode,
                    ),
                    const SizedBox(height: 16),

                    // Production Counters
                    Text(
                      'Üretim Sayaçları',
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
                          child: _buildCounterField(
                            label: 'Paketlenen',
                            controller: _paketlenenController,
                            color: AppColors.duzceGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildCounterField(
                            label: 'Hurda',
                            controller: _hurdaController,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildCounterField(
                      label: 'Rework',
                      controller: _reworkController,
                      color: AppColors.reworkOrange,
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

  Widget _buildCounterField({
    required String label,
    required TextEditingController controller,
    required Color color,
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
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  void _saveChanges() {
    if (_productCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ürün kodu boş olamaz'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Final kontrol kaydı güncellendi: ${widget.data['id']}'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
