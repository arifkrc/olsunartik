import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// Submit button for Fire Kayit form
class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color color;

  const SubmitButton({
    super.key,
    required this.onPressed,
    this.label = 'KAYDET',
    this.icon = Icons.save,
    this.color = AppColors.reworkOrange,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}
