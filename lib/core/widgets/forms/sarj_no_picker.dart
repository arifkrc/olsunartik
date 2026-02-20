import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';

/// Reusable Şarj No picker widget
/// Format: 26F025A (YearFoundryDayLine)
/// - Year: 2-digit year (00-99)
/// - Foundry: F or A
/// - Day: 3-digit day of year (001-366)
/// - Line: Single letter A-Z
class SarjNoPicker extends StatefulWidget {
  final Function(String) onChanged;
  final String? initialValue;

  const SarjNoPicker({super.key, required this.onChanged, this.initialValue});

  @override
  State<SarjNoPicker> createState() => _SarjNoPickerState();
}

class _SarjNoPickerState extends State<SarjNoPicker> {
  late int _sarjYear;
  late String _sarjFoundry;
  late TextEditingController _sarjDayController;
  late TextEditingController _sarjLineController;

  final List<String> _foundryOptions = ['F', 'A'];

  @override
  void initState() {
    super.initState();
    _initializeFromValue();
  }

  void _initializeFromValue() {
    if (widget.initialValue != null && widget.initialValue!.length >= 6) {
      // Parse initial value (e.g., "26F025A")
      try {
        _sarjYear = int.parse(widget.initialValue!.substring(0, 2));
        _sarjFoundry = widget.initialValue!.substring(2, 3);
        _sarjDayController = TextEditingController(
          text: widget.initialValue!.substring(3, 6),
        );
        _sarjLineController = TextEditingController(
          text: widget.initialValue!.substring(6, 7),
        );
      } catch (e) {
        _initializeDefaults();
      }
    } else {
      _initializeDefaults();
    }
  }

  void _initializeDefaults() {
    final now = DateTime.now();
    _sarjYear = now.year % 100;
    _sarjFoundry = 'F';
    final day = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    _sarjDayController = TextEditingController(
      text: day.toString().padLeft(3, '0'),
    );
    _sarjLineController = TextEditingController(text: 'A');
  }

  @override
  void dispose() {
    _sarjDayController.dispose();
    _sarjLineController.dispose();
    super.dispose();
  }

  String get _batchNo {
    final dayStr = _sarjDayController.text.padLeft(3, '0');
    final lineStr = _sarjLineController.text.isNotEmpty
        ? _sarjLineController.text.toUpperCase()
        : 'A';
    return '$_sarjYear$_sarjFoundry$dayStr$lineStr';
  }

  void _notifyChange() {
    widget.onChanged(_batchNo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Şarj No',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.hash, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 12),

              // Year (26)
              _buildStepperBox(
                value: _sarjYear.toString().padLeft(2, '0'),
                onDecrement: () {
                  setState(() {
                    _sarjYear = (_sarjYear - 1).clamp(0, 99);
                    _notifyChange();
                  });
                },
                onIncrement: () {
                  setState(() {
                    _sarjYear = (_sarjYear + 1).clamp(0, 99);
                    _notifyChange();
                  });
                },
              ),
              const SizedBox(width: 4),

              // Foundry (F/A)
              _buildStepperBox(
                value: _sarjFoundry,
                onDecrement: () {
                  final idx = _foundryOptions.indexOf(_sarjFoundry);
                  setState(() {
                    _sarjFoundry =
                        _foundryOptions[(idx - 1 + _foundryOptions.length) %
                            _foundryOptions.length];
                    _notifyChange();
                  });
                },
                onIncrement: () {
                  final idx = _foundryOptions.indexOf(_sarjFoundry);
                  setState(() {
                    _sarjFoundry =
                        _foundryOptions[(idx + 1) % _foundryOptions.length];
                    _notifyChange();
                  });
                },
              ),
              const SizedBox(width: 4),

              // Day (025)
              _buildStepperField(
                controller: _sarjDayController,
                width: 80,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(3),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onDecrement: () {
                  int current = int.tryParse(_sarjDayController.text) ?? 1;
                  current = (current - 1).clamp(1, 366);
                  _sarjDayController.text = current.toString().padLeft(3, '0');
                  setState(() {});
                  _notifyChange();
                },
                onIncrement: () {
                  int current = int.tryParse(_sarjDayController.text) ?? 1;
                  current = (current + 1).clamp(1, 366);
                  _sarjDayController.text = current.toString().padLeft(3, '0');
                  setState(() {});
                  _notifyChange();
                },
              ),
              const SizedBox(width: 4),

              // Line (A)
              _buildStepperField(
                controller: _sarjLineController,
                width: 60,
                isText: true,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
                onDecrement: () {
                  String current = _sarjLineController.text.toUpperCase();
                  if (current.isEmpty) current = 'A';
                  int code = current.codeUnitAt(0);
                  if (code > 65) {
                    _sarjLineController.text = String.fromCharCode(code - 1);
                  } else {
                    _sarjLineController.text = 'Z';
                  }
                  setState(() {});
                  _notifyChange();
                },
                onIncrement: () {
                  String current = _sarjLineController.text.toUpperCase();
                  if (current.isEmpty) current = 'A';
                  int code = current.codeUnitAt(0);
                  if (code < 90) {
                    _sarjLineController.text = String.fromCharCode(code + 1);
                  } else {
                    _sarjLineController.text = 'A';
                  }
                  setState(() {});
                  _notifyChange();
                },
              ),
              const Spacer(),

              // Preview
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _batchNo,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperBox({
    required String value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrement,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                LucideIcons.chevronLeft,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: onIncrement,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperField({
    required TextEditingController controller,
    required double width,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    bool isText = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrement,
            child: Icon(
              LucideIcons.chevronLeft,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: isText ? TextInputType.text : TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: inputFormatters,
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                setState(() {});
                _notifyChange();
              },
            ),
          ),
          InkWell(
            onTap: onIncrement,
            child: Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
