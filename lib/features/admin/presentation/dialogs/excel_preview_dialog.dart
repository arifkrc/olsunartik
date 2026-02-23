import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/uretim_bilgisi_bulk_dto.dart';

class ExcelPreviewDialog extends StatelessWidget {
  final List<UretimBilgisiBulkItemDto> items;

  const ExcelPreviewDialog({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(LucideIcons.fileSearch, color: AppColors.primary),
          SizedBox(width: 12),
          Text(
            'Yükleme Önizleme',
            style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Excel dosyasından aşağıdaki veriler başarıyla ayrıştırıldı. Onaylıyor musunuz?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Toplam Kayıt', items.length.toString(), LucideIcons.list),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kayıt Detayları (İlk 10 Kayıt):',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < (items.length > 10 ? 10 : items.length); i++)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            dense: true,
                            title: Text(
                              'Tarih: ${items[i].uretimTarihi}',
                              style: const TextStyle(color: AppColors.textMain, fontSize: 13),
                            ),
                            subtitle: Text(
                              'Adet: ${items[i].uretimAdeti} | Fabrika: ${items[i].dokumhaneAdi}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ),
                          if (i < (items.length > 10 ? 10 : items.length) - 1)
                            const Divider(height: 1, color: AppColors.glassBorder),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            if (items.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '...ve ${items.length - 10} kayıt daha.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Onayla ve Kaydet'),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
