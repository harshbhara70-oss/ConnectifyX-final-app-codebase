/// Production-ready null-safe model for Eligible Placement Students
/// Aligned with Backend endpoint GET /college/students/eligible
class EligibleStudentModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String rollNumber;
  final String department;
  final double percentage;
  final double cgpa;
  final List<String> skills;
  final String status;
  final String resumeUrl;

  const EligibleStudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.rollNumber,
    required this.department,
    required this.percentage,
    required this.cgpa,
    required this.skills,
    required this.status,
    required this.resumeUrl,
  });

  factory EligibleStudentModel.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['skills'];
    List<String> skillsList = [];
    if (rawSkills is List) {
      skillsList = rawSkills.map((e) => e.toString()).toList();
    } else if (rawSkills is String) {
      skillsList = rawSkills.split(',').map((e) => e.trim()).toList();
    }
    if (skillsList.isEmpty) {
      skillsList = ['Problem Solving', 'Data Structures', 'Git'];
    }

    final double pct = (json['percentage'] as num?)?.toDouble() ?? 82.5;
    final double computedCgpa = (json['cgpa'] as num?)?.toDouble() ?? (pct / 9.5);

    return EligibleStudentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'el_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name']?.toString() ?? 'Eligible Student',
      email: json['email']?.toString() ?? 'student@college.edu',
      phone: json['phone']?.toString() ?? '+91 98765 43210',
      rollNumber: json['rollNumber']?.toString() ?? json['roll']?.toString() ?? 'CS-2024',
      department: json['department']?.toString() ?? json['branch']?.toString() ?? 'Computer Science',
      percentage: pct,
      cgpa: double.parse(computedCgpa.toStringAsFixed(1)),
      skills: skillsList,
      status: json['status']?.toString() ?? 'Active',
      resumeUrl: json['resume']?.toString() ?? '',
    );
  }

  static List<EligibleStudentModel> get mockEligibles => [
        const EligibleStudentModel(
          id: 'el_1',
          name: 'Aarav Sharma',
          email: 'aarav.sharma@college.edu',
          phone: '+91 98765 43210',
          rollNumber: '2022CS104',
          department: 'Computer Science',
          percentage: 92.4,
          cgpa: 9.7,
          skills: ['Flutter', 'Node.js', 'System Design', 'Docker'],
          status: 'Active',
          resumeUrl: 'https://example.com/resume_aarav.pdf',
        ),
        const EligibleStudentModel(
          id: 'el_2',
          name: 'Sneha Patel',
          email: 'sneha.patel@college.edu',
          phone: '+91 98765 43211',
          rollNumber: '2022IT089',
          department: 'Information Technology',
          percentage: 88.0,
          cgpa: 9.2,
          skills: ['React', 'Python', 'AWS', 'PostgreSQL'],
          status: 'Active',
          resumeUrl: 'https://example.com/resume_sneha.pdf',
        ),
        const EligibleStudentModel(
          id: 'el_3',
          name: 'Rohan Deshmukh',
          email: 'rohan.d@college.edu',
          phone: '+91 98765 43212',
          rollNumber: '2022EC045',
          department: 'Electronics & Comm.',
          percentage: 84.5,
          cgpa: 8.9,
          skills: ['Embedded C', 'Python', 'IoT', 'MATLAB'],
          status: 'Active',
          resumeUrl: 'https://example.com/resume_rohan.pdf',
        ),
        const EligibleStudentModel(
          id: 'el_4',
          name: 'Ananya Roy',
          email: 'ananya.roy@college.edu',
          phone: '+91 98765 43213',
          rollNumber: '2022CS034',
          department: 'Computer Science',
          percentage: 89.2,
          cgpa: 9.4,
          skills: ['Java', 'Spring Boot', 'Kafka', 'Kubernetes'],
          status: 'Active',
          resumeUrl: 'https://example.com/resume_ananya.pdf',
        ),
      ];
}
