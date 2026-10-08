import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/recruiter_message_model.dart';

class RecruiterMessagesRepository {
  final DioClient _dioClient;
  static const String _prefKey = 'c2c_recruiter_messages_cache';

  RecruiterMessagesRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetches conversations / messages from MongoDB Atlas
  Future<List<RecruiterConversationItem>> fetchConversations() async {
    try {
      final response = await _dioClient.instance.get(ApiEndpoints.recruiterMessages);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final List<dynamic> list = data['data'] as List<dynamic>? ?? [];
          final items = list
              .map((e) => RecruiterConversationItem.fromJson(e as Map<String, dynamic>, isMock: false))
              .toList();
          await _persist(items);
          return items;
        } else if (data is List) {
          final items = data
              .map((e) => RecruiterConversationItem.fromJson(e as Map<String, dynamic>, isMock: false))
              .toList();
          await _persist(items);
          return items;
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }
    } catch (_) {
      // Fall through to local cache or seed fallback
    }

    final cached = await _loadFromPrefs();
    if (cached.isNotEmpty) {
      return cached;
    }
    return _seedMockConversations();
  }

  /// Starts a new conversation with candidate
  Future<RecruiterConversationItem> startConversation({
    required String candidateName,
    required String role,
    required String firstMessage,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.recruiterMessages,
        data: {
          'candidateName': candidateName.trim(),
          'role': role.trim(),
          'firstMessage': firstMessage.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          final item = RecruiterConversationItem.fromJson(data['data'] as Map<String, dynamic>, isMock: false);
          await _prependAndPersist(item);
          return item;
        }
      }
    } catch (_) {
      // Offline fallback: create local item
    }

    final fallback = RecruiterConversationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      candidateName: candidateName.trim(),
      role: role.trim(),
      lastMessage: firstMessage.trim(),
      time: 'Just now',
      messages: [
        ChatMessageItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: 'recruiter',
          text: firstMessage.trim(),
          time: 'Just now',
          isMe: true,
        ),
      ],
      isMock: true,
    );

    await _prependAndPersist(fallback);
    return fallback;
  }

  /// Sends a reply inside an active conversation
  Future<ChatMessageItem> sendReply({
    required String conversationId,
    required String text,
  }) async {
    try {
      final response = await _dioClient.instance.post(
        '${ApiEndpoints.recruiterMessages}/$conversationId/reply',
        data: {'text': text.trim(), 'sender': 'recruiter'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null && data['data']['newMessage'] != null) {
          return ChatMessageItem.fromJson(data['data']['newMessage'] as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Offline fallback
    }

    final newMsg = ChatMessageItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'recruiter',
      text: text.trim(),
      time: 'Just now',
      isMe: true,
    );

    await _appendMessageLocally(conversationId, newMsg);
    return newMsg;
  }

  // --- Local Persistence ---
  Future<void> _persist(List<RecruiterConversationItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKey, encoded);
    } catch (_) {}
  }

  Future<List<RecruiterConversationItem>> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_prefKey);
      if (str != null && str.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(str);
        return decoded
            .map((e) => RecruiterConversationItem.fromJson(e as Map<String, dynamic>, isMock: true))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _prependAndPersist(RecruiterConversationItem item) async {
    final list = await _loadFromPrefs();
    list.removeWhere((e) => e.id == item.id);
    list.insert(0, item);
    await _persist(list);
  }

  Future<void> _appendMessageLocally(String convId, ChatMessageItem msg) async {
    final list = await _loadFromPrefs();
    final idx = list.indexWhere((e) => e.id == convId);
    if (idx != -1) {
      final old = list[idx];
      final updatedMsgs = List<ChatMessageItem>.from(old.messages)..add(msg);
      list[idx] = old.copyWith(
        lastMessage: msg.text,
        time: msg.time,
        messages: updatedMsgs,
      );
      await _persist(list);
    }
  }

  /// Mock seeds mirroring web initial conversations if backend has no data yet
  List<RecruiterConversationItem> _seedMockConversations() {
    return [
      RecruiterConversationItem(
        id: 'mock_1',
        candidateName: 'Priya Sharma',
        role: 'Full Stack Engineer',
        lastMessage: 'Looking forward to the technical interview discussion tomorrow.',
        time: '10:30 AM',
        isMock: true,
        messages: [
          ChatMessageItem(
            id: 'm1',
            sender: 'recruiter',
            text: 'Hello Priya, we were very impressed by your full stack portfolio and projects.',
            time: '10:15 AM',
            isMe: true,
          ),
          ChatMessageItem(
            id: 'm2',
            sender: 'candidate',
            text: 'Thank you! I am really excited about this opportunity.',
            time: '10:22 AM',
            isMe: false,
          ),
          ChatMessageItem(
            id: 'm3',
            sender: 'candidate',
            text: 'Looking forward to the technical interview discussion tomorrow.',
            time: '10:30 AM',
            isMe: false,
          ),
        ],
      ),
      RecruiterConversationItem(
        id: 'mock_2',
        candidateName: 'Aarav Patel',
        role: 'Backend Developer',
        lastMessage: 'Shared my updated GitHub repository and system architecture document.',
        time: 'Yesterday',
        isMock: true,
        messages: [
          ChatMessageItem(
            id: 'm4',
            sender: 'recruiter',
            text: 'Hi Aarav, can you provide the repository link for your distributed cache project?',
            time: 'Yesterday',
            isMe: true,
          ),
          ChatMessageItem(
            id: 'm5',
            sender: 'candidate',
            text: 'Shared my updated GitHub repository and system architecture document.',
            time: 'Yesterday',
            isMe: false,
          ),
        ],
      ),
    ];
  }
}
