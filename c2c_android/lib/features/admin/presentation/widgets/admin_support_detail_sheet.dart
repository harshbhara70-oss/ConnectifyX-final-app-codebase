import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_support_models.dart';

/// Modal Bottom Sheet matching the web SupportCenter.tsx Right-Column Ticket Inspector
/// Engineered for zero RenderBox overflows, safe Android navigation insets,
/// 120Hz smooth scrolling, and instant reactive state updates.
class AdminSupportDetailSheet extends StatefulWidget {
  final AdminSupportTicketModel ticket;
  final Function(String message, bool isInternalNote) onSendReply;
  final VoidCallback onToggleResolve;
  final Function(String assignee) onAssign;

  const AdminSupportDetailSheet({
    super.key,
    required this.ticket,
    required this.onSendReply,
    required this.onToggleResolve,
    required this.onAssign,
  });

  static Future<void> show(
    BuildContext context, {
    required AdminSupportTicketModel ticket,
    required Function(String message, bool isInternalNote) onSendReply,
    required VoidCallback onToggleResolve,
    required Function(String assignee) onAssign,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminSupportDetailSheet(
        ticket: ticket,
        onSendReply: onSendReply,
        onToggleResolve: onToggleResolve,
        onAssign: onAssign,
      ),
    );
  }

  @override
  State<AdminSupportDetailSheet> createState() => _AdminSupportDetailSheetState();
}

class _AdminSupportDetailSheetState extends State<AdminSupportDetailSheet> {
  final TextEditingController _replyController = TextEditingController();
  bool _isInternalNote = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _showAssigneePicker(BuildContext context) {
    HapticFeedback.lightImpact();
    final assignees = [
      'Admin Staff',
      'SecOps Team',
      'Dev Team',
      'College Coordinator',
      'Dispute Board',
    ];

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final bottomPad = MediaQuery.paddingOf(ctx).bottom;
        return SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: bottomPad > 0 ? bottomPad + 12 : 20,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assign Ticket',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...assignees.map((assignee) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.userCheck, size: 16, color: Color(0xFF6D28D9)),
                        ),
                        title: Text(
                          assignee,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: widget.ticket.assignedTo == assignee
                            ? const Icon(LucideIcons.check, size: 18, color: Color(0xFF6D28D9))
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          widget.onAssign(assignee);
                        },
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _insertTemplate(String templateText) {
    HapticFeedback.lightImpact();
    setState(() {
      _replyController.text = templateText;
    });
  }

  void _showTemplatesPicker(BuildContext context) {
    HapticFeedback.lightImpact();
    final templates = [
      {
        'title': 'Salary Mismatch Resolution',
        'text': 'Hello,\n\nWe have reviewed the signed offer letter and verified with the employer. The offer details have now been updated in the portal. Please re-check and confirm.',
      },
      {
        'title': 'API Key Rotation Acknowledgment',
        'text': 'Hello IT Team,\n\nThe production OAuth2 secret has been regenerated and dispatched securely to your registered admin email address.',
      },
      {
        'title': 'Export Error Hotfix',
        'text': 'Hello Coordinator,\n\nThe batch timeout issue has been resolved. Please try triggering the bulk verification export again.',
      },
    ];

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final bottomPad = MediaQuery.paddingOf(ctx).bottom;
        return SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: bottomPad > 0 ? bottomPad + 12 : 20,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quick Response Templates',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...templates.map((tpl) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: ListTile(
                          title: Text(
                            tpl['title']!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6D28D9),
                            ),
                          ),
                          subtitle: Text(
                            tpl['text']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            _insertTemplate(tpl['text']!);
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final bottomPadding = mediaQuery.padding.bottom;
    final isResolved = widget.ticket.status == 'resolved';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Drag Handle
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Ticket Header & Action Buttons
                    _buildHeaderAndActions(context, isResolved: isResolved),
                    const SizedBox(height: 12),

                    // 2. Requester Metadata & SLA Grid (4 boxes)
                    _buildMetadataGrid(screenWidth),
                    const SizedBox(height: 14),

                    // 3. Message Thread
                    _buildMessageThread(),
                    const SizedBox(height: 12),

                    // 4. Automated System Check Pill (if dispute)
                    if (widget.ticket.type.toLowerCase().contains('dispute') || widget.ticket.id == 'TCK-8921')
                      _buildSystemCheckPill(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Reply Composition Box with Safe Keyboard Insets & Android navigation button protection
            _buildReplyBox(
              context,
              bottomInset: bottomInset,
              bottomPadding: bottomPadding,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderAndActions(BuildContext context, {required bool isResolved}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Badges Row with Wrap protection to prevent ANY right overflow
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '#${widget.ticket.id}',
                    style: GoogleFonts.firaCode(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.ticket.priority.contains('Critical')
                          ? const Color(0xFFFEF2F2)
                          : (widget.ticket.priority.contains('Escalated')
                              ? const Color(0xFFFFFBEB)
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.ticket.priority.contains('Critical')
                            ? const Color(0xFFFECACA)
                            : (widget.ticket.priority.contains('Escalated')
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFE2E8F0)),
                        width: 0.6,
                      ),
                    ),
                    child: Text(
                      widget.ticket.priority.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: widget.ticket.priority.contains('Critical')
                            ? const Color(0xFFEF4444)
                            : (widget.ticket.priority.contains('Escalated')
                                ? const Color(0xFFD97706)
                                : AppColors.textSecondary),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFDDD6FE), width: 0.6),
                    ),
                    child: Text(
                      widget.ticket.type.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Title
        Text(
          widget.ticket.title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 10),

        // Action Buttons Row (Assign + Resolve)
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _showAssigneePicker(context),
              icon: const Icon(LucideIcons.userCheck, size: 13, color: AppColors.textPrimary),
              label: Text(
                widget.ticket.assignedTo != null ? widget.ticket.assignedTo! : 'Assign',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onToggleResolve();
              },
              icon: Icon(
                isResolved ? LucideIcons.checkCircle2 : LucideIcons.check,
                size: 13,
              ),
              label: Text(
                isResolved ? 'Resolved' : 'Resolve Ticket',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isResolved ? const Color(0xFF059669) : const Color(0xFF6D28D9),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataGrid(double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: screenWidth < 360 ? 2.3 : 2.7,
        children: [
          _buildMetaBox('REQUESTER', widget.ticket.requester, isBold: true),
          _buildMetaBox('ORGANIZATION', widget.ticket.organization, isBold: true),
          _buildMetaBox('CREATED', widget.ticket.created, isMono: true),
          _buildMetaBox(
            'SLA TARGET',
            widget.ticket.sla,
            isMono: true,
            customColor: widget.ticket.sla.contains('remaining') ? const Color(0xFFEF4444) : const Color(0xFF6D28D9),
            showClock: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaBox(
    String label,
    String value, {
    bool isBold = false,
    bool isMono = false,
    Color? customColor,
    bool showClock = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 1),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showClock) ...[
              Icon(LucideIcons.clock, size: 10, color: customColor ?? AppColors.textPrimary),
              const SizedBox(width: 2),
            ],
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isMono
                    ? GoogleFonts.firaCode(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        color: customColor ?? AppColors.textPrimary,
                      )
                    : GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                        color: customColor ?? AppColors.textPrimary,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageThread() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.ticket.messages.map((msg) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: msg.isInternalNote ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: msg.isInternalNote ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message Header Row with Expanded protection against overflow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEDE9FE),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              msg.senderName.isNotEmpty ? msg.senderName[0] : 'U',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF6D28D9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.senderName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                msg.senderRole,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    msg.timestamp,
                    style: GoogleFonts.firaCode(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                msg.content,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Attachment pill
              if (msg.attachmentName != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Downloading ${msg.attachmentName}...'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.paperclip, size: 13, color: Color(0xFF6D28D9)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            msg.attachmentName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (msg.attachmentSize != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${msg.attachmentSize})',
                            style: GoogleFonts.firaCode(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.download, size: 12, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSystemCheckPill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDD6FE), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.shieldCheck, size: 13, color: Color(0xFF6D28D9)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                'Automated System Check: Offer ID #89214 Verified',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6D28D9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBox(
    BuildContext context, {
    required double bottomInset,
    required double bottomPadding,
  }) {
    final effectiveBottom = bottomInset > 0
        ? bottomInset + 10.0
        : (bottomPadding > 0 ? bottomPadding + 10.0 : 16.0);

    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 8,
        bottom: effectiveBottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toolbar: Formatting + Templates + Internal Note
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildFormatBtn('B', FontWeight.w900),
                  const SizedBox(width: 4),
                  _buildFormatBtn('I', FontWeight.normal, isItalic: true),
                  const SizedBox(width: 4),
                  _buildFormatBtn('• List', FontWeight.w700),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _showTemplatesPicker(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Templates',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6D28D9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isInternalNote = !_isInternalNote);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: Checkbox(
                            value: _isInternalNote,
                            onChanged: (val) {
                              setState(() => _isInternalNote = val ?? false);
                            },
                            activeColor: const Color(0xFF6D28D9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Internal Note',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Input Row + Send Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  maxLines: 3,
                  minLines: 1,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: _isInternalNote ? 'Write an internal staff note...' : 'Type your reply here...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    filled: true,
                    fillColor: _isInternalNote ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _isInternalNote ? const Color(0xFFFDE68A) : AppColors.border,
                        width: 0.8,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _isInternalNote ? const Color(0xFFFDE68A) : AppColors.border,
                        width: 0.8,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF6D28D9),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () {
                  final text = _replyController.text.trim();
                  if (text.isEmpty) return;
                  HapticFeedback.lightImpact();
                  widget.onSendReply(text, _isInternalNote);
                  _replyController.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D28D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Icon(LucideIcons.send, size: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatBtn(String label, FontWeight weight, {bool isItalic = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.0,
          fontWeight: weight,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
