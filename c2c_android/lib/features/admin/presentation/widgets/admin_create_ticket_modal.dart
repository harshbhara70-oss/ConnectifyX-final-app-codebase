import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';

/// Modal bottom sheet for creating a new support ticket / dispute record
/// Features Form validation, responsive keyboard insets, and zero-overflow RenderBox safety.
class AdminCreateTicketModal extends StatefulWidget {
  final Function(Map<String, dynamic> data) onSubmit;

  const AdminCreateTicketModal({
    super.key,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(Map<String, dynamic> data) onSubmit,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminCreateTicketModal(onSubmit: onSubmit),
    );
  }

  @override
  State<AdminCreateTicketModal> createState() => _AdminCreateTicketModalState();
}

class _AdminCreateTicketModalState extends State<AdminCreateTicketModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _requesterController = TextEditingController(text: 'Admin Staff');
  final _orgController = TextEditingController(text: 'Campus2Corporate');
  final _descController = TextEditingController();

  String _selectedPriority = 'Critical Priority';
  String _selectedType = 'Dispute';

  @override
  void dispose() {
    _titleController.dispose();
    _requesterController.dispose();
    _orgController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final data = {
      'title': _titleController.text.trim(),
      'requester': _requesterController.text.trim(),
      'organization': _orgController.text.trim(),
      'priority': _selectedPriority,
      'type': _selectedType,
      'description': _descController.text.trim(),
    };

    widget.onSubmit(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

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
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: bottomInset > 0 ? bottomInset + 16.0 : 16.0,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
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
                  const SizedBox(height: 14),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Support Ticket',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 19, color: AppColors.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title Field
                  _buildLabel('TICKET TITLE'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a ticket title' : null,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary),
                    decoration: _inputDecoration('e.g. Placement Offer Dispute - Salary Mismatch'),
                  ),
                  const SizedBox(height: 14),

                  // Category & Priority Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('TYPE'),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border, width: 0.8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedType,
                                  isExpanded: true,
                                  icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  items: ['Dispute', 'Request', 'System Issue', 'General Inquiry'].map((t) {
                                    return DropdownMenuItem(value: t, child: Text(t));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedType = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('PRIORITY'),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border, width: 0.8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPriority,
                                  isExpanded: true,
                                  icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textSecondary),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  items: ['Critical Priority', 'Escalated', 'Standard'].map((p) {
                                    return DropdownMenuItem(value: p, child: Text(p));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedPriority = val);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Requester & Organization Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('REQUESTER'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _requesterController,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textPrimary),
                              decoration: _inputDecoration('Requester name'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ORGANIZATION'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _orgController,
                              style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textPrimary),
                              decoration: _inputDecoration('Organization / College'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Description
                  _buildLabel('ISSUE DETAILS / DESCRIPTION'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please describe the inquiry' : null,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textPrimary),
                    decoration: _inputDecoration('Explain the dispute or support inquiry details...'),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleSubmit,
                      icon: const Icon(LucideIcons.plusCircle, size: 16),
                      label: Text(
                        'Create Ticket',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D28D9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: AppColors.textMuted,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 0.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6D28D9), width: 1.2),
      ),
    );
  }
}
