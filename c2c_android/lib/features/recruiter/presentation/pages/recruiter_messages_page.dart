import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/recruiter_messages_bloc.dart';
import '../../data/models/recruiter_message_model.dart';
import '../widgets/recruiter_side_nav.dart';

class RecruiterMessagesPage extends StatelessWidget {
  const RecruiterMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecruiterMessagesBloc()..add(const FetchMessagesEvent()),
      child: const _RecruiterMessagesView(),
    );
  }
}

class _RecruiterMessagesView extends StatefulWidget {
  const _RecruiterMessagesView();

  @override
  State<_RecruiterMessagesView> createState() => _RecruiterMessagesViewState();
}

class _RecruiterMessagesViewState extends State<_RecruiterMessagesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStartMessageSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final bloc = context.read<RecruiterMessagesBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _StartMessageSheet(
        onSendMessage: (name, role, message) {
          bloc.add(StartConversationEvent(
            candidateName: name,
            role: role,
            firstMessage: message,
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bottomInset = mediaQuery.padding.bottom;
    final hPad = clampDouble(screenWidth * 0.045, 12.0, 20.0);
    final headerSize = clampDouble(screenWidth * 0.052, 18.0, 22.0);
    final subtitleSize = clampDouble(screenWidth * 0.033, 12.0, 14.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RecruiterSideNav(highlightRoute: '/recruiter/messages'),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<RecruiterMessagesBloc, RecruiterMessagesState>(
          listener: (context, state) {
            if (state is RecruiterMessagesLoaded && state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.successMessage!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is RecruiterMessagesLoading || state is RecruiterMessagesInitial) {
              return _buildLoadingState(headerSize, hPad);
            }

            if (state is RecruiterMessagesError) {
              return _buildErrorState(context, state.message, hPad);
            }

            if (state is! RecruiterMessagesLoaded) {
              return const SizedBox.shrink();
            }

            final isMock = state.isMock;
            final selected = state.selectedConversation;

            // If a conversation is selected on mobile view, render the Active Chat Screen
            if (selected != null) {
              return _ActiveChatView(
                conversation: selected,
                onBack: () {
                  HapticFeedback.lightImpact();
                  context.read<RecruiterMessagesBloc>().add(const ClearSelectedConversationEvent());
                },
                onSendReply: (text) {
                  context.read<RecruiterMessagesBloc>().add(
                        SendMessageEvent(
                          conversationId: selected.id,
                          text: text,
                        ),
                      );
                },
              );
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context.read<RecruiterMessagesBloc>().add(const FetchMessagesEvent());
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.only(
                  left: hPad,
                  right: hPad,
                  top: 14.0,
                  bottom: bottomInset == 0 ? 20.0 : bottomInset + 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- App Bar / Top Navigation Bar ---
                    _buildTopAppBar(context, headerSize, isMock),
                    const SizedBox(height: 12),

                    // --- Subtitle Banner ---
                    Text(
                      'Communicate directly with candidates and coordinate interview schedules.',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Action Bar: Search Input + Start Message Button ---
                    _buildSearchBar(context, screenWidth),
                    const SizedBox(height: 16),

                    // --- Main Card / Conversations List ---
                    _buildConversationsSection(context, state, screenWidth, screenHeight),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, double headerSize, bool isMock) {
    return Builder(
      builder: (innerContext) {
        return Row(
          children: [
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                Scaffold.of(innerContext).openDrawer();
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.menu, size: 20, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Messages',
                    style: TextStyle(
                      fontSize: headerSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (isMock) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '*',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            InkWell(
              onTap: () => _openStartMessageSheet(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5E17EB), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5E17EB).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'New Message',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        onChanged: (val) {
          context.read<RecruiterMessagesBloc>().add(SearchMessagesEvent(val));
        },
        decoration: InputDecoration(
          hintText: 'Search messages by candidate or role...',
          hintStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    context.read<RecruiterMessagesBloc>().add(const SearchMessagesEvent(''));
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildConversationsSection(
    BuildContext context,
    RecruiterMessagesLoaded state,
    double screenWidth,
    double screenHeight,
  ) {
    final list = state.filteredConversations;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.messageSquare, size: 24, color: Color(0xFF5E17EB)),
            ),
            const SizedBox(height: 14),
            const Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Start a new message to contact candidates and coordinate interviews.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => _openStartMessageSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E17EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text(
                'Start Message',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
        itemBuilder: (ctx, idx) {
          final item = list[idx];
          return _ConversationListTile(
            item: item,
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<RecruiterMessagesBloc>().add(SelectConversationEvent(item));
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(double headerSize, double hPad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 12),
              Container(width: 120, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, _) => Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, double hPad) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, color: Color(0xFFEF4444), size: 44),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<RecruiterMessagesBloc>().add(const FetchMessagesEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Conversation List Tile Widget ---
class _ConversationListTile extends StatelessWidget {
  final RecruiterConversationItem item;
  final VoidCallback onTap;

  const _ConversationListTile({
    required this.item,
    required this.onTap,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'C';
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(item.candidateName);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with initials
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5E17EB), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            item.candidateName,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.time,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.role,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5E17EB),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.lastMessage,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Active Chat View / Sub-Screen ---
class _ActiveChatView extends StatefulWidget {
  final RecruiterConversationItem conversation;
  final VoidCallback onBack;
  final ValueChanged<String> onSendReply;

  const _ActiveChatView({
    required this.conversation,
    required this.onBack,
    required this.onSendReply,
  });

  @override
  State<_ActiveChatView> createState() => _ActiveChatViewState();
}

class _ActiveChatViewState extends State<_ActiveChatView> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    widget.onSendReply(text);
    _msgController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final paddingBottom = mediaQuery.padding.bottom;
    final hPad = clampDouble(mediaQuery.size.width * 0.045, 12.0, 20.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary),
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversation.candidateName,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              widget.conversation.role,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 14),
              itemCount: widget.conversation.messages.length,
              itemBuilder: (ctx, idx) {
                final msg = widget.conversation.messages[idx];
                final isMe = msg.isMe;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: BoxConstraints(
                      maxWidth: mediaQuery.size.width * 0.78,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isMe
                          ? const LinearGradient(
                              colors: [Color(0xFF5E17EB), Color(0xFF7C3AED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isMe ? null : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: isMe ? const Radius.circular(14) : const Radius.circular(2),
                        bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(14),
                      ),
                      border: isMe ? null : Border.all(color: AppColors.border, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: isMe ? Colors.white : AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg.time,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w400,
                            color: isMe ? Colors.white.withValues(alpha: 0.75) : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Input Bar
          Container(
            padding: EdgeInsets.only(
              left: hPad,
              right: hPad,
              top: 10,
              bottom: bottomInset > 0 ? bottomInset + 8 : (paddingBottom == 0 ? 12 : paddingBottom),
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _handleSend,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E17EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.send, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Start New Candidate Message Bottom Sheet ---
class _StartMessageSheet extends StatefulWidget {
  final void Function(String name, String role, String firstMessage) onSendMessage;

  const _StartMessageSheet({required this.onSendMessage});

  @override
  State<_StartMessageSheet> createState() => _StartMessageSheetState();
}

class _StartMessageSheetState extends State<_StartMessageSheet> {
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _messageController = TextEditingController();

  String _nameError = '';
  String _roleError = '';
  String _generalError = '';

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onNameChanged(String val) {
    if (RegExp(r'[0-9]').hasMatch(val)) {
      setState(() {
        _nameError = 'Numbers are not allowed in Candidate Name';
      });
    } else {
      if (_nameError.isNotEmpty) {
        setState(() {
          _nameError = '';
        });
      }
    }
  }

  void _onRoleChanged(String val) {
    if (RegExp(r'[0-9]').hasMatch(val)) {
      setState(() {
        _roleError = 'Numbers are not allowed in Job Title / Role';
      });
    } else {
      if (_roleError.isNotEmpty) {
        setState(() {
          _roleError = '';
        });
      }
    }
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final role = _roleController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || role.isEmpty || message.isEmpty) {
      setState(() {
        _generalError = 'Please fill out all required fields.';
      });
      return;
    }

    if (RegExp(r'[0-9]').hasMatch(name)) {
      setState(() {
        _nameError = 'Numbers are not allowed in Candidate Name';
      });
      return;
    }

    if (RegExp(r'[0-9]').hasMatch(role)) {
      setState(() {
        _roleError = 'Numbers are not allowed in Job Title / Role';
      });
      return;
    }

    setState(() {
      _generalError = '';
    });

    widget.onSendMessage(name, role, message);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bottomInset = mediaQuery.viewInsets.bottom;
    final systemBottomPadding = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : mediaQuery.padding.bottom;
    final hPad = clampDouble(screenWidth * 0.048, 14.0, 20.0);
    final vPad = clampDouble(screenHeight * 0.018, 12.0, 18.0);
    final titleSize = clampDouble(screenWidth * 0.044, 15.0, 18.0);
    final labelSize = clampDouble(screenWidth * 0.033, 11.5, 13.0);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.90,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          bottom: bottomInset == 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal Header (Always visible)
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Start New Candidate Message',
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // Scrollable Form Body (Butterly smooth on soft keyboard popup)
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    14,
                    hPad,
                    vPad + (bottomInset > 0 ? 12.0 : (systemBottomPadding > 0 ? 14.0 : 20.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_generalError.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.alertTriangle, size: 16, color: Color(0xFFE11D48)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _generalError,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE11D48),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Field 1: Candidate Name
                    Row(
                      children: [
                        Text(
                          'Candidate Name',
                          style: TextStyle(
                            fontSize: labelSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('*', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      onChanged: _onNameChanged,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\.\-']")),
                      ],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'e.g. Priya Sharma (Letters only)',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF5E17EB), width: 1.5),
                        ),
                      ),
                    ),
                    if (_nameError.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.alertTriangle, size: 13, color: Color(0xFFE11D48)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _nameError,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE11D48)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 2),
                    const Text(
                      'Numbers (0-9) are strictly prohibited in Candidate Name.',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Field 2: Job Title / Position
                    Row(
                      children: [
                        Text(
                          'Job Title / Position',
                          style: TextStyle(
                            fontSize: labelSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('*', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _roleController,
                      onChanged: _onRoleChanged,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\.\-']")),
                      ],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'e.g. Software Engineer (Letters only)',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF5E17EB), width: 1.5),
                        ),
                      ),
                    ),
                    if (_roleError.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.alertTriangle, size: 13, color: Color(0xFFE11D48)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _roleError,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFE11D48)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 2),
                    const Text(
                      'Numbers (0-9) are strictly prohibited in Job Title field.',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),

                    // Field 3: Initial Message
                    Row(
                      children: [
                        Text(
                          'Initial Message',
                          style: TextStyle(
                            fontSize: labelSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('*', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Write your message or interview invite...',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF5E17EB), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Actions: Cancel + Send Message
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E17EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          child: const Text('Send Message', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
