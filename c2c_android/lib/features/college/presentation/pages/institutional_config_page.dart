import 'package:flutter/material.dart';
import 'college_settings_page.dart';

/// Backward-compatible alias for the College Settings & Institutional Configuration page.
///
/// Route bindings:
/// - `/college/settings`
/// - `/college/operations/config`
class InstitutionalConfigPage extends StatelessWidget {
  const InstitutionalConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CollegeSettingsPage();
  }
}
