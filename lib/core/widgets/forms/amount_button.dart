import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Reusable increment/decrement button for amount fields
/// Eliminates code duplication across multiple form screens
class AmountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;

  const AmountButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 48,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor ?? AppColors.border),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.textMain, size: 20),
      ),
    );
  }
}
