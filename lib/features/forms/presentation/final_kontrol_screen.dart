import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/forms/amount_button.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/dialogs/hurda_selection_dialog.dart';
import '../../../core/widgets/forms/product_info_card.dart';
import '../../../core/widgets/forms/modern_quick_button.dart';
import '../../auth/presentation/login_screen.dart';
import '../../chat/presentation/shift_notes_screen.dart';
import '../logic/cubits/production_counter_cubit.dart';
import '../logic/cubits/production_counter_state.dart';
import '../data/models/final_kontrol_form_dto.dart';
import 'providers/final_kontrol_providers.dart';

class FinalKontrolScreen extends StatefulWidget {
  final DateTime? initialDate;
  const FinalKontrolScreen({super.key, this.initialDate});

  @override
  State<FinalKontrolScreen> createState() => _FinalKontrolScreenState();
}

class _FinalKontrolScreenState extends State<FinalKontrolScreen> {
  // Form Controllers
  final _amountController = TextEditingController(text: '1');
  final _productCodeController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _paletNoController = TextEditingController();
  final _aciklamaController = TextEditingController();

  // Ürün Bilgileri
  String _productName = '';
  String _productType = '';
  int? _selectedProductId;
  final String _operatorName = 'Furkan Yılmaz';

  @override
  void dispose() {
    _amountController.dispose();
    _productCodeController.dispose();
    _customerNameController.dispose();
    _paletNoController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  void _onProductCodeChanged(String code) {
    // Simüle edilmiş sistem yanıtı - gerçek uygulamada API çağrısı yapılır
    if (code.isNotEmpty) {
      setState(() {
        _productName = 'Ürün-$code';
        _productType = 'Disk';
      });
      context.read<ProductionCounterCubit>().setProductInfo(
        _productName,
        _productType,
      );
    } else {
      setState(() {
        _productName = '';
        _productType = '';
      });
      context.read<ProductionCounterCubit>().setProductInfo('', '');
    }
  }

  void _updateAmount(int change) {
    int current = int.tryParse(_amountController.text) ?? 1;
    int newValue = current + change;
    if (newValue < 1) newValue = 1;
    _amountController.text = newValue.toString();
  }

  int get _currentAmount => int.tryParse(_amountController.text) ?? 1;

  void _addToPaketlenen([BuildContext? ctx]) {
    final cubitContext = ctx ?? context;
    cubitContext.read<ProductionCounterCubit>().incrementPaketlenen(
      _currentAmount,
    );
    // _resetAmount(); // Removed for persistence
  }

  void _addToRework([BuildContext? ctx]) {
    final cubitContext = ctx ?? context;
    cubitContext.read<ProductionCounterCubit>().incrementRework(_currentAmount);
    // _resetAmount(); // Removed for persistence
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
          // _resetAmount(); // Removed for persistence
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
                                      'Final Kontrol',
                                      style: TextStyle(
                                        color: AppColors.textMain,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Son Kontrol Aşaması',
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
                                          // Product Info Card (full width with dropdown)
                                          ProductInfoCard(
                                            productCodeController:
                                                _productCodeController,
                                            productName: _productName.isEmpty
                                                ? null
                                                : _productName,
                                            productType: _productType.isEmpty
                                                ? null
                                                : _productType,
                                            onProductCodeChanged:
                                                _onProductCodeChanged,
                                            onProductSelected: (product) {
                                              setState(() {
                                                _productName = product.urunAdi;
                                                _productType = product.urunTuru;
                                                _selectedProductId = product.id;
                                              });
                                              context
                                                  .read<ProductionCounterCubit>()
                                                  .setProductInfo(
                                                    product.urunAdi,
                                                    product.urunTuru,
                                                  );
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          // Customer Name + Palet İzlenebilirlik (side by side)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildInputField(
                                                  label: 'Müşteri Adı',
                                                  controller:
                                                      _customerNameController,
                                                  icon: LucideIcons.user,
                                                  keyboardType:
                                                      TextInputType.text,
                                                ),
                                              ),
                                              const SizedBox(width: 16),

                                              Expanded(
                                                child: _buildInputField(
                                                  label:
                                                      'Palet İzlenebilirlik No',
                                                  controller:
                                                      _paletNoController,
                                                  icon: LucideIcons.scanLine,
                                                  keyboardType:
                                                      TextInputType.text,
                                                ),
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
                                                    // First row: TOPLAM, PAKETLENEN (2 equal boxes)
                                                    BlocBuilder<
                                                      ProductionCounterCubit,
                                                      ProductionCounterState
                                                    >(
                                                      builder: (context, state) {
                                                        return Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  _buildCounterDisplay(
                                                                    'TOPLAM',
                                                                    state.total,
                                                                    AppColors
                                                                        .primary,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: _buildCounterDisplay(
                                                                'PAKETLENEN',
                                                                state
                                                                    .paketlenen,
                                                                AppColors
                                                                    .almanyaBlue,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(height: 8),
                                                    // Second row: HURDA, REWORK (2 equal boxes)
                                                    BlocBuilder<
                                                      ProductionCounterCubit,
                                                      ProductionCounterState
                                                    >(
                                                      builder: (context, state) {
                                                        return Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  _buildCounterDisplay(
                                                                    'HURDA',
                                                                    state.hurda,
                                                                    AppColors
                                                                        .error,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: _buildCounterDisplay(
                                                                'REWORK',
                                                                state.rework,
                                                                AppColors
                                                                    .reworkOrange,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildActionButton(
                                                  'PAKETLENEN EKLE',
                                                  AppColors.almanyaBlue,
                                                  LucideIcons.package,
                                                  () =>
                                                      _addToPaketlenen(context),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildActionButton(
                                                  'REWORK EKLE',
                                                  AppColors.reworkOrange,
                                                  LucideIcons.wrench,
                                                  () => _addToRework(context),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _buildActionButton(
                                                  'HURDA EKLE',
                                                  AppColors.error,
                                                  LucideIcons.trash2,
                                                  () =>
                                                      _showHurdaPopup(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          // Açıklama
                                          _buildInputField(
                                            label: 'Açıklama',
                                            controller: _aciklamaController,
                                            icon: LucideIcons.messageSquare,
                                            keyboardType: TextInputType.text,
                                          ),
                                          const SizedBox(height: 24),
                                          // Summary Section - Eklenen Adetler
                                          BlocBuilder<
                                            ProductionCounterCubit,
                                            ProductionCounterState
                                          >(
                                            builder: (context, state) {
                                              if (state.paketlenen > 0 ||
                                                  state.rework > 0 ||
                                                  state.hurda > 0) {
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
                                                          if (state.paketlenen >
                                                              0)
                                                            _buildSummaryChip(
                                                              '${state.paketlenen} Paketlenen',
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
                                          const SizedBox(height: 24),

                                          // Transaction Logs
                                          BlocBuilder<
                                            ProductionCounterCubit,
                                            ProductionCounterState
                                          >(
                                            builder: (context, state) {
                                              return _buildTransactionLogs(
                                                state,
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 24),
                                          // Conditional spacing removed - handled by BlocBuilder
                                          // Save Button
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () => _submitForm(context),
                                              icon: const Icon(
                                                LucideIcons.save,
                                                size: 18,
                                              ),
                                              label: const Text('KAYDET'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.duzceGreen,
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

  // --- Form Submission ---

  Future<void> _submitForm(BuildContext context) async {
    final counterState = context.read<ProductionCounterCubit>().state;

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir ürün seçin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (counterState.logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kaydedilecek işlem yok. Paketlenen, rework veya hurda ekleyin.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Map logs -> items
      final items = counterState.logs.map((log) {
        int islemTipi;
        switch (log.actionType) {
          case 'paketlenen': islemTipi = 1; break;
          case 'rework':     islemTipi = 2; break;
          case 'hurda':      islemTipi = 3; break;
          default:           islemTipi = 1;
        }
        return FinalKontrolItemDto(
          islemTipi: islemTipi,
          adet: log.quantity,
          retKoduId: log.scrapReasonId,
          aciklama: _aciklamaController.text.isNotEmpty ? _aciklamaController.text : null,
        );
      }).toList();

      final requestDto = FinalKontrolRequestDto(
        urunId: _selectedProductId!,
        paletIzlenebilirlikNo: _paletNoController.text,
        items: items,
      );

      // Get useCase from Riverpod (using ProviderScope)
      final useCase = ProviderScope.containerOf(context).read(submitFinalKontrolFormUseCaseProvider);
      final result = await useCase.call(requestDto);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading

      final successMsg = result.successCount > 0
          ? '${result.successCount} kayıt başarıyla oluşturuldu'
          : 'Kayıt tamamlandı';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMsg),
          backgroundColor: AppColors.duzceGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      // Reset
      context.read<ProductionCounterCubit>().clearAll();
      setState(() {
        _amountController.text = '1';
        _productCodeController.clear();
        _customerNameController.clear();
        _paletNoController.clear();
        _aciklamaController.clear();
        _productName = '';
        _productType = '';
        _selectedProductId = null;
      });
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Helpers ---

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
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
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
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

    if (hurdaLogs.isEmpty) {
      return [_buildSummaryChip('${state.hurda} Hurda', AppColors.error)];
    }

    // Hata nedenlerine göre grupla
    final Map<String, int> errorCounts = {};
    for (final log in hurdaLogs) {
      final reason = log.scrapReason ?? 'Bilinmeyen';
      errorCounts[reason] = (errorCounts[reason] ?? 0) + log.quantity;
    }

    final List<Widget> chips = [];
    errorCounts.forEach((reason, count) {
      chips.add(_buildSummaryChip('$count adet $reason', AppColors.error));
    });

    return chips;
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
              case 'paketlenen':
                logColor = AppColors.success;
                logIcon = LucideIcons.package;
                actionText = 'Paketlenen Eklendi';
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
