import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/candidate_pipeline_model.dart';

class PipelineRepository {
  final DioClient _dioClient;
  static const String _prefKey = 'c2c_recruiter_candidates';

  PipelineRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetches candidates across all hiring pipeline stages
  Future<List<CandidatePipelineItem>> fetchPipelineCandidates() async {
    try {
      final response = await _dioClient.instance.get(ApiEndpoints.recruiterApplications);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final List<dynamic> list = data is List
            ? data
            : (data['data'] as List<dynamic>?) ??
                (data['applications'] as List<dynamic>?) ??
                [];

        if (list.isNotEmpty) {
          final items = list
              .map((e) => CandidatePipelineItem.fromJson(e as Map<String, dynamic>, isMock: false))
              .toList();
          await _persist(items);
          return items;
        } else if (data['success'] == true) {
          return [];
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }
    } catch (_) {
      // Fall through to local cache / seeds
    }

    final local = await _loadFromPrefs();
    if (local.isNotEmpty) {
      return local;
    }
    return _seedPipelineCandidates();
  }

  /// Advances candidate to next stage (shortlisted -> contacted -> interview -> offer)
  Future<bool> advanceCandidate(String candidateId, String currentStage) async {
    String nextStage = currentStage;
    if (currentStage == 'shortlisted') {
      nextStage = 'contacted';
    } else if (currentStage == 'contacted') {
      nextStage = 'interview';
    } else if (currentStage == 'interview') {
      nextStage = 'offer';
    }

    if (nextStage == currentStage) return true;

    try {
      await _dioClient.instance.patch(
        '${ApiEndpoints.recruiterApplications}/$candidateId/stage',
        data: {'stage': nextStage},
      );
    } catch (_) {}

    final existing = await _loadFromPrefs();
    if (existing.isNotEmpty) {
      final updated = existing.map((c) => c.id == candidateId ? c.copyWith(stage: nextStage) : c).toList();
      await _persist(updated);
      return true;
    }

    final seeds = _seedPipelineCandidates();
    final updated = seeds.map((c) => c.id == candidateId ? c.copyWith(stage: nextStage) : c).toList();
    await _persist(updated);
    return true;
  }

  /// Rolls back candidate to previous stage (offer -> interview -> contacted -> shortlisted)
  Future<bool> rollbackCandidate(String candidateId, String currentStage) async {
    String prevStage = currentStage;
    if (currentStage == 'offer') {
      prevStage = 'interview';
    } else if (currentStage == 'interview') {
      prevStage = 'contacted';
    } else if (currentStage == 'contacted') {
      prevStage = 'shortlisted';
    }

    if (prevStage == currentStage) return true;

    try {
      await _dioClient.instance.patch(
        '${ApiEndpoints.recruiterApplications}/$candidateId/stage',
        data: {'stage': prevStage},
      );
    } catch (_) {}

    final existing = await _loadFromPrefs();
    if (existing.isNotEmpty) {
      final updated = existing.map((c) => c.id == candidateId ? c.copyWith(stage: prevStage) : c).toList();
      await _persist(updated);
      return true;
    }

    final seeds = _seedPipelineCandidates();
    final updated = seeds.map((c) => c.id == candidateId ? c.copyWith(stage: prevStage) : c).toList();
    await _persist(updated);
    return true;
  }

  /// Adds a candidate (referral / external) to the hiring pipeline
  Future<CandidatePipelineItem> addCandidate({
    required String name,
    required String role,
    required String stage,
    required String source,
    required String score,
  }) async {
    final newCand = CandidatePipelineItem(
      id: 'cand_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      role: role,
      stage: stage,
      score: score.isNotEmpty ? score : '90',
      source: source,
      isMock: false,
    );

    // Save locally
    final existing = await _loadFromPrefs();
    final updated = [...existing, newCand];
    await _persist(updated);

    try {
      final res = await _dioClient.instance.post(
        '/recruiter/candidates',
        data: {
          'name': name,
          'role': role,
          'stage': stage,
          'source': source,
          'score': score,
        },
      );
      if (res.statusCode == 201 && res.data != null && res.data['data'] != null) {
        return CandidatePipelineItem.fromJson(res.data['data'] as Map<String, dynamic>, isMock: false);
      }
    } catch (_) {}

    return newCand;
  }

  /// Removes candidate from hiring pipeline
  Future<bool> removeCandidate(String candidateId) async {
    try {
      await _dioClient.instance.delete('/recruiter/candidates/$candidateId');
    } catch (_) {}

    final existing = await _loadFromPrefs();
    final updated = existing.where((c) => c.id != candidateId).toList();
    await _persist(updated);
    return true;
  }

  Future<List<CandidatePipelineItem>> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> arr = jsonDecode(raw);
        return arr.map((e) => CandidatePipelineItem.fromJson(e as Map<String, dynamic>, isMock: false)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _persist(List<CandidatePipelineItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(items.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  List<CandidatePipelineItem> _seedPipelineCandidates() {
    return [
      const CandidatePipelineItem(
        id: '101',
        name: 'Rohan Verma',
        role: 'Full Stack Developer',
        stage: 'shortlisted',
        score: '94',
        source: 'Referral',
        isMock: true,
      ),
      const CandidatePipelineItem(
        id: '103',
        name: 'Siddharth Rao',
        role: 'Full Stack Developer',
        stage: 'shortlisted',
        score: '96',
        source: 'Referral',
        isMock: true,
      ),
      const CandidatePipelineItem(
        id: '102',
        name: 'Ananya Sharma',
        role: 'AI / ML Engineer',
        stage: 'contacted',
        score: '91',
        source: 'External / Outside',
        isMock: true,
      ),
      const CandidatePipelineItem(
        id: '104',
        name: 'Priya Sundaram',
        role: 'Full Stack Developer',
        stage: 'interview',
        score: '98',
        source: 'Direct Application',
        isMock: true,
      ),
      const CandidatePipelineItem(
        id: '105',
        name: 'Kabir Mehta',
        role: 'AI / ML Engineer',
        stage: 'offer',
        score: '99',
        source: 'External / Outside',
        isMock: true,
      ),
    ];
  }
}
