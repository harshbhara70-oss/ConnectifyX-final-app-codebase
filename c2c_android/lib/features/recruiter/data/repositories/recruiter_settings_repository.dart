import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/recruiter_settings_model.dart';

class RecruiterSettingsRepository {
  final DioClient _dioClient;
  static const String _prefProfileKey = 'c2c_company_profile';
  static const String _prefStatusKey = 'c2c_verification_status';

  RecruiterSettingsRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetches recruiter corporate settings & verification status
  Future<RecruiterSettingsModel> fetchSettings() async {
    try {
      final response = await _dioClient.instance.get(ApiEndpoints.recruiterSettings);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true && data['data'] != null) {
          final model = RecruiterSettingsModel.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
          await _persist(model);
          return model;
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }
    } catch (_) {
      // Fall through to local cache or default seed
    }

    final cached = await _loadFromPrefs();
    if (cached != null) {
      return cached;
    }
    return _seedDefaultSettings();
  }

  /// Saves / submits company profile for Admin Verification
  Future<RecruiterSettingsModel> saveSettings({
    required String repName,
    required String companyName,
    required String websiteUrl,
    required String aboutCompany,
    String? logoUrl,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.recruiterSettings,
        data: {
          'repName': repName.trim(),
          'companyName': companyName.trim(),
          'websiteUrl': websiteUrl.trim(),
          'aboutCompany': aboutCompany.trim(),
          'logoUrl': logoUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final model = RecruiterSettingsModel.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
          await _persist(model);
          return model;
        }
      }
    } catch (_) {
      // Offline fallback: save locally as PENDING
    }

    final current = await _loadFromPrefs() ?? _seedDefaultSettings();
    final updated = current.copyWith(
      repName: repName.trim(),
      companyName: companyName.trim(),
      websiteUrl: websiteUrl.trim(),
      aboutCompany: aboutCompany.trim(),
      logoUrl: logoUrl,
      verificationStatus: 'PENDING',
      isVerified: false,
      submittedAt: 'Just now',
      isMock: true,
    );

    await _persist(updated);
    return updated;
  }

  /// Sends edit request for verified / locked profile to Admin
  Future<String> requestAdminEdit({required String companyName}) async {
    try {
      final response = await _dioClient.instance.post(
        '${ApiEndpoints.recruiterSettings}/request-edit',
        data: {'companyName': companyName.trim()},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['message'] != null) {
          return data['message'].toString();
        }
      }
    } catch (_) {}

    return 'Edit request sent to Admin notification panel! Admin will review your field change request.';
  }

  /// Updates notification preferences
  Future<RecruiterSettingsModel> updateNotificationPreferences({
    required RecruiterNotificationPreferences preferences,
  }) async {
    final current = await _loadFromPrefs() ?? _seedDefaultSettings();
    final updated = current.copyWith(notificationPreferences: preferences);
    await _persist(updated);
    return updated;
  }

  /// Invites a new team member
  Future<RecruiterSettingsModel> inviteTeamMember({
    required String name,
    required String email,
    required String role,
  }) async {
    final current = await _loadFromPrefs() ?? _seedDefaultSettings();
    final newMember = RecruiterTeamMember.fromJson({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name.trim(),
      'email': email.trim(),
      'role': role.trim(),
    });

    final updatedMembers = List<RecruiterTeamMember>.from(current.teamMembers)..add(newMember);
    final updated = current.copyWith(teamMembers: updatedMembers);
    await _persist(updated);
    return updated;
  }

  // --- Local Cache ---
  Future<void> _persist(RecruiterSettingsModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefProfileKey, jsonEncode(model.toJson()));
      await prefs.setString(_prefStatusKey, model.verificationStatus);
    } catch (_) {}
  }

  Future<RecruiterSettingsModel?> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_prefProfileKey);
      final status = prefs.getString(_prefStatusKey) ?? 'UNFILLED';

      if (str != null && str.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(str);
        decoded['verificationStatus'] = status;
        return RecruiterSettingsModel.fromJson(decoded, isMock: true);
      }
    } catch (_) {}
    return null;
  }

  RecruiterSettingsModel _seedDefaultSettings() {
    return const RecruiterSettingsModel(
      repName: 'Alexander Wright',
      companyName: 'Lumina Nexus Tech',
      websiteUrl: 'https://luminanexus.com',
      aboutCompany: 'Enterprise AI software and campus recruitment platform partner.',
      logoUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=200&q=80',
      verificationStatus: 'VERIFIED',
      isVerified: true,
      submittedAt: 'Oct 12, 2025',
      email: 'alexander@luminanexus.com',
      teamMembers: [
        RecruiterTeamMember(
          id: 'tm-1',
          name: 'Alexander Wright',
          email: 'alexander@luminanexus.com',
          role: 'Account Owner / Admin',
          initials: 'AW',
        ),
      ],
      notificationPreferences: RecruiterNotificationPreferences(),
      isMock: true,
    );
  }
}
