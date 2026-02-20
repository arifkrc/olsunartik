import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';

/// Reusable number stepper field with +/- buttons
class StepperField extends StatelessWidget {
  final TextEditingController controller;
  final double width;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool isText;
  final List<TextInputFormatter>? inputFormatters;
  final String? label;

  const StepperField({
    super.key,
    required this.controller,
    required this.width,
    required this.onDecrement,
    required this.onIncrement,
    this.isText = false,
    this.inputFormatters,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          width: width,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              // Decrement Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onDecrement,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.remove,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ),
              // Text Field
              Expanded(
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: isText
                      ? TextInputType.text
                      : TextInputType.number,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              // Increment Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onIncrement,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primary,
                      size: 18,
                    ),
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
