import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../auth/presentation/login_screen.dart';
import '../../forms/presentation/forms_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import 'providers/shift_notes_providers.dart';

class ShiftNotesScreen extends ConsumerStatefulWidget {
  const ShiftNotesScreen({super.key});

  @override
  ConsumerState<ShiftNotesScreen> createState() => _ShiftNotesScreenState();
}

class _ShiftNotesScreenState extends ConsumerState<ShiftNotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final repository = ref.read(vardiyaNotlariRepositoryProvider);
      // Example: Title is empty or predefined, priority is 1
      await repository.createVardiyaNotu('Vardiya Notu', text, 1);
      
      _controller.clear();
      // Refresh the list
      ref.invalidate(vardiyaNotlariProvider);
      
      // Attempt to scroll to bottom after refreshing
      Future.delayed(const Duration(milliseconds: 500), _scrollToBottom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not gönderilemedi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current user context
    final currentUserAsync = ref.watch(currentUserProvider);
    final userFullName = currentUserAsync.value?.fullName ?? 'Operatör';
    final notesAsync = ref.watch(vardiyaNotlariProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Arka Plan Görseli
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.black.withValues(alpha: 0.6)),
              ),
            ),
          ),
          // Ön Plan İçerik
          Row(
            children: [
              SidebarNavigation(
                selectedIndex: 3, // Vardiya Notları
                onItemSelected: (index) {
                  if (index == 0) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else if (index == 1) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const FormsScreen()),
                    );
                  } else if (index == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  } else if (index == 4) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }
                },
                operatorInitial: userFullName.isNotEmpty ? userFullName[0] : 'O',
                onLogout: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        height: 72,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Vardiya Notları & Chat',
                              style: TextStyle(
                                color: AppColors.textMain,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                LucideIcons.users,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Chat Alanı
                      Expanded(
                        child: Column(
                          children: [
                            // Mesaj Listesi
                            Expanded(
                              child: notesAsync.when(
                                data: (messages) {
                                  if (messages.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Henüz not eklenmemiş.',
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                    );
                                  }

                                  // Otomatik scroll için Future.microtask
                                  Future.microtask(() {
                                    if (_scrollController.hasClients && _scrollController.position.pixels == 0) {
                                       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                                    }
                                  });

                                  return ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(24),
                                    itemCount: messages.length,
                                    itemBuilder: (context, index) {
                                      final msg = messages[index];
                                      // If personelAdi is empty, fallback to kullaniciAdi
                                      final senderName = (msg.personelAdi.isNotEmpty)
                                          ? msg.personelAdi
                                          : msg.kullaniciAdi;
                                          
                                      final isMe = senderName == userFullName;
                                      
                                      // Basit renk seçimi
                                      final Color avatarColor = isMe ? AppColors.primary : Colors.blueGrey;

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          mainAxisAlignment: isMe
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (!isMe) ...[
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor:
                                                    avatarColor.withValues(alpha: 0.2),
                                                child: Text(
                                                  senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                                                  style: TextStyle(
                                                    color: avatarColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Flexible(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 10,
                                                ),
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.7,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isMe
                                                      ? AppColors.primary
                                                      : AppColors.surface,
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: const Radius.circular(
                                                      12,
                                                    ),
                                                    topRight: const Radius.circular(
                                                      12,
                                                    ),
                                                    bottomLeft: isMe
                                                        ? const Radius.circular(12)
                                                        : Radius.zero,
                                                    bottomRight: isMe
                                                        ? Radius.zero
                                                        : const Radius.circular(12),
                                                  ),
                                                  border: isMe
                                                      ? null
                                                      : Border.all(
                                                          color:
                                                              AppColors.glassBorder,
                                                        ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (!isMe)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              bottom: 4,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // Primary: personelAdi (real name)
                                                            Text(
                                                              msg.personelAdi.isNotEmpty
                                                                  ? msg.personelAdi
                                                                  : msg.kullaniciAdi,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                color: Colors.white
                                                                    .withValues(
                                                                      alpha: 0.9,
                                                                    ),
                                                              ),
                                                            ),
                                                            // Secondary: @kullaniciAdi — only shown when different from personelAdi
                                                            if (msg.personelAdi.isNotEmpty &&
                                                                msg.kullaniciAdi.isNotEmpty &&
                                                                msg.personelAdi != msg.kullaniciAdi)
                                                              Text(
                                                                '@${msg.kullaniciAdi}',
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .white
                                                                      .withValues(
                                                                        alpha:
                                                                            0.45,
                                                                      ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    Text(
                                                      msg.notMetni,
                                                      style: TextStyle(
                                                        color: isMe
                                                            ? Colors.white
                                                            : AppColors.textMain,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: Text(
                                                        DateFormat('HH:mm').format(msg.olusturmaZamani.toLocal()),
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: isMe
                                                              ? Colors.white
                                                                    .withValues(
                                                                      alpha: 0.7,
                                                                    )
                                                              : AppColors
                                                                    .textSecondary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (isMe) ...[const SizedBox(width: 8)],
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                                error: (error, StackTrace? stack) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 48),
                                        const SizedBox(height: 16),
                                        Text('Bir hata oluştu :\n$error', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () => ref.invalidate(vardiyaNotlariProvider),
                                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                                          label: const Text('Tekrar Dene'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              ),
                            ),
                            
                            // Input Alanı
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      style: const TextStyle(
                                        color: AppColors.textMain,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Mesajınızı yazın...',
                                        hintStyle: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: const BorderSide(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                        fillColor: AppColors.background
                                            .withValues(alpha: 0.5),
                                        filled: true,
                                      ),
                                      onSubmitted: (_) => _sendMessage(),
                                      enabled: !_isSending,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: _isSending ? null : _sendMessage,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _isSending ? AppColors.textSecondary : AppColors.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          if (!_isSending)
                                            BoxShadow(
                                              color: AppColors.primary.withValues(
                                                alpha: 0.4,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                        ],
                                      ),
                                      child: _isSending 
                                        ? const SizedBox(
                                            width: 18, 
                                            height: 18, 
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                          )
                                        : const Icon(
                                            LucideIcons.send,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
}

