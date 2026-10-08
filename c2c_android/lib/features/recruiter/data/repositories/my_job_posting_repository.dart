import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/my_job_posting_model.dart';

class MyJobPostingRepository {
  final DioClient _dioClient;
  static const String _prefKey = 'c2c_recruiter_jobs';

  MyJobPostingRepository({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Fetch recruiter postings from MongoDB Atlas backend with robust offline fallback
  Future<List<JobPostingItem>> fetchMyPostings({String? jobIdFilter}) async {
    try {
      final response = await _dioClient.instance.get(
        ApiEndpoints.recruiterMyPostings,
        queryParameters: jobIdFilter != null ? {'jobId': jobIdFilter} : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final List<dynamic> list = data is List
            ? data
            : (data['data'] as List<dynamic>?) ??
                (data['jobs'] as List<dynamic>?) ??
                (data['postings'] as List<dynamic>?) ??
                [];
        
        // If MongoDB Atlas returned real data
        if (list.isNotEmpty) {
          final items = list
              .map((e) => JobPostingItem.fromJson(e as Map<String, dynamic>, isMock: false))
              .toList();
          // Update cache
          await _persist(items);
          return items;
        } else if (data['success'] == true) {
          // Explicit empty list from live backend
          return [];
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }
    } catch (_) {
      // Fall through to local cache + seed
    }

    // ---- Local Fallback & Seed ----
    final local = await _loadFromPrefs();
    if (local.isNotEmpty) {
      return local;
    }
    return _seedMockPostings();
  }

  Future<bool> deletePosting(String id) async {
    try {
      await _dioClient.instance.delete('${ApiEndpoints.recruiterMyPostings}/$id');
    } catch (_) {}
    
    // Always sync local cache
    final existing = await _loadFromPrefs();
    final updated = existing.where((p) => p.id != id).toList();
    await _persist(updated);
    return true;
  }

  Future<bool> publishDraft(String id) async {
    try {
      await _dioClient.instance.patch(
        '${ApiEndpoints.recruiterMyPostings}/$id/status',
        data: {'status': 'ACTIVE'},
      );
    } catch (_) {}

    final existing = await _loadFromPrefs();
    if (existing.isNotEmpty) {
      final updated = existing.map((p) => p.id == id ? p.copyWith(status: 'ACTIVE') : p).toList();
      await _persist(updated);
      return true;
    }

    final seeds = _seedMockPostings();
    final target = seeds.where((s) => s.id == id).toList();
    if (target.isNotEmpty) {
      final promoted = target.first.copyWith(status: 'ACTIVE');
      await _persist([promoted]);
    }
    return true;
  }

  // ---- Helpers ----

  Future<List<JobPostingItem>> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> arr = jsonDecode(raw);
        return arr.map((e) => JobPostingItem.fromJson(e as Map<String, dynamic>, isMock: false)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _persist(List<JobPostingItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(items.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  List<JobPostingItem> _seedMockPostings() {
    return [
      const JobPostingItem(
        id: 'job_01',
        title: 'Associate Software Engineer',
        description:
            'We are seeking an Associate Software Engineer to build scalable web platforms using Flutter, Node.js and cloud-native patterns. You will own features end-to-end and collaborate with product and design teams.',
        jobType: 'Full-time Permanent',
        isRemote: false,
        location: 'Bengaluru, Karnataka',
        salaryMin: '8',
        salaryMax: '12',
        salaryCurrency: 'LPA',
        skills: ['Flutter', 'Dart', 'Node.js', 'MongoDB', 'REST APIs'],
        departments: ['Engineering'],
        status: 'ACTIVE',
        createdAt: 'Aug 18, 2026',
        applicantsCount: 14,
        inReviewCount: 6,
        hiredCount: 1,
        isMock: true,
      ),
      const JobPostingItem(
        id: 'job_02',
        title: 'Frontend React Developer',
        description:
            'Craft high-performance React interfaces with TypeScript and Tailwind. Own UI architecture and mentor junior developers on component design.',
        jobType: 'Full-time Permanent',
        isRemote: true,
        location: 'Remote',
        salaryMin: '7',
        salaryMax: '10.5',
        salaryCurrency: 'LPA',
        skills: ['React.js', 'TypeScript', 'TailwindCSS', 'Redux'],
        departments: ['Frontend'],
        status: 'ACTIVE',
        createdAt: 'Aug 15, 2026',
        applicantsCount: 9,
        inReviewCount: 3,
        hiredCount: 0,
        isMock: true,
      ),
      const JobPostingItem(
        id: 'job_03',
        title: 'AI/ML Engineering Intern',
        description:
            'Join our AI research pod to prototype GenAI pipelines with Python, PyTorch and FastAPI. Intensive mentorship and publication support.',
        jobType: 'Internship',
        isRemote: false,
        location: 'Noida, Uttar Pradesh',
        salaryMin: '35',
        salaryMax: '45',
        salaryCurrency: 'INR',
        skills: ['Python', 'PyTorch', 'FastAPI', 'GenAI', 'LLMs'],
        departments: ['AI/ML'],
        status: 'DRAFT',
        createdAt: 'Aug 20, 2026',
        applicantsCount: 0,
        inReviewCount: 0,
        hiredCount: 0,
        isMock: true,
      ),
      const JobPostingItem(
        id: 'job_04',
        title: 'Business Analyst Intern',
        description:
            'Support product analytics and stakeholder research. Strong Excel and storytelling skills preferred. Duration 3 months, PPO track.',
        jobType: 'Internship',
        isRemote: false,
        location: 'Hyderabad, Telangana',
        salaryMin: '25',
        salaryMax: '30',
        salaryCurrency: 'INR',
        skills: ['Excel', 'SQL', 'Business Analysis', 'Communication'],
        departments: ['Product'],
        status: 'DRAFT',
        createdAt: 'Aug 22, 2026',
        applicantsCount: 0,
        inReviewCount: 0,
        hiredCount: 0,
        isMock: true,
      ),
    ];
  }
}
