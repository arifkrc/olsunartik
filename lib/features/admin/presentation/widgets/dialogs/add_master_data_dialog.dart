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
  final _yakinTelefonController = TextEditingController();
  final _yakinlikDerecesiController = TextEditingController();
  DateTime? _dogumTarihi;

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _productTypeController.dispose();
    _yakinTelefonController.dispose();
    _yakinlikDerecesiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dogumTarihi) {
      if (mounted) {
        setState(() {
          _dogumTarihi = picked;
        });
      }
    }
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
          child: SingleChildScrollView(
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

              // Product Type (only for urunler and ham-urunler)
              if (widget.category == 'urunler' || widget.category == 'ham-urunler') ...[
                TextFormField(
                  controller: _productTypeController,
                  style: const TextStyle(color: AppColors.textMain),
                  textCapitalization: TextCapitalization.words,
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
                maxLines: widget.category == 'personeller' || widget.category == 'operatorler' || widget.category == 'tezgahlar' || widget.category == 'operasyonlar' || widget.category == 'bolgeler' ? 1 : 3,
                decoration: InputDecoration(
                  labelText: _getDescriptionLabel(),
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(widget.category == 'personeller' ? LucideIcons.phone : LucideIcons.fileText, size: 18),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if ((widget.category == 'urunler' || widget.category == 'ham-urunler') && (value == null || value.isEmpty)) {
                     return 'Ürün adı gerekli';
                  }
                  return null;
                },
              ),
              // Personeller extra fields
              if (widget.category == 'personeller') ...[
                // Doğum Tarihi
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Text(
                          _dogumTarihi == null ? 'Doğum Tarihi Seçiniz' : '${_dogumTarihi!.year}-${_dogumTarihi!.month.toString().padLeft(2, '0')}-${_dogumTarihi!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: _dogumTarihi == null ? AppColors.textSecondary : AppColors.textMain,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Yakın Telefon No
                TextFormField(
                  controller: _yakinTelefonController,
                  style: const TextStyle(color: AppColors.textMain),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Yakın Telefon No',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.phoneCall, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Yakınlık Derecesi
                TextFormField(
                  controller: _yakinlikDerecesiController,
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: InputDecoration(
                    labelText: 'Yakınlık Derecesi',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(LucideIcons.users, size: 18),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ],
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
      ),
    );
  }

  String _getCodeLabel() {
    switch (widget.category) {
      case 'operasyonlar':
        return 'Operasyon Kodu';
      case 'operatorler':
      case 'personeller':
        return 'Ad Soyad';
      case 'bolgeler':
        return 'Bölge Kodu';
      case 'ret-kodlari':
        return 'Ret Kodu';
      case 'tezgahlar':
        return 'Tezgah No';
      case 'urunler':
      case 'ham-urunler':
        return 'Ürün Kodu';
      default:
        return 'Kod';
    }
  }

  String _getDescriptionLabel() {
    switch (widget.category) {
      case 'operasyonlar':
        return 'Operasyon Adı (Opsiyonel)';
      case 'operatorler':
        return 'Sicil No (Opsiyonel)';
      case 'personeller':
        return 'Telefon No (Opsiyonel)';
      case 'bolgeler':
        return 'Bölge Adı (Opsiyonel)';
      case 'ret-kodlari':
        return 'Açıklama (Opsiyonel)';
      case 'tezgahlar':
        return 'Tezgah Türü (Opsiyonel)';
      case 'urunler':
      case 'ham-urunler':
        return 'Ürün Adı';
      default:
        return 'Açıklama (Opsiyonel)';
    }
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      final code = _codeController.text;
      final desc = _descriptionController.text.isNotEmpty ? _descriptionController.text : null;
      final type = _productTypeController.text.isNotEmpty ? _productTypeController.text : null;

      Map<String, dynamic> payload = {};

      switch (widget.category) {
        case 'operasyonlar':
          payload = {'operasyonKodu': code, 'operasyonAdi': desc};
          break;
        case 'operatorler':
          payload = {'adSoyad': code, 'sicilNo': desc};
          break;
        case 'personeller':
          payload = {
            'adSoyad': code, 
            'telefonNo': desc,
            if (_dogumTarihi != null) 'dogumTarihi': '${_dogumTarihi!.year}-${_dogumTarihi!.month.toString().padLeft(2, '0')}-${_dogumTarihi!.day.toString().padLeft(2, '0')}',
            if (_yakinTelefonController.text.isNotEmpty) 'yakinTelefonNo': _yakinTelefonController.text,
            if (_yakinlikDerecesiController.text.isNotEmpty) 'yakinlikDerecesi': _yakinlikDerecesiController.text,
          };
          break;
        case 'bolgeler':
          payload = {'bolgeKodu': code, 'bolgeAdi': desc};
          break;
        case 'ret-kodlari':
          payload = {'kod': code, 'aciklama': desc};
          break;
        case 'tezgahlar':
          payload = {'tezgahNo': code, 'tezgahTuru': desc};
          break;
        case 'urunler':
        case 'ham-urunler':
          payload = {'urunKodu': code, 'urunAdi': desc, 'urunTuru': type ?? 'Belirtilmedi'};
          break;
      }

      ref.read(masterDataProvider.notifier).addItem(
            category: widget.category,
            payload: payload,
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
