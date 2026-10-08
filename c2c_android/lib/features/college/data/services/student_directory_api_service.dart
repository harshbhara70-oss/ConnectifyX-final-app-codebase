import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/college_student_model.dart';

class StudentDirectoryApiService {
  final DioClient _dioClient;

  StudentDirectoryApiService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// GET /api/college/students — fetches all students belonging to the logged-in college.
  ///
  /// Real MongoDB atlas response -> isMock = false.
  /// If network / server / endpoint error occurs -> graceful fallback to mock seeds with isMock = true.
  Future<({List<CollegeStudentModel> students, bool isMock})> fetchStudents() async {
    try {
      final response = await _dioClient.instance.get(
        ApiEndpoints.collegeStudents,
      );

      List<dynamic> list = [];
      if (response.data is Map && response.data['data'] is List) {
        list = response.data['data'] as List<dynamic>;
      } else if (response.data is List) {
        list = response.data as List<dynamic>;
      }

      final liveStudents = list
          .whereType<Map<String, dynamic>>()
          .map((json) => CollegeStudentModel.fromJson(json, isMock: false))
          .toList();

      return (students: liveStudents, isMock: false);
    } catch (e) {
      // Graceful fallback with standard mock seed data (isMock = true)
      return (students: CollegeStudentModel.mockSeeds, isMock: true);
    }
  }

  /// POST /api/college/students — creates a new student in MongoDB Atlas.
  Future<({CollegeStudentModel student, bool isMock})> createStudent(
    Map<String, dynamic> studentData,
  ) async {
    final payload = <String, dynamic>{
      'name': studentData['name']?.toString().trim(),
      'email': studentData['email']?.toString().trim().toLowerCase(),
      'phone': studentData['phone']?.toString().trim() ?? '',
      'branch': studentData['department']?.toString() ??
          studentData['branch']?.toString() ??
          'Computer Science',
      if (studentData['semester'] != null)
        'semester': (studentData['semester'] as num).toInt(),
      'percentage': (studentData['percentage'] as num?)?.toDouble() ?? 0.0,
      'status': studentData['status']?.toString() ?? 'Active',
      if (studentData['bio'] != null &&
          studentData['bio'].toString().trim().isNotEmpty)
        'bio': studentData['bio'].toString().trim(),
      if (studentData['skills'] is List &&
          (studentData['skills'] as List).isNotEmpty)
        'skills': studentData['skills'],
    };

    try {
      final response = await _dioClient.instance.post(
        ApiEndpoints.collegeStudents,
        data: payload,
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      final created = CollegeStudentModel.fromJson(
        data as Map<String, dynamic>,
        isMock: false,
      );
      return (student: created, isMock: false);
    } catch (e) {
      // Local fallback creation
      final parsedCgpa = (studentData['cgpa'] as num?)?.toDouble() ??
          (((studentData['percentage'] as num?)?.toDouble() ?? 75.0) / 10.0);
      final fallbackStudent = CollegeStudentModel(
        id: 'stu-${DateTime.now().millisecondsSinceEpoch}',
        name: studentData['name']?.toString() ?? 'New Candidate',
        rollNumber: studentData['rollNumber']?.toString() ?? 'Roll: CS2024-000',
        department: studentData['department']?.toString() ??
            studentData['branch']?.toString() ??
            'Computer Science',
        graduationYear: studentData['graduationYear']?.toString() ?? '2024 (Current)',
        cgpa: parsedCgpa,
        percentage: parsedCgpa * 10,
        readinessScore: (parsedCgpa * 10).clamp(10, 99).round(),
        placementStatus: studentData['placementStatus']?.toString() ?? 'UNPLACED',
        skills: (studentData['skills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            ['React.js', 'Node.js', 'Python'],
        email: studentData['email']?.toString() ?? '',
        phone: studentData['phone']?.toString() ?? '',
        isMock: true,
      );
      return (student: fallbackStudent, isMock: true);
    }
  }

  /// PUT /api/college/students/:id — updates an existing student in MongoDB.
  Future<({CollegeStudentModel student, bool isMock})> updateStudent(
    String id,
    Map<String, dynamic> studentData,
  ) async {
    try {
      final response = await _dioClient.instance.put(
        '${ApiEndpoints.collegeStudents}/$id',
        data: studentData,
      );

      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      final updated = CollegeStudentModel.fromJson(
        data as Map<String, dynamic>,
        isMock: false,
      );
      return (student: updated, isMock: false);
    } catch (e) {
      final parsedCgpa = (studentData['cgpa'] as num?)?.toDouble() ??
          (((studentData['percentage'] as num?)?.toDouble() ?? 75.0) / 10.0);
      final updatedFallback = CollegeStudentModel(
        id: id,
        name: studentData['name']?.toString() ?? 'Candidate',
        rollNumber: studentData['rollNumber']?.toString() ?? 'Roll: CS2024-000',
        department: studentData['department']?.toString() ??
            studentData['branch']?.toString() ??
            'Computer Science',
        graduationYear: studentData['graduationYear']?.toString() ?? '2024 (Current)',
        cgpa: parsedCgpa,
        percentage: parsedCgpa * 10,
        readinessScore: (parsedCgpa * 10).clamp(10, 99).round(),
        placementStatus: studentData['placementStatus']?.toString() ?? 'UNPLACED',
        skills: (studentData['skills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            ['React.js', 'Node.js'],
        email: studentData['email']?.toString() ?? '',
        phone: studentData['phone']?.toString() ?? '',
        isMock: true,
      );
      return (student: updatedFallback, isMock: true);
    }
  }

  /// DELETE /api/college/students/:id — deletes a student from MongoDB.
  Future<bool> deleteStudent(String id) async {
    try {
      await _dioClient.instance.delete(
        '${ApiEndpoints.collegeStudents}/$id',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// GET /api/college/students/:id — fetch single student detail.
  Future<CollegeStudentModel> fetchStudentById(String id) async {
    try {
      final response = await _dioClient.instance.get(
        '${ApiEndpoints.collegeStudents}/$id',
      );
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return CollegeStudentModel.fromJson(
        data as Map<String, dynamic>,
        isMock: false,
      );
    } catch (e) {
      final match = CollegeStudentModel.mockSeeds.firstWhere(
        (s) => s.id == id,
        orElse: () => CollegeStudentModel(
          id: id,
          name: 'Student Candidate',
          rollNumber: 'Roll: CS2024-042',
          department: 'Computer Science',
          graduationYear: '2024 (Current)',
          cgpa: 8.5,
          percentage: 85.0,
          readinessScore: 88,
          placementStatus: 'UNPLACED',
          skills: const ['React.js', 'Node.js', 'Python'],
          email: 'candidate@college.edu',
          phone: '+91 98765 00000',
          isMock: true,
        ),
      );
      return match;
    }
  }
}
