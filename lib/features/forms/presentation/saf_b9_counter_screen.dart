import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/domain/entities/tezgah.dart';
import '../../../core/providers/tezgah_providers.dart';
import '../../../core/widgets/forms/amount_button.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/dialogs/hurda_selection_dialog.dart';
import '../../../core/widgets/forms/modern_quick_button.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../data/models/saf_b9_counter_entry_dto.dart';
import '../logic/cubits/production_counter_cubit.dart';
import '../logic/cubits/production_counter_state.dart';
import 'providers/saf_b9_counter_providers.dart';

class SafB9CounterScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const SafB9CounterScreen({super.key, this.initialDate});

  @override
  ConsumerState<SafB9CounterScreen> createState() => _SafB9CounterScreenState();
}

class _SafB9CounterScreenState extends ConsumerState<SafB9CounterScreen> {
  // Form Controllers
  final _amountController = TextEditingController(text: '1');
  final _aciklamaController = TextEditingController();

  // Sabit Ürün Bilgileri
  final String _productName = 'SAF B9';
  final String _productCode = '6312011';
  final String _productDrawing = 'FRB1201';
  final String _operatorName = 'Furkan Yılmaz';

  // Tezgah Seçimi
  Tezgah? _selectedTezgah;

  @override
  void dispose() {
    _amountController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  void _updateAmount(int change) {
    int current = int.tryParse(_amountController.text) ?? 1;
    int newValue = current + change;
    if (newValue < 1) newValue = 1;
    _amountController.text = newValue.toString();
  }

  int get _currentAmount => int.tryParse(_amountController.text) ?? 1;

  void _addToDuzce([BuildContext? ctx]) {
    final cubitContext = ctx ?? context;
    cubitContext.read<ProductionCounterCubit>().incrementDuzce(_currentAmount);
    // _amountController.text = '1'; // Removed for persistence
  }

  void _addToAlmanya([BuildContext? ctx]) {
    final cubitContext = ctx ?? context;
    cubitContext.read<ProductionCounterCubit>().incrementAlmanya(
      _currentAmount,
    );
    // _amountController.text = '1'; // Removed for persistence
  }

  void _addToRework([BuildContext? ctx]) {
    final cubitContext = ctx ?? context;
    cubitContext.read<ProductionCounterCubit>().incrementRework(_currentAmount);
    // _amountController.text = '1'; // Removed for persistence
  }

  void _showHurdaPopup([BuildContext? ctx]) {
    final cubitContext = ctx ?? context;
    showDialog(
      context: cubitContext,
      builder: (context) => HurdaSelectionDialog(
        onReasonSelected: (reasonId, reason) {
          cubitContext.read<ProductionCounterCubit>().incrementHurda(
            _currentAmount,
            reasonId,
            reason,
          );
          // _amountController.text = '1'; // Removed for persistence
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductionCounterCubit(),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Arka Plan Görseli
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/frenbu_bg.jpg',
                      ), // Updated BG
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              // Ön Plan İçerik
              Row(
                children: [
                  // Sidebar
                  SidebarNavigation(
                    selectedIndex: 1, // Formlar altındayız
                    onItemSelected: (index) {
                      if (index == 0) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      } else if (index == 3) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ShiftNotesScreen(),
                          ),
                        );
                      } else if (index == 1) {
                        Navigator.of(context).pop();
                      }
                    },
                    operatorInitial: _operatorName.isNotEmpty
                        ? _operatorName[0]
                        : 'O',
                    onLogout: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                  // Ana İçerik
                  Expanded(
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.glassBorder,
                                      ),
                                    ),
                                    child: const Icon(
                                      LucideIcons.arrowLeft,
                                      color: AppColors.textMain,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SAF B9 Üretim Takibi',
                                      style: TextStyle(
                                        color: AppColors.textMain,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Günlük üretim giriş ekranı',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Image.asset(
                                  'assets/images/logo.png',
                                  height: 32,
                                ),
                              ],
                            ),
                          ),

                          // Form Content
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 32),
                                child: Column(
                                  // Main Column inside Scroll
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.glassBorder,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Product Info Row
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildReadOnlyField(
                                                  label: 'Ürün Kodu',
                                                  value: _productCode,
                                                  icon: LucideIcons.box,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildReadOnlyField(
                                                  label: 'Teknik Resim',
                                                  value: _productDrawing,
                                                  icon: LucideIcons.fileImage,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildReadOnlyField(
                                                  label: 'Ürün Adı',
                                                  value: _productName,
                                                  icon:
                                                      LucideIcons.clipboardList,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildTezgahDropdown(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          Divider(color: AppColors.border),
                                          const SizedBox(height: 24),

                                          // Input & Counters
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Left: Current Totals
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Mevcut Üretim',
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .textSecondary,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // First row: DÜZCE, ALMANYA (2 equal boxes)
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              BlocBuilder<
                                                                ProductionCounterCubit,
                                                                ProductionCounterState
                                                              >(
                                                                builder: (context, state) {
                                                                  return _buildCounterDisplay(
                                                                    'DÜZCE',
                                                                    state.duzce,
                                                                    AppColors
                                                                        .duzceGreen,
                                                                  );
                                                                },
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              BlocBuilder<
                                                                ProductionCounterCubit,
                                                                ProductionCounterState
                                                              >(
                                                                builder: (context, state) {
                                                                  return _buildCounterDisplay(
                                                                    'ALMANYA',
                                                                    state
                                                                        .almanya,
                                                                    AppColors
                                                                        .almanyaBlue,
                                                                  );
                                                                },
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // Second row: HURDA, REWORK, TOPLAM (3 equal boxes)
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              BlocBuilder<
                                                                ProductionCounterCubit,
                                                                ProductionCounterState
                                                              >(
                                                                builder: (context, state) {
                                                                  return _buildCounterDisplay(
                                                                    'HURDA',
                                                                    state.hurda,
                                                                    AppColors
                                                                        .error,
                                                                  );
                                                                },
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              BlocBuilder<
                                                                ProductionCounterCubit,
                                                                ProductionCounterState
                                                              >(
                                                                builder: (context, state) {
                                                                  return _buildCounterDisplay(
                                                                    'REWORK',
                                                                    state
                                                                        .rework,
                                                                    AppColors
                                                                        .reworkOrange,
                                                                  );
                                                                },
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              BlocBuilder<
                                                                ProductionCounterCubit,
                                                                ProductionCounterState
                                                              >(
                                                                builder: (context, state) {
                                                                  return _buildCounterDisplay(
                                                                    'TOPLAM',
                                                                    state.total,
                                                                    AppColors
                                                                        .primary,
                                                                  );
                                                                },
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 24),
                                              // Right: Input
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Giriş Miktarı',
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .textSecondary,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        AmountButton(
                                                          icon:
                                                              LucideIcons.minus,
                                                          onTap: () =>
                                                              _updateAmount(-1),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: TextFormField(
                                                            controller:
                                                                _amountController,
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .textMain,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly,
                                                            ],
                                                            decoration: InputDecoration(
                                                              filled: true,
                                                              fillColor: AppColors
                                                                  .surfaceLight,
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        12,
                                                                  ),
                                                              border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color: AppColors
                                                                          .border,
                                                                    ),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide(
                                                                      color: AppColors
                                                                          .border,
                                                                    ),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                borderSide: BorderSide(
                                                                  color: AppColors
                                                                      .primary,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        AmountButton(
                                                          icon:
                                                              LucideIcons.plus,
                                                          onTap: () =>
                                                              _updateAmount(1),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // Quick Add/Subtract with modern buttons
                                                    Row(
                                                      children: [
                                                        ModernQuickButton(
                                                          label: '+5',
                                                          onPressed: () =>
                                                              _updateAmount(5),
                                                          color: AppColors
                                                              .duzceGreen,
                                                          icon:
                                                              LucideIcons.plus,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        ModernQuickButton(
                                                          label: '+10',
                                                          onPressed: () =>
                                                              _updateAmount(10),
                                                          color: AppColors
                                                              .duzceGreen,
                                                          icon: LucideIcons
                                                              .chevronsUp,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        ModernQuickButton(
                                                          label: '-5',
                                                          onPressed: () =>
                                                              _updateAmount(-5),
                                                          color:
                                                              AppColors.error,
                                                          icon:
                                                              LucideIcons.minus,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        ModernQuickButton(
                                                          label: '-10',
                                                          onPressed: () =>
                                                              _updateAmount(
                                                                -10,
                                                              ),
                                                          color:
                                                              AppColors.error,
                                                          icon: LucideIcons
                                                              .chevronsDown,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 32),
                                          Text(
                                            'İşlem Tamamla',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Action Buttons
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _buildActionButton(
                                                      'DÜZCE EKLE',
                                                      AppColors.duzceGreen,
                                                      LucideIcons.checkCircle,
                                                      () =>
                                                          _addToDuzce(context),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: _buildActionButton(
                                                      'ALMANYA EKLE',
                                                      AppColors.almanyaBlue,
                                                      LucideIcons.globe,
                                                      () => _addToAlmanya(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _buildActionButton(
                                                      'REWORK EKLE',
                                                      AppColors.reworkOrange,
                                                      LucideIcons.wrench,
                                                      () =>
                                                          _addToRework(context),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: _buildActionButton(
                                                      'HURDA EKLE',
                                                      AppColors.error,
                                                      LucideIcons.trash2,
                                                      () => _showHurdaPopup(
                                                        context,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          // Açıklama Input
                                          Text(
                                            'Açıklama',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceLight
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppColors.border,
                                              ),
                                            ),
                                            child: TextFormField(
                                              controller: _aciklamaController,
                                              maxLines: 2,
                                              style: TextStyle(
                                                color: AppColors.textMain,
                                                fontSize: 14,
                                              ),
                                              decoration: InputDecoration(
                                                prefixIcon: Icon(
                                                  LucideIcons.fileText,
                                                  color:
                                                      AppColors.textSecondary,
                                                  size: 18,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 12,
                                                    ),
                                                hintText: 'Opsiyonel not...',
                                                hintStyle: TextStyle(
                                                  color: AppColors.textSecondary
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          // Summary Section - Eklenen Adetler
                                          BlocBuilder<
                                            ProductionCounterCubit,
                                            ProductionCounterState
                                          >(
                                            builder: (context, state) {
                                              if (state.total > 0) {
                                                return Container(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors
                                                        .surfaceLight
                                                        .withValues(alpha: 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color: AppColors.border,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            LucideIcons
                                                                .clipboardList,
                                                            color: AppColors
                                                                .textSecondary,
                                                            size: 18,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            'Eklenen Adetler',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      Wrap(
                                                        spacing: 8,
                                                        runSpacing: 8,
                                                        children: [
                                                          if (state.duzce > 0)
                                                            _buildSummaryChip(
                                                              '${state.duzce} Düzce',
                                                              AppColors
                                                                  .duzceGreen,
                                                            ),
                                                          if (state.almanya > 0)
                                                            _buildSummaryChip(
                                                              '${state.almanya} Almanya',
                                                              AppColors
                                                                  .almanyaBlue,
                                                            ),
                                                          if (state.rework > 0)
                                                            _buildSummaryChip(
                                                              '${state.rework} Rework',
                                                              AppColors
                                                                  .reworkOrange,
                                                            ),
                                                          if (state.hurda > 0)
                                                            ..._buildHurdaSummary(
                                                              state,
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          // Save Button
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                if (_selectedTezgah == null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Lütfen tezgah seçiniz'),
                                                      backgroundColor: AppColors.error,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                final state = context.read<ProductionCounterCubit>().state;
                                                if (state.total == 0) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Lütfen en az bir üretim giriniz'),
                                                      backgroundColor: AppColors.error,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                final hurdaLogs = state.logs.where((e) => e.actionType == 'hurda');
                                                final retMap = <int, SAFBRetDetayDto>{};
                                                for (final log in hurdaLogs) {
                                                  if (log.scrapReasonId != null) {
                                                    if (retMap.containsKey(log.scrapReasonId)) {
                                                      retMap[log.scrapReasonId!] = SAFBRetDetayDto(
                                                        retKoduId: log.scrapReasonId!,
                                                        retKodu: log.scrapReason,
                                                        retAdet: retMap[log.scrapReasonId!]!.retAdet + log.quantity,
                                                      );
                                                    } else {
                                                      retMap[log.scrapReasonId!] = SAFBRetDetayDto(
                                                        retKoduId: log.scrapReasonId!,
                                                        retKodu: log.scrapReason,
                                                        retAdet: log.quantity,
                                                      );
                                                    }
                                                  }
                                                }

                                                final request = SAFBRequestDto(
                                                  urunId: 303, // Default 303
                                                  tezgahId: _selectedTezgah!.id,
                                                  duzceAdet: state.duzce,
                                                  almanyaAdet: state.almanya,
                                                  reworkAdet: state.rework,
                                                  retDetaylari: retMap.values.toList(),
                                                  aciklama: _aciklamaController.text,
                                                );

                                                try {
                                                  final useCase = ref.read(submitSafB9CounterEntryUseCaseProvider);
                                                  final message = await useCase(request);

                                                  if (context.mounted) {
                                                    context.read<ProductionCounterCubit>().clearAll();
                                                    setState(() {
                                                      _amountController.text = '1';
                                                      _aciklamaController.clear();
                                                      _selectedTezgah = null;
                                                    });

                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(message),
                                                        backgroundColor: AppColors.success,
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text(e.toString().replaceAll('Exception: ', '')),
                                                        backgroundColor: AppColors.error,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              icon: const Icon(
                                                LucideIcons.save,
                                                size: 18,
                                              ),
                                              label: const Text('KAYDET'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    BlocBuilder<
                                      ProductionCounterCubit,
                                      ProductionCounterState
                                    >(
                                      builder: (context, state) {
                                        return _buildTransactionLogs(state);
                                      },
                                    ),
                                  ],
                                ),
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
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 12),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTezgahDropdown() {
    final tezgahlarAsync = ref.watch(tezgahlarProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tezgah Seçimi',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: tezgahlarAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (err, stack) => Text('Hata: $err',
                  style: const TextStyle(color: AppColors.error, fontSize: 12)),
              data: (tezgahList) {
                return DropdownButton<Tezgah>(
                  value: _selectedTezgah,
                  hint: Row(
                    children: [
                      Icon(
                        LucideIcons.settings,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tezgah Seçiniz',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  style: TextStyle(color: AppColors.textMain, fontSize: 14),
                  icon: Icon(
                    LucideIcons.chevronDown,
                    color: AppColors.textSecondary,
                  ),
                  items: tezgahList.map((tezgah) {
                    return DropdownMenuItem<Tezgah>(
                      value: tezgah,
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.settings,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(tezgah.displayLabel),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTezgah = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterDisplay(String label, int value, Color color) {
    // TOPLAM gets white background, others use their color
    final isTotal = label == 'TOPLAM';
    final bgColor = isTotal ? Colors.transparent : color.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTotal ? Colors.white : color.withValues(alpha: 0.3),
          width: isTotal ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildSummaryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildHurdaSummary(ProductionCounterState state) {
    // Log girdilerinden hurda hatalarını grupla
    final hurdaLogs = state.logs.where((e) => e.actionType == 'hurda').toList();

    if (hurdaLogs.isEmpty && state.hurda > 0) {
      return [_buildSummaryChip('${state.hurda} Hurda', AppColors.error)];
    } else if (hurdaLogs.isEmpty) {
      return [];
    }

    // Hata nedenlerine göre grupla
    final Map<String, int> errorCounts = {};
    for (final log in hurdaLogs) {
      final reason = log.scrapReason ?? 'Bilinmeyen';
      errorCounts[reason] = (errorCounts[reason] ?? 0) + log.quantity;
    }

    return errorCounts.entries.map((entry) {
      return _buildSummaryChip('${entry.value} ${entry.key}', AppColors.error);
    }).toList();
  }

  // Transaction Log List
  Widget _buildTransactionLogs(ProductionCounterState state) {
    if (state.logs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Son İşlemler',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.logs.length,
          itemBuilder: (context, index) {
            // Show newest first
            final log = state.logs[state.logs.length - 1 - index];
            Color logColor = AppColors.primary;
            IconData logIcon = LucideIcons.info;
            String actionText = '';

            switch (log.actionType) {
              case 'duzce':
                logColor = AppColors.success;
                logIcon = LucideIcons.checkCircle;
                actionText = 'Düzce Eklendi';
                break;
              case 'almanya':
                logColor = AppColors.info;
                logIcon = LucideIcons.globe;
                actionText = 'Almanya Eklendi';
                break;
              case 'hurda':
                logColor = AppColors.error;
                logIcon = LucideIcons.trash2;
                actionText = 'Hurda: ${log.scrapReason ?? "Bilinmiyor"}';
                break;
              case 'rework':
                logColor = AppColors.warning;
                logIcon = LucideIcons.wrench;
                actionText = 'Rework Eklendi';
                break;
              default:
                actionText = 'İşlem';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: logColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(logIcon, color: logColor, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actionText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Saat: ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${log.quantity}',
                    style: TextStyle(
                      color: logColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
