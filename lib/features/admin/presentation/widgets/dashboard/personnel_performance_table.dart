import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';

class PersonnelPerformanceTable extends StatelessWidget {
  const PersonnelPerformanceTable({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Personel Performans Verisi
    final List<Map<String, dynamic>> personnelPerformance = [
      {'name': 'Furkan Yılmaz', 'total': 120, 'defects': 5, 'efficiency': 95},
      {'name': 'Ahmet Demir', 'total': 98, 'defects': 8, 'efficiency': 91},
      {'name': 'Mehmet Yılmaz', 'total': 105, 'defects': 2, 'efficiency': 98},
      {'name': 'Ali Veli', 'total': 85, 'defects': 1, 'efficiency': 99},
    ];

    // Sıralama: Verimliliğe göre (Yüksekten düşüğe)
    personnelPerformance.sort(
      (a, b) => (b['efficiency'] as int).compareTo(a['efficiency'] as int),
    );

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Icon(LucideIcons.users, size: 20, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                'Personel Performans Özeti',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        ...personnelPerformance.map((p) => _PersonnelCard(data: p)),
      ],
    );
  }
}

class _PersonnelCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _PersonnelCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final String name = data['name'];
    final int total = data['total'];
    final int defects = data['defects'];
    // final int efficiency = data['efficiency']; // Kaldırıldı

    // Renk skalası kaldırıldı (Verimlilik gösterilmediği için)

    // Uygun Üretim = Toplam - Hata
    final int okCount = total - defects;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceLight,
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // İsim ve Detaylar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Uygun Adet Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.duzceGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.duzceGreen.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.checkCircle,
                            size: 10,
                            color: AppColors.duzceGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$okCount Uygun',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Ret Adet Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.xCircle,
                            size: 10,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$defects Ret',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Toplam Üretim (Sağda Sade)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total',
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Toplam',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
