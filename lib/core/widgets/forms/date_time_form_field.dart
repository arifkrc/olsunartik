import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';

/// A form field widget for selecting date and time
///
/// Shows date and time selection buttons that open DatePicker and TimePicker
/// Supports read-only mode for users without edit permissions
class DateTimeFormField extends StatefulWidget {
  final DateTime? initialDateTime;
  final ValueChanged<DateTime>? onChanged;
  final bool isEnabled;
  final String? label;

  const DateTimeFormField({
    super.key,
    this.initialDateTime,
    this.onChanged,
    this.isEnabled = true,
    this.label,
  });

  @override
  State<DateTimeFormField> createState() => _DateTimeFormFieldState();
}

class _DateTimeFormFieldState extends State<DateTimeFormField> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!widget.isEnabled) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
      widget.onChanged?.call(_selectedDateTime);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (!widget.isEnabled) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
      widget.onChanged?.call(_selectedDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            // Date Button
            Expanded(
              child: InkWell(
                onTap: widget.isEnabled ? () => _selectDate(context) : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isEnabled
                        ? AppColors.surfaceLight
                        : AppColors.surfaceLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.isEnabled
                          ? AppColors.border
                          : AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 18,
                        color: widget.isEnabled
                            ? AppColors.textSecondary
                            : AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd.MM.yyyy').format(_selectedDateTime),
                        style: TextStyle(
                          color: widget.isEnabled
                              ? AppColors.textMain
                              : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Time Button
            Expanded(
              child: InkWell(
                onTap: widget.isEnabled ? () => _selectTime(context) : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isEnabled
                        ? AppColors.surfaceLight
                        : AppColors.surfaceLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.isEnabled
                          ? AppColors.border
                          : AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 18,
                        color: widget.isEnabled
                            ? AppColors.textSecondary
                            : AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('HH:mm').format(_selectedDateTime),
                        style: TextStyle(
                          color: widget.isEnabled
                              ? AppColors.textMain
                              : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
