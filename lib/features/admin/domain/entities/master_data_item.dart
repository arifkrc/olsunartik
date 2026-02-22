class MasterDataItem {
  final int id;
  final String category;
  final String code;
  final String? description;
  final String? productType; // Product type for product-codes category
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdByName;
  final String? updatedByName;
  
  // Personeller fields
  final DateTime? dogumTarihi;
  final String? yakinTelefonNo;
  final String? yakinlikDerecesi;

  MasterDataItem({
    required this.id,
    required this.category,
    required this.code,
    this.description,
    this.productType,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
    this.createdByName,
    this.updatedByName,
    this.dogumTarihi,
    this.yakinTelefonNo,
    this.yakinlikDerecesi,
  }) : createdAt = createdAt ?? DateTime.now();

  MasterDataItem copyWith({
    int? id,
    String? category,
    String? code,
    String? description,
    String? productType,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdByName,
    String? updatedByName,
    DateTime? dogumTarihi,
    String? yakinTelefonNo,
    String? yakinlikDerecesi,
  }) {
    return MasterDataItem(
      id: id ?? this.id,
      category: category ?? this.category,
      code: code ?? this.code,
      description: description ?? this.description,
      productType: productType ?? this.productType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByName: createdByName ?? this.createdByName,
      updatedByName: updatedByName ?? this.updatedByName,
      dogumTarihi: dogumTarihi ?? this.dogumTarihi,
      yakinTelefonNo: yakinTelefonNo ?? this.yakinTelefonNo,
      yakinlikDerecesi: yakinlikDerecesi ?? this.yakinlikDerecesi,
    );
  }
}
