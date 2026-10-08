import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../../../core/constants/app_colors.dart';
import '../../bloc/recruiter_settings_bloc.dart';
import '../../bloc/recruiter_settings_event.dart';
import '../../bloc/recruiter_settings_state.dart';
import '../../data/models/recruiter_settings_model.dart';
import '../widgets/recruiter_side_nav.dart';

class RecruiterSettingsPage extends StatelessWidget {
  const RecruiterSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecruiterSettingsBloc()..add(const FetchRecruiterSettingsEvent()),
      child: const _RecruiterSettingsView(),
    );
  }
}

class _RecruiterSettingsView extends StatefulWidget {
  const _RecruiterSettingsView();

  @override
  State<_RecruiterSettingsView> createState() => _RecruiterSettingsViewState();
}

class _RecruiterSettingsViewState extends State<_RecruiterSettingsView> {
  // Form Controllers
  late final TextEditingController _repNameController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _websiteController;
  late final TextEditingController _aboutController;

  String? _logoUrl;
  String _repNameError = '';
  Map<String, String> _errors = {};

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _repNameController = TextEditingController();
    _companyNameController = TextEditingController();
    _websiteController = TextEditingController();
    _aboutController = TextEditingController();
  }

  @override
  void dispose() {
    _repNameController.dispose();
    _companyNameController.dispose();
    _websiteController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _syncFromState(RecruiterSettingsModel settings) {
    if (!_initialized) {
      _repNameController.text = settings.repName;
      _companyNameController.text = settings.companyName;
      _websiteController.text = settings.websiteUrl;
      _aboutController.text = settings.aboutCompany;
      _logoUrl = settings.logoUrl;
      _initialized = true;
    }
  }

  void _onRepNameChanged(String val, bool isVerified) {
    if (isVerified) return;
    if (RegExp(r'[0-9]').hasMatch(val)) {
      setState(() {
        _repNameError = 'Numbers are not allowed in Name field';
      });
    } else {
      if (_repNameError.isNotEmpty) {
        setState(() {
          _repNameError = '';
        });
      }
    }
  }

  Future<void> _pickLogo(bool isVerified) async {
    if (isVerified) return;
    HapticFeedback.lightImpact();

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes != null) {
          final ext = file.extension ?? 'png';
          final base64String = 'data:image/$ext;base64,${base64Encode(bytes)}';
          setState(() {
            _logoUrl = base64String;
            _errors.remove('logo');
          });
        } else if (file.path != null) {
          setState(() {
            _logoUrl = file.path;
            _errors.remove('logo');
          });
        }
      }
    } catch (_) {
      // Fallback
    }
  }

  void _handleSave(BuildContext context, bool isVerified, String companyName) {
    HapticFeedback.mediumImpact();
    final bloc = context.read<RecruiterSettingsBloc>();

    if (isVerified) {
      bloc.add(RequestAdminEditEvent(companyName));
      return;
    }

    final newErrors = <String, String>{};
    if (_logoUrl == null || _logoUrl!.isEmpty) {
      newErrors['logo'] = 'Company Logo is mandatory for admin verification';
    }
    if (_repNameController.text.trim().isEmpty) {
      newErrors['repName'] = 'Representative Name is required';
    }
    if (_companyNameController.text.trim().isEmpty) {
      newErrors['companyName'] = 'Company Name is required';
    }
    if (_websiteController.text.trim().isEmpty) {
      newErrors['websiteUrl'] = 'Website URL is required';
    }
    if (_aboutController.text.trim().isEmpty) {
      newErrors['aboutCompany'] = 'About Company is required';
    }

    if (newErrors.isNotEmpty) {
      setState(() {
        _errors = newErrors;
      });
      return;
    }

    setState(() {
      _errors = {};
    });

    bloc.add(SaveRecruiterSettingsEvent(
      repName: _repNameController.text.trim(),
      companyName: _companyNameController.text.trim(),
      websiteUrl: _websiteController.text.trim(),
      aboutCompany: _aboutController.text.trim(),
      logoUrl: _logoUrl,
    ));
  }

  void _openInviteModal(BuildContext context) {
    HapticFeedback.lightImpact();
    final bloc = context.read<RecruiterSettingsBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => _InviteTeamMemberSheet(
        onInvite: (name, email, role) {
          bloc.add(InviteTeamMemberEvent(name: name, email: email, role: role));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RecruiterSideNav(highlightRoute: '/recruiter/settings'),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<RecruiterSettingsBloc, RecruiterSettingsState>(
          listener: (context, state) {
            if (state is RecruiterSettingsLoaded) {
              if (state.successMessage != null) {
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
              } else if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(LucideIcons.alertTriangle, color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
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
            }
          },
          builder: (context, state) {
            if (state is RecruiterSettingsLoading || state is RecruiterSettingsInitial) {
              return _buildLoadingState();
            }

            if (state is RecruiterSettingsError) {
              return _buildErrorState(context, state.message);
            }

            if (state is! RecruiterSettingsLoaded) {
              return const SizedBox.shrink();
            }

            _syncFromState(state.settings);

            final isVerified = state.isVerified;
            final isMock = state.isMock;
            final activeTab = state.activeTab;

            return RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.lightImpact();
                _initialized = false;
                context.read<RecruiterSettingsBloc>().add(const FetchRecruiterSettingsEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 14.0,
                  bottom: bottomInset == 0 ? 24.0 : bottomInset + 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- App Bar / Top Navigation Bar ---
                    _buildTopAppBar(context, isMock),
                    const SizedBox(height: 8),

                    // --- Subtitle Banner ---
                    const Text(
                      'Manage corporate branding, verification details, and account preferences.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // --- Header Category Tabs ---
                    _buildCategoryTabs(context, activeTab),
                    const SizedBox(height: 14),

                    // --- Active Tab Content ---
                    if (activeTab == 'company') ...[
                      _buildCompanyProfileTab(context, state, isVerified),
                    ] else if (activeTab == 'team') ...[
                      _buildTeamManagementTab(context, state),
                    ] else ...[
                      _buildNotificationsTab(context, state),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Top App Bar ---
  Widget _buildTopAppBar(BuildContext context, bool isMock) {
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
                  const Flexible(
                    child: Text(
                      'Company Settings',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
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
          ],
        );
      },
    );
  }

  // --- Category Tabs (Company Profile | Team Management | Notifications & Security) ---
  Widget _buildCategoryTabs(BuildContext context, String activeTab) {
    final tabs = [
      {'id': 'company', 'label': 'Company Profile', 'icon': LucideIcons.building},
      {'id': 'team', 'label': 'Team Management', 'icon': LucideIcons.users},
      {'id': 'notifications', 'label': 'Notifications', 'icon': LucideIcons.bell},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = activeTab == tab['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                context.read<RecruiterSettingsBloc>().add(ChangeSettingsTabEvent(tab['id']! as String));
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5E17EB) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF5E17EB) : AppColors.border,
                    width: 0.8,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: const Color(0xFF5E17EB).withValues(alpha: 0.22),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 14,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- TAB 1: Company Profile ---
  Widget _buildCompanyProfileTab(
    BuildContext context,
    RecruiterSettingsLoaded state,
    bool isVerified,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Onboarding Alert Banner (Only shown if unverified)
        if (!isVerified) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFEF3C7).withValues(alpha: 0.8),
                  const Color(0xFFEDE9FE).withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFCD34D), width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFBBF24)),
                  ),
                  child: const Icon(LucideIcons.building, size: 16, color: Color(0xFFB45309)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Recruiter Onboarding — Verification',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF78350F),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Fill in your corporate credentials and upload your company logo to submit your verification request to Admin.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF92400E),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Verification Status Badge Card
        _buildVerificationStatusCard(isVerified),
        const SizedBox(height: 14),

        // Corporate Identity Card
        Container(
          padding: const EdgeInsets.all(14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Lock Status Pill (Overflow-proof Wrap)
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  const Text(
                    'Corporate Identity',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.lock, size: 10, color: Color(0xFF059669)),
                          SizedBox(width: 4),
                          Text(
                            'LOCKED BY ADMIN (VERIFIED)',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text(
                      '* Mandatory fields',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // 1. Mandatory Logo Upload Section
              _buildLogoUploadSection(isVerified),
              const SizedBox(height: 16),

              // 2. Representative Name Field (Strictly NO numbers)
              _buildInputField(
                label: 'Company Representative Name',
                controller: _repNameController,
                hintText: 'FullName (Letters only)',
                isVerified: isVerified,
                isRequired: true,
                onChanged: (val) => _onRepNameChanged(val, isVerified),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\.\-']")),
                ],
                errorText: _repNameError.isNotEmpty ? _repNameError : _errors['repName'],
              ),
              const SizedBox(height: 12),

              // 3. Company Legal Entity Name Field
              _buildInputField(
                label: 'Company / Legal Entity Name',
                controller: _companyNameController,
                hintText: 'e.g. Lumina Nexus Tech Solutions',
                isVerified: isVerified,
                isRequired: true,
                errorText: _errors['companyName'],
              ),
              const SizedBox(height: 12),

              // 4. Official Website URL
              _buildInputField(
                label: 'Official Website URL',
                controller: _websiteController,
                hintText: 'https://company.com',
                keyboardType: TextInputType.url,
                isVerified: isVerified,
                isRequired: true,
                errorText: _errors['websiteUrl'],
              ),
              const SizedBox(height: 12),

              // 5. About Company Field
              _buildInputField(
                label: 'About Company',
                controller: _aboutController,
                hintText: 'Describe company operations, culture, and goals...',
                isVerified: isVerified,
                isRequired: true,
                maxLines: 4,
                errorText: _errors['aboutCompany'],
              ),
              const SizedBox(height: 18),

              // Action Button (Submit or Request Edit - Auto-scaling to prevent overflow)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSaving
                      ? null
                      : () => _handleSave(context, isVerified, _companyNameController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified ? const Color(0xFFF59E0B) : const Color(0xFF5E17EB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isVerified ? LucideIcons.send : LucideIcons.shieldCheck,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: AutoSizeText(
                                isVerified
                                    ? 'Request Admin Profile Edit'
                                    : 'Submit Profile for Admin Verification',
                                maxLines: 1,
                                minFontSize: 11,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Logo Upload Component ---
  Widget _buildLogoUploadSection(bool isVerified) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Company Logo',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            if (!isVerified) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _errors.containsKey('logo') ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _errors.containsKey('logo') ? const Color(0xFFFECDD3) : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              // Logo Preview
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF5E17EB),
                  borderRadius: BorderRadius.circular(12),
                  image: _logoUrl != null && _logoUrl!.isNotEmpty
                      ? (_logoUrl!.startsWith('http')
                          ? DecorationImage(image: NetworkImage(_logoUrl!), fit: BoxFit.cover)
                          : (_logoUrl!.startsWith('data:image')
                              ? DecorationImage(
                                  image: MemoryImage(
                                    base64Decode(_logoUrl!.split(',').last),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null))
                      : null,
                ),
                child: _logoUrl == null || _logoUrl!.isEmpty
                    ? Center(
                        child: Text(
                          _companyNameController.text.isNotEmpty
                              ? _companyNameController.text[0].toUpperCase()
                              : 'L',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Upload Action & Helper Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isVerified)
                      InkWell(
                        onTap: () => _pickLogo(isVerified),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF5E17EB),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5E17EB).withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.upload, size: 12, color: Colors.white),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  _logoUrl != null ? 'Change Logo' : 'Upload Logo *',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Row(
                        children: [
                          Icon(LucideIcons.checkCircle2, size: 13, color: Color(0xFF059669)),
                          SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Logo Verified & Locked',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 3),
                    const Text(
                      'PNG/SVG, max 2MB.',
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                    if (_errors.containsKey('logo')) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(LucideIcons.alertTriangle, size: 11, color: Color(0xFFE11D48)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _errors['logo']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Input Field Component (Overflow-Proof) ---
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isVerified,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isRequired && !isVerified) ...[
                    const SizedBox(width: 3),
                    const Text('*', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700)),
                  ],
                ],
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 8),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.lock, size: 11, color: Color(0xFF059669)),
                  SizedBox(width: 3),
                  Text(
                    'Locked',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF059669)),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: !isVerified,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: isVerified ? const Color(0xFF475569) : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            filled: true,
            fillColor: isVerified ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5E17EB), width: 1.5),
            ),
          ),
        ),
        if (errorText != null && errorText.isNotEmpty) ...[
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(LucideIcons.alertTriangle, size: 11, color: Color(0xFFE11D48)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // --- Verification Status Badge Card ---
  Widget _buildVerificationStatusCard(bool isVerified) {
    return BlocBuilder<RecruiterSettingsBloc, RecruiterSettingsState>(
      builder: (context, state) {
        final status = state is RecruiterSettingsLoaded
            ? state.verificationStatus.toUpperCase()
            : (isVerified ? 'VERIFIED' : 'UNFILLED');
        final isPending = status == 'PENDING';

        final bgColor = isVerified
            ? const Color(0xFFECFDF5)
            : (isPending ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2));
        final borderColor = isVerified
            ? const Color(0xFFA7F3D0)
            : (isPending ? const Color(0xFFFDE68A) : const Color(0xFFFECACA));
        final iconColor = isVerified
            ? const Color(0xFF059669)
            : (isPending ? const Color(0xFFD97706) : const Color(0xFFDC2626));
        final titleColor = isVerified
            ? const Color(0xFF065F46)
            : (isPending ? const Color(0xFF92400E) : const Color(0xFF991B1B));
        final descColor = isVerified
            ? const Color(0xFF047857)
            : (isPending ? const Color(0xFFB45309) : const Color(0xFFB91C1C));

        final title = isVerified
            ? 'Verified Corporate Account'
            : (isPending ? 'Company Profile Under Admin Review' : 'Unverified Account');
        final desc = isVerified
            ? 'Your company details are verified by Campus2Corporate Admin. Core profile fields are locked for security compliance.'
            : (isPending
                ? 'Your credentials have been submitted and are being reviewed by Administrator.'
                : 'Upload mandatory logo and complete your company profile to submit a verification request to Admin.');

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isVerified
                        ? LucideIcons.checkCircle2
                        : (isPending ? LucideIcons.clock : LucideIcons.alertTriangle),
                    size: 16,
                    color: iconColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 11,
                            color: descColor,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/recruiter/admin-review');
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.shieldCheck, size: 12, color: iconColor),
                      const SizedBox(width: 5),
                      Text(
                        'View Admin Review Status & Timeline',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(LucideIcons.chevronRight, size: 12, color: iconColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 2: Team Management ---
  Widget _buildTeamManagementTab(BuildContext context, RecruiterSettingsLoaded state) {
    final members = state.settings.teamMembers;

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recruitment Team',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Manage recruiters with access.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _openInviteModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E17EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(LucideIcons.userPlus, size: 13),
                label: const Text('Invite', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (ctx, i) {
              final member = members[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5E17EB),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          member.initials,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            member.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        member.role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5E17EB),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 3: Notifications & Security ---
  Widget _buildNotificationsTab(BuildContext context, RecruiterSettingsLoaded state) {
    final prefs = state.settings.notificationPreferences;
    final bloc = context.read<RecruiterSettingsBloc>();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notification Preferences',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              const Text(
                'Configure alerts for candidate applications and interview updates.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 4),

              // Email Alerts Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: const Color(0xFF5E17EB),
                title: const Text('Email Alerts', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                subtitle: const Text('Receive email on new applications', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                value: prefs.emailAlerts,
                onChanged: (val) {
                  bloc.add(UpdateNotificationPreferencesEvent(prefs.copyWith(emailAlerts: val)));
                },
              ),
              const Divider(height: 1, color: AppColors.border),

              // Push Alerts Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: const Color(0xFF5E17EB),
                title: const Text('Push Notifications', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                subtitle: const Text('Get device alerts on candidate messages', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                value: prefs.pushAlerts,
                onChanged: (val) {
                  bloc.add(UpdateNotificationPreferencesEvent(prefs.copyWith(pushAlerts: val)));
                },
              ),
              const Divider(height: 1, color: AppColors.border),

              // Candidate Application Notifications
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: const Color(0xFF5E17EB),
                title: const Text('Application Telemetry', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                subtitle: const Text('Real-time updates on candidate stages', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                value: prefs.applicationNotifications,
                onChanged: (val) {
                  bloc.add(UpdateNotificationPreferencesEvent(prefs.copyWith(applicationNotifications: val)));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Security & Session Info Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.shield, size: 15, color: Color(0xFF5E17EB)),
                  SizedBox(width: 8),
                  Text(
                    'Security & Compliance',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Two-Factor Authentication is active for all corporate recruitment portals.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.info, size: 13, color: AppColors.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Session token is securely managed via JWT and expires in 24 hours of inactivity.',
                        style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Loading State Shimmer ---
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 12),
              Container(width: 140, height: 22, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14))),
          const SizedBox(height: 14),
          Container(height: 320, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
        ],
      ),
    );
  }

  // --- Error State ---
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertCircle, color: Color(0xFFEF4444), size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                context.read<RecruiterSettingsBloc>().add(const FetchRecruiterSettingsEvent());
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

// --- Invite Team Member Bottom Sheet Modal (With Safe Area padding for Android Navigation Bar) ---
class _InviteTeamMemberSheet extends StatefulWidget {
  final void Function(String name, String email, String role) onInvite;

  const _InviteTeamMemberSheet({required this.onInvite});

  @override
  State<_InviteTeamMemberSheet> createState() => _InviteTeamMemberSheetState();
}

class _InviteTeamMemberSheetState extends State<_InviteTeamMemberSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _role = 'Hiring Manager';
  String _error = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      setState(() {
        _error = 'Please fill out all fields.';
      });
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() {
        _error = 'Please enter a valid email address.';
      });
      return;
    }

    widget.onInvite(name, email, _role);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final systemBottomPadding = mediaQuery.viewPadding.bottom > 0
        ? mediaQuery.viewPadding.bottom
        : mediaQuery.padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.85),
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
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Invite Team Member',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
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

              // Form Scrollable
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    14 + (bottomInset > 0 ? 10.0 : (systemBottomPadding > 0 ? 12.0 : 16.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.alertTriangle, size: 13, color: Color(0xFFE11D48)),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  _error,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE11D48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Full Name
                      const Text(
                        'Full Name *',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'e.g. Sarah Jenkins',
                          hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Email Address
                      const Text(
                        'Corporate Email Address *',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'sarah@company.com',
                          hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Role Dropdown
                      const Text(
                        'Role / Permission Level *',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _role,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'Hiring Manager', child: Text('Hiring Manager', style: TextStyle(fontSize: 12.5))),
                              DropdownMenuItem(value: 'Technical Recruiter', child: Text('Technical Recruiter', style: TextStyle(fontSize: 12.5))),
                              DropdownMenuItem(value: 'Campus Coordinator', child: Text('Campus Coordinator', style: TextStyle(fontSize: 12.5))),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _role = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Buttons (Equal flex to prevent overflow)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5E17EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: const Text('Send Invite', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ),
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
