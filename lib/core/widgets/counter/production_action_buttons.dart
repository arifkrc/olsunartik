import 'package:flutter/material.dart';

/// Production Action Buttons Widget
/// Large action buttons for production counter operations
class ProductionActionButtons extends StatelessWidget {
  final List<ActionButtonConfig> buttons;

  const ProductionActionButtons({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: buttons.map((config) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: config == buttons.last ? 0 : 12),
            child: _buildActionButton(
              config.label,
              config.color,
              config.icon,
              config.onTap,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Config class for action buttons
class ActionButtonConfig {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const ActionButtonConfig({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });
}
