import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/broadcast_center_model.dart';

class BroadcastCenterApiService {
  final DioClient _dioClient;

  BroadcastCenterApiService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// GET /api/college/operations/communication[?tab=&search=]
  /// Attempts live MongoDB Atlas query via backend endpoint.
  /// If backend endpoint is active -> returns realtime data with `isMock: false`.
  /// If endpoint is unintegrated (404/500/timeout/unreachable) -> returns seed dataset with `isMock: true`.
  Future<BroadcastCenterData> fetchBroadcastCenter({
    String? tab,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (tab != null && tab.isNotEmpty) queryParams['tab'] = tab;
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        queryParams['search'] = searchQuery.trim();
      }

      final response = await _dioClient.instance.get(
        ApiEndpoints.collegeCommunication,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          if (map['data'] is Map<String, dynamic> || map['data'] is List) {
            if (map['data'] is List) {
              return BroadcastCenterData.fromJson({'broadcasts': map['data']}, isMock: false);
            }
            return BroadcastCenterData.fromJson(map, isMock: false);
          }
          return BroadcastCenterData.fromJson(map, isMock: false);
        }
        if (response.data is List) {
          return BroadcastCenterData.fromJson({'broadcasts': response.data}, isMock: false);
        }
      }
      return BroadcastCenterData.mockSeed();
    } catch (_) {
      // Graceful fallback to mock seed dataset directly from React frontend
      return BroadcastCenterData.mockSeed();
    }
  }

  /// POST /api/college/operations/communication/broadcast
  Future<BroadcastLogItem> sendBroadcast({
    required String title,
    required String body,
    required String targetAudience,
    required bool isUrgent,
    required int recipientCount,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.collegeBroadcast,
        data: {
          'title': title.trim(),
          'content': body.trim(),
          'targetAudience': targetAudience,
          'isUrgent': isUrgent,
          'totalCount': recipientCount,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final map = response.data as Map<String, dynamic>;
          final payload = map['data'] is Map<String, dynamic> ? map['data'] as Map<String, dynamic> : map;
          return BroadcastLogItem.fromJson(payload, isMock: false);
        }
      }
    } catch (_) {
      // Backend not yet available or failed — return local item marked isMock = true
    }

    return BroadcastLogItem(
      id: 'bcast-${DateTime.now().millisecondsSinceEpoch}',
      type: isUrgent ? BroadcastType.megaphone : BroadcastType.document,
      title: title.trim(),
      snippet: body.length > 80 ? '${body.substring(0, 80)}...' : body,
      fullBody: body.trim(),
      isUrgent: isUrgent,
      targetAudience: targetAudience,
      dateSent: 'Just now',
      readCount: 1,
      totalCount: recipientCount,
      status: BroadcastStatus.sent,
      isMock: true,
    );
  }

  /// PUT /api/college/operations/communication/broadcast/:id/publish
  Future<bool> publishDraft(String draftId) async {
    try {
      final response = await _dioClient.instance.put(
        '${ApiEndpoints.collegeBroadcast}/$draftId/publish',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// DELETE /api/college/operations/communication/broadcast/drafts/:id
  Future<bool> deleteDraft(String draftId) async {
    try {
      final response = await _dioClient.instance.delete(
        '${ApiEndpoints.collegeBroadcast}/drafts/$draftId',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}

