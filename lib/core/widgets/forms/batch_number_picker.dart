import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/app_colors.dart';
import 'stepper_box.dart';

/// Batch number picker widget for forms
///
/// Provides an interactive batch number (Şarj No) builder with components:
/// - Year (2 digits)
/// - Foundry code (single letter: F, M, S, K)
/// - Day of year (3 digits, 001-366)
/// - Line code (single letter A-Z)
///
/// Displays formatted batch number: e.g., "26F025A"
class BatchNumberPicker extends StatefulWidget {
  final String label;
  final Function(String) onBatchNoChanged;
  final DateTime? initialDate;
  final int? initialYear;
  final String? initialFoundry;
  final int? initialDay;
  final String? initialLine;

  const BatchNumberPicker({
    super.key,
    this.label = 'Şarj No',
    required this.onBatchNoChanged,
    this.initialDate,
    this.initialYear,
    this.initialFoundry,
    this.initialDay,
    this.initialLine,
  });

  @override
  State<BatchNumberPicker> createState() => _BatchNumberPickerState();
}

class _BatchNumberPickerState extends State<BatchNumberPicker> {
  static const List<String> _foundryOptions = ['F', 'A'];

  late int _year;
  late String _foundry;
  late TextEditingController _dayController;
  late TextEditingController _lineController;

  @override
  void initState() {
    super.initState();
    final now = widget.initialDate ?? DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;

    _year = widget.initialYear ?? (now.year % 100);
    _foundry = widget.initialFoundry ?? 'F';
    _dayController = TextEditingController(
      text: (widget.initialDay ?? dayOfYear).toString().padLeft(3, '0'),
    );
    _lineController = TextEditingController(text: widget.initialLine ?? 'A');

    // Notify initial value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onBatchNoChanged(_formattedBatchNo);
    });
  }

  @override
  void dispose() {
    _dayController.dispose();
    _lineController.dispose();
    super.dispose();
  }

  String get _formattedBatchNo {
    final dayStr = _dayController.text.padLeft(3, '0');
    return '${_year.toString().padLeft(2, '0')}$_foundry$dayStr${_lineController.text}';
  }

  void _notifyChange() {
    widget.onBatchNoChanged(_formattedBatchNo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
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

              // Year (2 digits: 00-99)
              StepperBox(
                value: _year.toString().padLeft(2, '0'),
                onDecrement: () {
                  setState(() => _year = (_year - 1).clamp(0, 99));
                  _notifyChange();
                },
                onIncrement: () {
                  setState(() => _year = (_year + 1).clamp(0, 99));
                  _notifyChange();
                },
              ),
              const SizedBox(width: 4),

              // Foundry code (F, M, S, K)
              StepperBox(
                value: _foundry,
                onDecrement: () {
                  final idx = _foundryOptions.indexOf(_foundry);
                  setState(() {
                    _foundry =
                        _foundryOptions[(idx - 1 + _foundryOptions.length) %
                            _foundryOptions.length];
                  });
                  _notifyChange();
                },
                onIncrement: () {
                  final idx = _foundryOptions.indexOf(_foundry);
                  setState(() {
                    _foundry =
                        _foundryOptions[(idx + 1) % _foundryOptions.length];
                  });
                  _notifyChange();
                },
              ),
              const SizedBox(width: 4),

              // Day of year (001-366)
              Container(
                width: 80,
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        int current = int.tryParse(_dayController.text) ?? 1;
                        current = (current - 1).clamp(1, 366);
                        _dayController.text = current.toString().padLeft(
                          3,
                          '0',
                        );
                        setState(() {});
                        _notifyChange();
                      },
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _dayController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(3),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                        onChanged: (_) {
                          setState(() {});
                          _notifyChange();
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        int current = int.tryParse(_dayController.text) ?? 1;
                        current = (current + 1).clamp(1, 366);
                        _dayController.text = current.toString().padLeft(
                          3,
                          '0',
                        );
                        setState(() {});
                        _notifyChange();
                      },
                      child: Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // Line code (A-Z)
              Container(
                width: 60,
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        String current = _lineController.text.toUpperCase();
                        if (current.isEmpty) current = 'A';
                        int code = current.codeUnitAt(0);
                        if (code > 65) {
                          _lineController.text = String.fromCharCode(code - 1);
                        } else {
                          _lineController.text = 'Z';
                        }
                        setState(() {});
                        _notifyChange();
                      },
                      child: Icon(
                        LucideIcons.chevronLeft,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _lineController,
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z]'),
                          ),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return newValue.copyWith(
                              text: newValue.text.toUpperCase(),
                            );
                          }),
                        ],
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
                        onChanged: (_) {
                          setState(() {});
                          _notifyChange();
                        },
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        String current = _lineController.text.toUpperCase();
                        if (current.isEmpty) current = 'A';
                        int code = current.codeUnitAt(0);
                        if (code < 90) {
                          _lineController.text = String.fromCharCode(code + 1);
                        } else {
                          _lineController.text = 'A';
                        }
                        setState(() {});
                        _notifyChange();
                      },
                      child: Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Formatted batch number display
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
                  _formattedBatchNo,
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
}
