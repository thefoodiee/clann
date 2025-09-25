class TimeTable {
  final int tId;
  final String programID;
  final String courseId;
  final String classCode;
  final String day;
  final DateTime startTime;
  final DateTime endTime;
  final String courseName;

  TimeTable({
    required this.tId,
    required this.programID,
    required this.courseId,
    required this.classCode,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.courseName
  });

  factory TimeTable.fromMap(Map<String, dynamic> map) {
    return TimeTable(
      tId: map['t_id'] is String
          ? int.parse(map['t_id'])
          : map['t_id'] as int,
      programID: map['programID']?.toString() ?? map['program_id']?.toString() ?? '',
      courseName: map['courseName'] ??
          map['courses']?['course_name'] ??
          map['course_id'] ??
          '',
      courseId: map['courseId']?.toString() ??
          map['course_id']?.toString() ??
          '',
      classCode: map['classCode'] ?? map['class_code'] ?? '',
      day: map['day'],
      startTime: DateTime.parse(map['startTime'] ?? map['start_time']),
      endTime: DateTime.parse(map['endTime'] ?? map['end_time']),
    );
  }

  @override
  String toString() {
    return '''
TimeTable(
  tId: $tId,
  programId: $programID,
  courseId: $courseId,
  classCode: $classCode,
  day: $day,
  startTime: $startTime,
  endTime: $endTime,
  courseName: $courseName
)''';
  }

  Map<String, dynamic> toMap() {
    return {
      't_id': tId,
      'courseName': courseName,
      'courseId': courseId,
      'classCode': classCode,
      'day': day,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

}