import 'package:flutter/material.dart';
import '../../../../../core/widgets/forms/batch_number_picker.dart';

/// Şarj No picker section (without error reason)
///
/// This widget has been simplified to use the shared BatchNumberPicker component
class SarjNoSection extends StatelessWidget {
  final DateTime? initialDate;
  final Function(String) onBatchNoChanged;

  const SarjNoSection({
    super.key,
    this.initialDate,
    required this.onBatchNoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BatchNumberPicker(
          initialDate: initialDate,
          onBatchNoChanged: onBatchNoChanged,
        ),
      ],
    );
  }
}
