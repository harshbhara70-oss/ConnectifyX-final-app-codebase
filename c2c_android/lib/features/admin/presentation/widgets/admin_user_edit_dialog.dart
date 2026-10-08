import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/admin_user_models.dart';

class AdminUserEditDialog extends StatefulWidget {
  final dynamic userModel;
  final UserRoleTab role;
  final Function(Map<String, dynamic>) onSave;

  const AdminUserEditDialog({
    super.key,
    required this.userModel,
    required this.role,
    required this.onSave,
  });

  static void show(
    BuildContext context, {
    required dynamic userModel,
    required UserRoleTab role,
    required Function(Map<String, dynamic>) onSave,
  }) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AdminUserEditDialog(
        userModel: userModel,
        role: role,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AdminUserEditDialog> createState() => _AdminUserEditDialogState();
}

class _AdminUserEditDialogState extends State<AdminUserEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Student specific
  late TextEditingController _collegeController;
  late TextEditingController _branchController;
  late TextEditingController _cgpaController;
  String _placementStatus = 'Seeking';

  // College specific
  late TextEditingController _universityController;
  late TextEditingController _cityController;
  late TextEditingController _websiteController;

  // Recruiter specific
  late TextEditingController _companyController;
  late TextEditingController _designationController;
  late TextEditingController _linkedinController;

  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    if (widget.role == UserRoleTab.students && widget.userModel is AdminStudentModel) {
      final s = widget.userModel as AdminStudentModel;
      _nameController = TextEditingController(text: s.name);
      _emailController = TextEditingController(text: s.email);
      _phoneController = TextEditingController(text: s.phone);
      _collegeController = TextEditingController(text: s.college);
      _branchController = TextEditingController(text: s.branch);
      _cgpaController = TextEditingController(text: s.cgpa);
      _placementStatus = s.placementStatus;
      _status = s.activeStatus;
    } else if (widget.role == UserRoleTab.colleges && widget.userModel is AdminCollegeModel) {
      final c = widget.userModel as AdminCollegeModel;
      _nameController = TextEditingController(text: c.name);
      _emailController = TextEditingController(text: c.email);
      _phoneController = TextEditingController(text: c.phone);
      _universityController = TextEditingController(text: c.university);
      _cityController = TextEditingController(text: c.city);
      _websiteController = TextEditingController(text: c.website);
      _status = c.status;
    } else if (widget.role == UserRoleTab.recruiters && widget.userModel is AdminRecruiterModel) {
      final r = widget.userModel as AdminRecruiterModel;
      _nameController = TextEditingController(text: r.name);
      _emailController = TextEditingController(text: r.email);
      _phoneController = TextEditingController(text: r.phone);
      _companyController = TextEditingController(text: r.company);
      _designationController = TextEditingController(text: r.designation);
      _linkedinController = TextEditingController(text: r.linkedin);
      _status = r.status;
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    if (widget.role == UserRoleTab.students) {
      _collegeController.dispose();
      _branchController.dispose();
      _cgpaController.dispose();
    } else if (widget.role == UserRoleTab.colleges) {
      _universityController.dispose();
      _cityController.dispose();
      _websiteController.dispose();
    } else if (widget.role == UserRoleTab.recruiters) {
      _companyController.dispose();
      _designationController.dispose();
      _linkedinController.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'status': _status,
    };

    if (widget.role == UserRoleTab.students) {
      data['college'] = _collegeController.text.trim();
      data['branch'] = _branchController.text.trim();
      data['cgpa'] = _cgpaController.text.trim();
      data['placementStatus'] = _placementStatus;
    } else if (widget.role == UserRoleTab.colleges) {
      data['university'] = _universityController.text.trim();
      data['city'] = _cityController.text.trim();
      data['website'] = _websiteController.text.trim();
    } else if (widget.role == UserRoleTab.recruiters) {
      data['company'] = _companyController.text.trim();
      data['designation'] = _designationController.text.trim();
      data['linkedin'] = _linkedinController.text.trim();
    }

    widget.onSave(data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: clampDouble(screenWidth * 0.045, 12.0, 20.0),
        vertical: 20,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: screenHeight * 0.85,
        ),
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (RenderBox Safe)
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(LucideIcons.edit2, size: 18, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit ${widget.role.label.substring(0, widget.role.label.length - 1)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.045, 16.0, 18.0),
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Update directory records & status',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: clampDouble(screenWidth * 0.030, 11.0, 12.0),
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.x, size: 18, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.border, height: 1, thickness: 0.8),
              const SizedBox(height: 12),

              // Scrollable Inputs
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: keyboardInset > 0 ? 10 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'Full Name / Title',
                        controller: _nameController,
                        icon: LucideIcons.user,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        label: 'Email Address',
                        controller: _emailController,
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        icon: LucideIcons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),

                      // Role Specific Fields
                      if (widget.role == UserRoleTab.students) ...[
                        _buildTextField(
                          label: 'College / University',
                          controller: _collegeController,
                          icon: LucideIcons.building,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          label: 'Branch / Specialization',
                          controller: _branchController,
                          icon: LucideIcons.bookOpen,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          label: 'CGPA / Grade (e.g., 8.9)',
                          controller: _cgpaController,
                          icon: LucideIcons.award,
                        ),
                        const SizedBox(height: 10),
                        _buildDropdownField(
                          label: 'Placement Status',
                          value: _placementStatus,
                          items: const [
                            DropdownMenuItem(value: 'Placed', child: Text('Placed')),
                            DropdownMenuItem(value: 'Seeking', child: Text('Seeking')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _placementStatus = val);
                          },
                        ),
                        const SizedBox(height: 10),
                      ] else if (widget.role == UserRoleTab.colleges) ...[
                        _buildTextField(
                          label: 'Affiliated University',
                          controller: _universityController,
                          icon: LucideIcons.landmark,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          label: 'City & State',
                          controller: _cityController,
                          icon: LucideIcons.mapPin,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          label: 'Website Link',
                          controller: _websiteController,
                          icon: LucideIcons.globe,
                        ),
                        const SizedBox(height: 10),
                      ] else if (widget.role == UserRoleTab.recruiters) ...[
                        _buildTextField(
                          label: 'Company / Organization',
                          controller: _companyController,
                          icon: LucideIcons.building2,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          label: 'Job Designation',
                          controller: _designationController,
                          icon: LucideIcons.userCheck,
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          label: 'LinkedIn Profile URL',
                          controller: _linkedinController,
                          icon: LucideIcons.linkedin,
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Status Selector
                      _buildDropdownField(
                        label: 'Directory Active Status',
                        value: _status,
                        items: const [
                          DropdownMenuItem(value: 'Active', child: Text('Active')),
                          DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                          DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Action Buttons Tier
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border, width: 0.8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _submit();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              prefixIcon: Icon(icon, size: 16, color: AppColors.textMuted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    final validValue = items.any((i) => i.value == value) ? value : items.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: validValue,
              isExpanded: true,
              icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
