import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/master_data_item.dart';
import '../providers/master_data_provider.dart';
import 'dialogs/add_master_data_dialog.dart';
import 'dialogs/edit_master_data_dialog.dart';
import 'dialogs/delete_master_data_dialog.dart';

class MasterDataTab extends ConsumerStatefulWidget {
  const MasterDataTab({super.key});

  @override
  ConsumerState<MasterDataTab> createState() => _MasterDataTabState();
}

class _MasterDataTabState extends ConsumerState<MasterDataTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final masterDataAsync = ref.watch(masterDataProvider);

    return masterDataAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text('Hata: $error', style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(masterDataProvider),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
      data: (allItems) {
        final filteredItems = allItems.where((item) {
          if (_searchQuery.isEmpty) return true;
          return item.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (item.description?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);
        }).toList();

        return Row(
          children: [
            // Category Selector
            _buildCategorySelector(selectedCategory),

            // Vertical Divider
            Container(width: 1, color: AppColors.border),

            // Data Panel
            Expanded(
              child: Column(
                children: [
                  _buildDataHeader(selectedCategory, filteredItems.length),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? _buildEmptyState()
                        : _buildDataList(filteredItems),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategorySelector(String selectedCategory) {
    return Container(
      width: 280,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.database, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'Kategoriler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: masterDataCategories.entries.map((entry) {
                return _buildCategoryItem(
                  category: entry.key,
                  label: entry.value['label']!,
                  icon: _getIconForCategory(entry.value['icon']!),
                  isSelected: entry.key == selectedCategory,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required String category,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () =>
            ref.read(selectedCategoryProvider.notifier).setCategory(category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMain,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  LucideIcons.chevronRight,
                  color: Colors.white,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataHeader(String category, int itemCount) {
    final categoryInfo = masterDataCategories[category]!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForCategory(categoryInfo['icon']!),
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryInfo['label']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              Text(
                '$itemCount öğe',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Search
          Container(
            width: 280,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: AppColors.textMain),
              decoration: const InputDecoration(
                hintText: 'Ara...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(
                  LucideIcons.search,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Add button
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(category),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Yeni Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataList(List<MasterDataItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildDataCard(items[index]),
    );
  }

  Widget _buildDataCard(MasterDataItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isActive
              ? AppColors.glassBorder
              : AppColors.border.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.isActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _getIconForCategory(
                  masterDataCategories[item.category]!['icon']!,
                ),
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.code,
                      style: TextStyle(
                        color: item.isActive
                            ? AppColors.textMain
                            : AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!item.isActive) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Pasif',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(
                      color: item.isActive
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      LucideIcons.calendar,
                      size: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.updatedAt != null 
                        ? 'Son Güncelleme Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(item.updatedAt!)}'
                        : 'Eklenme Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(item.createdAt)}',
                      style: TextStyle(
                        color: item.isActive
                            ? AppColors.textSecondary
                            : AppColors.textSecondary.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (item.updatedByName != null || item.createdByName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.user,
                        size: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.updatedByName != null 
                          ? 'Son Güncelleyen: ${item.updatedByName}'
                          : 'Oluşturan: ${item.createdByName}',
                        style: TextStyle(
                          color: item.isActive
                              ? AppColors.textSecondary
                              : AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              // Active toggle
              Switch(
                value: item.isActive,
                activeTrackColor: AppColors.duzceGreen.withValues(alpha: 0.5),
                thumbColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.duzceGreen
                      : AppColors.textSecondary,
                ),
                onChanged: (value) {
                  ref.read(masterDataProvider.notifier).updateItem(
                        item: item,
                        payload: {
                          'isActive': value,
                        },
                      );
                },
              ),
              IconButton(
                icon: const Icon(LucideIcons.edit2, size: 18),
                color: AppColors.primary,
                tooltip: 'Düzenle',
                onPressed: () => _showEditDialog(item),
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, size: 18),
                color: AppColors.error,
                tooltip: 'Sil',
                onPressed: () => _showDeleteDialog(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.inbox, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Henüz veri yok' : 'Arama sonucu bulunamadı',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String iconName) {
    switch (iconName) {
      case 'settings':
        return LucideIcons.settings;
      case 'user':
        return LucideIcons.user;
      case 'xCircle':
        return LucideIcons.xCircle;
      case 'mapPin':
        return LucideIcons.mapPin;
      case 'package':
        return LucideIcons.package;
      case 'box':
        return LucideIcons.box;
      case 'tool':
        return LucideIcons.wrench;
      case 'rotateC cw':
        return LucideIcons.rotateCw;
      default:
        return LucideIcons.circle;
    }
  }

  void _showAddDialog(String category) {
    showDialog(
      context: context,
      builder: (context) => AddMasterDataDialog(category: category),
    );
  }

  void _showEditDialog(MasterDataItem item) {
    showDialog(
      context: context,
      builder: (context) => EditMasterDataDialog(item: item),
    );
  }

  void _showDeleteDialog(MasterDataItem item) {
    showDialog(
      context: context,
      builder: (context) => DeleteMasterDataDialog(item: item),
    );
  }
}
