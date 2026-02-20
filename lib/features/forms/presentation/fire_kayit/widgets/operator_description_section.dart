import 'package:flutter/material.dart';
import '../../../../../core/widgets/forms/custom_text_field.dart';

/// Operator name and description input section
class OperatorDescriptionSection extends StatelessWidget {
  final TextEditingController operatorNameController;
  final TextEditingController aciklamaController;

  const OperatorDescriptionSection({
    super.key,
    required this.operatorNameController,
    required this.aciklamaController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'Operatör Adı',
          controller: operatorNameController,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          label: 'Açıklama (İsteğe Bağlı)',
          controller: aciklamaController,
          icon: Icons.description_outlined,
          maxLines: 2,
        ),
      ],
    );
  }
}
