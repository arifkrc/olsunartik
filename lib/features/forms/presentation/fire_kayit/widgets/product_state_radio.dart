import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/forms/custom_radio_option.dart';

/// Product state radio group (Ham / İşlenmiş)
class ProductStateRadio extends StatelessWidget {
  final String productState;
  final Function(String?) onChanged;

  const ProductStateRadio({
    super.key,
    required this.productState,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ürün Durumu',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: CustomRadioOption(
                value: 'Ham',
                groupValue: productState,
                icon: productState == 'Ham'
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomRadioOption(
                value: 'İşlenmiş',
                groupValue: productState,
                icon: productState == 'İşlenmiş'
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
