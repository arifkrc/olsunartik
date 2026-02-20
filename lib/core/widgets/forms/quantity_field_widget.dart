import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';

/// Quantity field widget with increment/decrement buttons
///
/// Used across multiple forms for entering quantities (Adet field).
/// Provides +/- buttons and manual text input with number formatting.
class QuantityFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const QuantityFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
  });

  void _decrement() {
    int current = int.tryParse(controller.text) ?? 1;
    if (current > 1) {
      controller.text = (current - 1).toString();
      onChanged?.call();
    }
  }

  void _increment() {
    int current = int.tryParse(controller.text) ?? 1;
    controller.text = (current + 1).toString();
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Decrease button
              InkWell(
                onTap: _decrement,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    LucideIcons.minus,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
              // Text field
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => onChanged?.call(),
                ),
              ),
              // Increase button
              InkWell(
                onTap: _increment,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    LucideIcons.plus,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
