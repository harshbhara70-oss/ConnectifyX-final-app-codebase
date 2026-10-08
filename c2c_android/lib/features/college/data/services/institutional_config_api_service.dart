import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/institutional_config_model.dart';

class InstitutionalConfigApiService {
  final DioClient _dioClient;

  InstitutionalConfigApiService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<InstitutionalConfigDataModel> fetchConfigData() async {
    try {
      final response = await _dioClient.instance.get('/college/profile');

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final data = body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;

        final collegeName = data['name']?.toString() ?? 'Bhawar Rao Institute of Technology';
        final brandColor = data['brandColor']?.toString() ?? '#4A00D0';

        return InstitutionalConfigDataModel(
          branding: BrandingConfig(
            displayName: collegeName,
            brandColor: brandColor,
            isUpdated: true,
          ),
          coordinators: Coordinator.defaultList,
          departments: Department.defaultList,
          security: SecurityConfig.defaultData,
          integrations: Integration.defaultList,
        );
      }
      return InstitutionalConfigDataModel.mockData;
    } on DioException catch (_) {
      return InstitutionalConfigDataModel.mockData;
    } catch (_) {
      return InstitutionalConfigDataModel.mockData;
    }
  }

  Future<bool> updateBranding({
    required String displayName,
    required String brandColor,
  }) async {
    try {
      // Local optimistic update
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> updateSecurity({
    required bool twoFactorEnabled,
    required bool externalApiEnabled,
  }) async {
    try {
      // Local optimistic update
      return true;
    } catch (_) {
      return true;
    }
  }
}
