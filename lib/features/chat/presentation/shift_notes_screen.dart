import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../auth/presentation/login_screen.dart';
import '../../forms/presentation/forms_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class ShiftNotesScreen extends StatefulWidget {
  const ShiftNotesScreen({super.key});

  @override
  State<ShiftNotesScreen> createState() => _ShiftNotesScreenState();
}

class _ShiftNotesScreenState extends State<ShiftNotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _operatorName = 'Furkan Yılmaz';

  // Örnek Mesajlar
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Ahmet Yılmaz',
      'message': 'Vardiya devri sorunsuz tamamlandı.',
      'time': '07:55',
      'isMe': false,
      'color': Colors.blue,
    },
    {
      'sender': 'Mehmet Demir',
      'message':
          '3 numaralı enjeksiyonda hammadde azalıyor, takviye lazım. Depodaki arkadaşlara ilettim ama henüz dönüş olmadı.',
      'time': '09:15',
      'isMe': false,
      'color': Colors.orange,
    },
    {
      'sender': 'Ali Kaya',
      'message': 'Kalite kontrol numuneleri hazır mı?',
      'time': '10:30',
      'isMe': false,
      'color': Colors.purple,
    },
    {
      'sender': 'Furkan Yılmaz',
      'message': 'Evet, laboratuvara gönderildi.',
      'time': '10:32',
      'isMe': true,
      'color': AppColors.primary,
    },
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'Furkan Yılmaz',
        'message': _controller.text,
        'time':
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'isMe': true,
        'color': AppColors.primary,
      });
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                operatorInitial: _operatorName.isNotEmpty
                    ? _operatorName[0]
                    : 'F',
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
                            Text(
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
                              child: Icon(
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
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(24),
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final msg = _messages[index];
                                  final isMe = msg['isMe'] as bool;

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
                                                (msg['color'] as Color)
                                                    .withValues(alpha: 0.2),
                                            child: Text(
                                              (msg['sender'] as String)[0],
                                              style: TextStyle(
                                                color: msg['color'],
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
                                                          bottom: 2,
                                                        ),
                                                    child: Text(
                                                      msg['sender'],
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.8,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                Text(
                                                  msg['message'],
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
                                                    msg['time'],
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
                              ),
                            ),
                            // Input Alanı
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
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
                                      style: TextStyle(
                                        color: AppColors.textMain,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Mesajınızı yazın...',
                                        hintStyle: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide(
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
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: _sendMessage,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
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
