import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/app_colors.dart';
import 'sidebar_navigation.dart';

/// Reusable template for all form screens
/// Eliminates 200+ lines of duplicate boilerplate code
class FormScreenTemplate extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final String operatorName;
  final VoidCallback onBack;
  final Function(int) onSidebarItemSelected;
  final VoidCallback onLogout;
  final int selectedSidebarIndex;

  const FormScreenTemplate({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.operatorName,
    required this.onBack,
    required this.onSidebarItemSelected,
    required this.onLogout,
    this.selectedSidebarIndex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Image with Blur
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/frenbu_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withValues(alpha: 0.6)),
              ),
            ),
          ),
          // Main Content
          Row(
            children: [
              // Sidebar Navigation
              SidebarNavigation(
                selectedIndex: selectedSidebarIndex,
                onItemSelected: onSidebarItemSelected,
                operatorInitial: operatorName.isNotEmpty
                    ? operatorName[0]
                    : 'O',
                onLogout: onLogout,
              ),
              // Main Content Area
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      _buildHeader(context),
                      // Form Content (Scrollable)
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: content,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                LucideIcons.arrowLeft,
                color: AppColors.textMain,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Logo
          Image.asset('assets/images/logo.png', height: 32),
        ],
      ),
    );
  }
}
