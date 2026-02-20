class MasterDataItem {
  final int id;
  final String category;
  final String code;
  final String? description;
  final String? productType; // Product type for product-codes category
  final bool isActive;
  final DateTime createdAt;

  MasterDataItem({
    required this.id,
    required this.category,
    required this.code,
    this.description,
    this.productType,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MasterDataItem copyWith({
    int? id,
    String? category,
    String? code,
    String? description,
    String? productType,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return MasterDataItem(
      id: id ?? this.id,
      category: category ?? this.category,
      code: code ?? this.code,
      description: description ?? this.description,
      productType: productType ?? this.productType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
