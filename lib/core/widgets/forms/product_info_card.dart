import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../domain/entities/product.dart';
import '../../providers/product_providers.dart';

/// Modern Product Info Card Widget with Search
///
/// Displays product code input with autocomplete search and
/// product name/type below in a card
/// - Product code: Editable, bold, large, with search
/// - Product name/type: Display only, thin, small, modern card
class ProductInfoCard extends ConsumerStatefulWidget {
  final TextEditingController productCodeController;
  final String? productName;
  final String? productType;
  final ValueChanged<String>? onProductCodeChanged;
  final ValueChanged<Product>? onProductSelected;
  final bool enabled;

  const ProductInfoCard({
    super.key,
    required this.productCodeController,
    this.productName,
    this.productType,
    this.onProductCodeChanged,
    this.onProductSelected,
    this.enabled = true,
  });

  @override
  ConsumerState<ProductInfoCard> createState() => _ProductInfoCardState();
}

class _ProductInfoCardState extends ConsumerState<ProductInfoCard> {
  final FocusNode _focusNode = FocusNode();
  bool _warmedUp = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Ürün listesini arka planda cache'le — forma ilk açılınca tetiklenir
  void _warmupIfNeeded() {
    if (!_warmedUp) {
      _warmedUp = true;
      ref.read(productSearchProvider.notifier).warmup();
    }
  }

  /// Her karakter girişinde anlık client-side filtre — debounce gerekmez
  void _onSearchChanged(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(productSearchProvider.notifier).searchProducts(query);
    } else {
      ref.read(productSearchProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    _warmupIfNeeded(); // Ürün listesini sessizce cache'le
    final productSearchState = ref.watch(productSearchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Product Code Input with Autocomplete
        Autocomplete<Product>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            return productSearchState.when(
              data: (products) => products,
              loading: () => <Product>[],
              error: (_, _) => <Product>[],
            );
          },
          displayStringForOption: (Product product) => product.urunKodu,
          onSelected: (Product product) {
            setState(() {
              widget.productCodeController.text = product.urunKodu;
            });
            widget.onProductSelected?.call(product);
          },
          fieldViewBuilder:
              (
                BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                // Sync controllers
                textEditingController.text = widget.productCodeController.text;
                textEditingController.selection =
                    widget.productCodeController.selection;

                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  enabled: widget.enabled,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Ürün Kodu',
                    labelStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      LucideIcons.box,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    suffixIcon: productSearchState.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                          )
                        : (textEditingController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    LucideIcons.x,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    textEditingController.clear();
                                    widget.productCodeController.clear();
                                    widget.onProductCodeChanged?.call('');
                                    ref
                                        .read(productSearchProvider.notifier)
                                        .clear();
                                  },
                                )
                              : null),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    filled: true,
                    fillColor: widget.enabled
                        ? AppColors.surfaceLight
                        : AppColors.surfaceLight.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) {
                    widget.productCodeController.text = value;
                    widget.productCodeController.selection =
                        textEditingController.selection;
                    widget.onProductCodeChanged?.call(value);
                    _onSearchChanged(value);
                  },
                  validator: (value) {
                    if (widget.enabled && (value == null || value.isEmpty)) {
                      return 'Ürün kodu boş bırakılamaz';
                    }
                    return null;
                  },
                );
              },
          optionsViewBuilder:
              (
                BuildContext context,
                AutocompleteOnSelected<Product> onSelected,
                Iterable<Product> options,
              ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      width: MediaQuery.of(context).size.width - 100,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: productSearchState.when(
                        data: (products) {
                          if (products.isEmpty) {
                            return _buildEmptyState();
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.all(8),
                            shrinkWrap: true,
                            itemCount: products.length,
                            itemBuilder: (BuildContext context, int index) {
                              final product = products[index];
                              return InkWell(
                                onTap: () => onSelected(product),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.urunKodu,
                                        style: const TextStyle(
                                          color: AppColors.textMain,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        product.urunAdi,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        product.urunTuru,
                                        style: TextStyle(
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.7),
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () => _buildLoadingState(),
                        error: (error, _) => _buildErrorState(),
                      ),
                    ),
                  ),
                );
              },
        ),

        // Product Info Display Card
        if ((widget.productName?.isNotEmpty ?? false) ||
            (widget.productType?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Code Display (Bold)
                Text(
                  widget.productCodeController.text.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                if (widget.productName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.productName!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
                if (widget.productType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tür: ${widget.productType}',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.searchX,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ürün bulunamadı',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Hata oluştu',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
