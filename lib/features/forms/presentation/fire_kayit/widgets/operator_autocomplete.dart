import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../admin/presentation/providers/master_data_provider.dart';

/// Searchable operator dropdown with autocomplete
class OperatorAutocomplete extends ConsumerStatefulWidget {
  final String? selectedOperator;
  final ValueChanged<String?> onOperatorChanged;
  final bool enabled;

  const OperatorAutocomplete({
    super.key,
    required this.selectedOperator,
    required this.onOperatorChanged,
    this.enabled = true,
  });

  @override
  ConsumerState<OperatorAutocomplete> createState() =>
      _OperatorAutocompleteState();
}

class _OperatorAutocompleteState extends ConsumerState<OperatorAutocomplete> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.selectedOperator != null) {
      _searchController.text = widget.selectedOperator!;
    }
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _showDropdown) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showDropdown = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<String> _getFilteredOperators() {
    final masterData = ref.watch(masterDataProvider);
    final operators = masterData
        .where((item) => item.category == 'operators' && item.isActive)
        .map((item) => item.code)
        .toList();

    if (_searchQuery.isEmpty) {
      return operators;
    }

    return operators
        .where(
          (name) => name.toUpperCase().contains(_searchQuery.toUpperCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOperators = _getFilteredOperators();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operatör Adı',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                enabled: widget.enabled,
                style: const TextStyle(color: AppColors.textMain, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Operatör ara...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              widget.onOperatorChanged(null);
                            });
                          },
                        )
                      : const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 24,
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _showDropdown = true;
                  });
                },
                onTap: () {
                  setState(() => _showDropdown = true);
                },
              ),
            ),
            if (_showDropdown && filteredOperators.isNotEmpty)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: filteredOperators.length,
                      itemBuilder: (context, index) {
                        final operator = filteredOperators[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _searchController.text = operator;
                              _searchQuery = operator;
                              _showDropdown = false;
                            });
                            widget.onOperatorChanged(operator);
                            _focusNode.unfocus();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: index < filteredOperators.length - 1
                                    ? BorderSide(
                                        color: AppColors.border.withValues(
                                          alpha: 0.3,
                                        ),
                                      )
                                    : BorderSide.none,
                              ),
                            ),
                            child: Text(
                              operator,
                              style: const TextStyle(
                                color: AppColors.textMain,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
