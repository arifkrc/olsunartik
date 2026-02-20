import 'package:flutter/material.dart';
import '../../../../../core/widgets/forms/product_info_card.dart';
import '../../../../../core/widgets/forms/stepper_field.dart';

/// Product information section for Fire Kayit form
class ProductInfoSection extends StatelessWidget {
  final TextEditingController productCodeController;
  final TextEditingController productNameController;
  final TextEditingController productTypeController;
  final TextEditingController quantityController;
  final VoidCallback onQuantityDecrement;
  final VoidCallback onQuantityIncrement;

  const ProductInfoSection({
    super.key,
    required this.productCodeController,
    required this.productNameController,
    required this.productTypeController,
    required this.quantityController,
    required this.onQuantityDecrement,
    required this.onQuantityIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Product Info Card (Code, Name, Type) with Autocomplete
        ProductInfoCard(
          productCodeController: productCodeController,
          productName: productNameController.text,
          productType: productTypeController.text,
          onProductCodeChanged: (value) {
            // Optional: clear other fields if code is cleared
            if (value.isEmpty) {
              productNameController.clear();
              productTypeController.clear();
            }
          },
          onProductSelected: (product) {
            productNameController.text = product.urunAdi;
            productTypeController.text = product.urunTuru;
          },
        ),
        const SizedBox(height: 12),

        // Quantity Field
        StepperField(
          label: 'Adet',
          controller: quantityController,
          width: double.infinity,
          onDecrement: onQuantityDecrement,
          onIncrement: onQuantityIncrement,
        ),
      ],
    );
  }
}
