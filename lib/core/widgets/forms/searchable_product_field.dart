import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import '../../domain/entities/product.dart';
import '../../providers/product_providers.dart';

/// Searchable Product Field Widget
/// Ürün kodu için autocomplete özellikli searchable combobox
class SearchableProductField extends ConsumerStatefulWidget {
  final Function(Product?) onProductSelected;
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final dynamic searchProvider; // A NotifierProvider of AsyncValue<List<Product>>
  final String Function(Product)? displayStringForOption;

  const SearchableProductField({
    super.key,
    required this.onProductSelected,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.searchProvider,
    this.displayStringForOption,
  });

  @override
  ConsumerState<SearchableProductField> createState() =>
      _SearchableProductFieldState();
}

class _SearchableProductFieldState
    extends ConsumerState<SearchableProductField> {
  late TextEditingController _controller;
  Timer? _debounce;
  late dynamic _activeProvider;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _activeProvider = widget.searchProvider ?? productSearchProvider;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Debouncing: Son yazdıktan 500ms sonra arama yap
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().length >= 2) {
        ref.read(_activeProvider.notifier).searchProducts(query);
      } else {
        ref.read(_activeProvider.notifier).clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Product>> productSearchState = ref.watch(_activeProvider);

    return Autocomplete<Product>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return productSearchState.when(
          data: (products) => products,
          loading: () => <Product>[],
          error: (_, _) => <Product>[],
        );
      },
      displayStringForOption: widget.displayStringForOption ?? (Product product) => product.urunKodu,
      onSelected: (Product product) {
        setState(() {
          _controller.text = widget.displayStringForOption != null 
              ? widget.displayStringForOption!(product) 
              : product.urunKodu;
        });
        widget.onProductSelected(product);
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Controller'ı senkronize et
            textEditingController.text = _controller.text;
            textEditingController.selection = _controller.selection;

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              enabled: widget.enabled,
              style: const TextStyle(color: AppColors.textMain, fontSize: 14),
              decoration: InputDecoration(
                labelText: widget.displayStringForOption != null ? 'Ürün Seçin' : 'Ürün Kodu',
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
                                _controller.clear();
                                widget.onProductSelected(null);
                                ref
                                    .read(_activeProvider.notifier)
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                filled: true,
                fillColor: widget.enabled
                    ? AppColors.surfaceLight
                    : AppColors.surfaceLight.withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                _controller.text = value;
                _controller.selection = textEditingController.selection;
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.7,
                                      ),
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
                    error: (error, _) => _buildErrorState(error.toString()),
                  ),
                ),
              ),
            );
          },
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
            'Sonuç bulunamadı',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'En az 2 karakter girin',
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 11,
            ),
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

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(
            'Hata oluştu',
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
