import 'package:flutter/material.dart';
import '../../../../../core/widgets/forms/custom_dropdown.dart';
import '../../../../../core/widgets/forms/custom_object_dropdown.dart';
import '../../../../../core/domain/entities/tezgah.dart';
import '../../../../../core/domain/entities/operasyon.dart';

/// Machine, zone operation, and product state selection (2 rows)
class MachineZoneSelection extends StatelessWidget {
  final Tezgah? selectedProcessedMachine;
  final Tezgah? selectedDetectedMachine;
  final String? selectedZone;
  final Operasyon? selectedOperation;
  final String productState;
  final List<Tezgah> machineOptions;
  final List<String> zoneOptions;
  final List<Operasyon> operationOptions;
  final Function(Tezgah?) onProcessedMachineChanged;
  final Function(Tezgah?) onDetectedMachineChanged;
  final Function(String?) onZoneChanged;
  final Function(Operasyon?) onOperationChanged;
  final Function(String?) onProductStateChanged;

  const MachineZoneSelection({
    super.key,
    required this.selectedProcessedMachine,
    required this.selectedDetectedMachine,
    required this.selectedZone,
    required this.selectedOperation,
    required this.machineOptions,
    required this.zoneOptions,
    required this.operationOptions,
    required this.productState,
    required this.onProcessedMachineChanged,
    required this.onDetectedMachineChanged,
    required this.onZoneChanged,
    required this.onOperationChanged,
    required this.onProductStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: İşlenen Tezgah + Tespit Edilen Tezgah + Durum
        Row(
          children: [
            Expanded(
              flex: 3,
              child: CustomObjectDropdown<Tezgah>(
                label: 'İşlenen Tezgah',
                value: selectedProcessedMachine,
                items: machineOptions,
                displayStringForOption: (t) => t.displayLabel,
                icon: Icons.precision_manufacturing_outlined,
                onChanged: onProcessedMachineChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: CustomObjectDropdown<Tezgah>(
                label: 'Tespit Edilen',
                value: selectedDetectedMachine,
                items: machineOptions,
                displayStringForOption: (t) => t.displayLabel,
                icon: Icons.search_outlined,
                onChanged: onDetectedMachineChanged,
              ),
            ),
            const SizedBox(width: 12),
            // Ham/İşlenmiş buttons
            Expanded(flex: 2, child: _buildCompactProductState()),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: Bölge + Operasyon
        Row(
          children: [
            Expanded(
              child: CustomDropdown(
                label: 'Bölge',
                value: selectedZone,
                items: zoneOptions,
                icon: Icons.location_on_outlined,
                onChanged: onZoneChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomObjectDropdown<Operasyon>(
                label: 'Operasyon',
                value: selectedOperation,
                items: operationOptions,
                displayStringForOption: (o) => o.operasyonAdi,
                icon: Icons.settings_outlined,
                onChanged: onOperationChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactProductState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durum',
          style: TextStyle(fontSize: 11, color: Colors.white54),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _buildStateButton('Ham', 'Ham')),
            const SizedBox(width: 4),
            Expanded(child: _buildStateButton('İşlenmiş', 'İşlenmiş')),
          ],
        ),
      ],
    );
  }

  Widget _buildStateButton(String label, String value) {
    final isSelected = productState == value;
    return GestureDetector(
      onTap: () => onProductStateChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
