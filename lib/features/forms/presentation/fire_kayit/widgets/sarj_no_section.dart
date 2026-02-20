import 'package:flutter/material.dart';

import '../../../../../core/widgets/forms/custom_text_field.dart';
import '../../../../../core/widgets/forms/form_section_title.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SarjNoSection extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<String> onBatchNoChanged;

  const SarjNoSection({
    super.key,
    required this.initialDate,
    required this.onBatchNoChanged,
  });

  @override
  State<SarjNoSection> createState() => _SarjNoSectionState();
}

class _SarjNoSectionState extends State<SarjNoSection> {
  final TextEditingController _batchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _batchController.addListener(() {
      widget.onBatchNoChanged(_batchController.text);
    });
    _generateBatchNo();
  }

  @override
  void didUpdateWidget(covariant SarjNoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      _generateBatchNo();
    }
  }

  void _generateBatchNo() {
    // Logic to generate batch number
  }

  @override
  void dispose() {
    _batchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle(
          title: 'Şun Bilgileri',
          icon:
              LucideIcons.scanLine, // Used scanLine as barcode might be missing
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _batchController,
          label: 'Şarj Numarası',
          hint: 'Şarj numarasını giriniz',
          icon: LucideIcons.scanLine,
        ),
      ],
    );
  }
}
