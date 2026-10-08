import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Production-ready null-safe model for Student Placement Applications
/// Aligned with Backend Mongoose Application schema (/college/applications)
class CollegeApplicationModel {
  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String studentRoll;
  final String studentDepartment;
  final double studentCgpa;
  final String projectId;
  final String projectTitle;
  final String companyName;
  final String status; // Applied, Under Review, Shortlisted, Interview, Selected, Rejected
  final String resumeUrl;
  final String coverLetter;
  final DateTime appliedAt;

  const CollegeApplicationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.studentRoll,
    required this.studentDepartment,
    required this.studentCgpa,
    required this.projectId,
    required this.projectTitle,
    required this.companyName,
    required this.status,
    required this.resumeUrl,
    required this.coverLetter,
    required this.appliedAt,
  });

  factory CollegeApplicationModel.fromJson(Map<String, dynamic> json) {
    // Extract populated student object safely
    final studentData = json['student'] is Map<String, dynamic>
        ? json['student'] as Map<String, dynamic>
        : <String, dynamic>{};
    
    // Extract populated project object safely
    final projectData = json['project'] is Map<String, dynamic>
        ? json['project'] as Map<String, dynamic>
        : <String, dynamic>{};

    // Extract populated company object or nested in project
    final companyData = json['company'] is Map<String, dynamic>
        ? json['company'] as Map<String, dynamic>
        : (projectData['company'] is Map<String, dynamic>
            ? projectData['company'] as Map<String, dynamic>
            : <String, dynamic>{});

    final projectTitle = projectData['title']?.toString() ?? 'Software Engineer Role';
    final companyName = companyData['name']?.toString() ??
        (projectTitle.contains('-') ? projectTitle.split('-').first.trim() : 'Corporate Partner');

    DateTime parsedDate;
    try {
      parsedDate = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now();
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return CollegeApplicationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'app_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentData['_id']?.toString() ?? json['student']?.toString() ?? '',
      studentName: studentData['name']?.toString() ?? 'Student Candidate',
      studentEmail: studentData['email']?.toString() ?? 'student@college.edu',
      studentRoll: studentData['rollNumber']?.toString() ?? studentData['roll']?.toString() ?? 'CS-2024',
      studentDepartment: studentData['department']?.toString() ?? 'Computer Science',
      studentCgpa: (studentData['cgpa'] as num?)?.toDouble() ?? 8.2,
      projectId: projectData['_id']?.toString() ?? json['project']?.toString() ?? '',
      projectTitle: projectTitle,
      companyName: companyName,
      status: json['status']?.toString() ?? 'Applied',
      resumeUrl: json['resume']?.toString() ?? '',
      coverLetter: json['coverLetter']?.toString() ?? '',
      appliedAt: parsedDate,
    );
  }

  // Convenience alias getters for UI consistency
  String get candidateName => studentName;
  String get department => studentDepartment;
  double get cgpa => studentCgpa;
  String get jobTitle => projectTitle;
  String get appliedDate => '${appliedAt.day}/${appliedAt.month}/${appliedAt.year}';

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'selected':
        return AppColors.success;
      case 'interview':
        return AppColors.accentViolet;
      case 'shortlisted':
        return const Color(0xFF0284C7);
      case 'under review':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      case 'applied':
      default:
        return AppColors.primary;
    }
  }

  Color get statusBgColor {
    switch (status.toLowerCase()) {
      case 'selected':
        return AppColors.successLight;
      case 'interview':
        return const Color(0xFFF3E8FF);
      case 'shortlisted':
        return const Color(0xFFE0F2FE);
      case 'under review':
        return AppColors.warningLight;
      case 'rejected':
        return AppColors.errorLight;
      case 'applied':
      default:
        return AppColors.primaryLight;
    }
  }

  static List<CollegeApplicationModel> get mockApplications => [
        CollegeApplicationModel(
          id: 'app_1',
          studentId: 'st_1',
          studentName: 'Aarav Sharma',
          studentEmail: 'aarav.sharma@college.edu',
          studentRoll: '2022CS104',
          studentDepartment: 'CSE',
          studentCgpa: 9.1,
          projectId: 'p_1',
          projectTitle: 'Google - Software Engineer (STEP)',
          companyName: 'Google',
          status: 'Interview',
          resumeUrl: 'https://example.com/resume_aarav.pdf',
          coverLetter: 'Passionate about backend systems and distributed architectures.',
          appliedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        CollegeApplicationModel(
          id: 'app_2',
          studentId: 'st_2',
          studentName: 'Sneha Patel',
          studentEmail: 'sneha.patel@college.edu',
          studentRoll: '2022IT089',
          studentDepartment: 'IT',
          studentCgpa: 8.8,
          projectId: 'p_2',
          projectTitle: 'Microsoft - Cloud Solutions Associate',
          companyName: 'Microsoft',
          status: 'Selected',
          resumeUrl: 'https://example.com/resume_sneha.pdf',
          coverLetter: 'Certified in Azure Cloud with experience in Kubernetes.',
          appliedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        CollegeApplicationModel(
          id: 'app_3',
          studentId: 'st_3',
          studentName: 'Rohan Deshmukh',
          studentEmail: 'rohan.d@college.edu',
          studentRoll: '2022EC045',
          studentDepartment: 'ECE',
          studentCgpa: 8.4,
          projectId: 'p_3',
          projectTitle: 'Amazon - SDE-1 Graduate',
          companyName: 'Amazon',
          status: 'Shortlisted',
          resumeUrl: 'https://example.com/resume_rohan.pdf',
          coverLetter: 'Strong problem solver with 500+ LeetCode problems solved.',
          appliedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        CollegeApplicationModel(
          id: 'app_4',
          studentId: 'st_4',
          studentName: 'Pooja Verma',
          studentEmail: 'pooja.verma@college.edu',
          studentRoll: '2022CS012',
          studentDepartment: 'CSE',
          studentCgpa: 8.9,
          projectId: 'p_1',
          projectTitle: 'Google - Software Engineer (STEP)',
          companyName: 'Google',
          status: 'Under Review',
          resumeUrl: 'https://example.com/resume_pooja.pdf',
          coverLetter: 'Proficient in Flutter, React, and Python.',
          appliedAt: DateTime.now().subtract(const Duration(hours: 14)),
        ),
      ];
}
