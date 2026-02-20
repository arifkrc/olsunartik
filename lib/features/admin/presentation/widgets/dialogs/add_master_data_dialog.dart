import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../providers/master_data_provider.dart';

class AddMasterDataDialog extends ConsumerStatefulWidget {
  final String category;

  const AddMasterDataDialog({super.key, required this.category});

  @override
  ConsumerState<AddMasterDataDialog> createState() =>
      _AddMasterDataDialogState();
}

class _AddMasterDataDialogState extends ConsumerState<AddMasterDataDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productTypeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _productTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryLabel = masterDataCategories[widget.category]!['label']!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.plus,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yeni $categoryLabel',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        Text(
                          categoryLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Code/Name
              TextFormField(
                controller: _codeController,
                style: const TextStyle(color: AppColors.textMain),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: _getCodeLabel(),
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(LucideIcons.tag, size: 18),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bu alan gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Product Type (only for product-codes)
              if (widget.category == 'product-codes') ...[
                TextFormField(
                  controller: _productTypeController,
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: InputDecoration(
                    labelText: 'Ürün Türü',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.package, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bu alan gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Description
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.textMain),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(LucideIcons.fileText, size: 18),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.border),
                      ),
                      child: const Text(
                        'İptal',
                        style: TextStyle(color: AppColors.textMain),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Ekle'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCodeLabel() {
    switch (widget.category) {
      case 'operators':
        return 'Ad Soyad';
      case 'machines':
        return 'Tezgah Kodu';
      case 'reject-codes':
        return 'Ret Kodu';
      case 'zones':
        return 'Bölge Kodu';
      case 'product-codes':
        return 'Ürün Kodu';
      case 'operation-names':
        return 'Operasyon Adı';
      case 'rework-operations':
        return 'Rework İşlemi';
      default:
        return 'Kod';
    }
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(masterDataProvider.notifier)
          .addItem(
            category: widget.category,
            code: _codeController.text,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
            productType:
                widget.category == 'product-codes' &&
                    _productTypeController.text.isNotEmpty
                ? _productTypeController.text
                : null,
          );

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_codeController.text} başarıyla eklendi'),
          backgroundColor: AppColors.duzceGreen,
        ),
      );
    }
  }
}
