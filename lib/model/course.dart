class Course {
  final String courseId;
  final String courseName;

  Course({required this.courseId, required this.courseName});

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseId: map['course_id']?.toString() ?? '',
      courseName: map['course_name'] ?? '',
    );
  }
}