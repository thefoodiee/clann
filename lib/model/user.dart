// ignore_for_file: non_constant_identifier_names

class Program {
  final String programName;
  final String section;
  final int startYear;
  final int endYear;

  Program({
    required this.programName,
    required this.section,
    required this.startYear,
    required this.endYear,
  });

  factory Program.fromMap(Map<String, dynamic> map) {
    return Program(
      programName: map['program_name'] ?? '',
      section: map['section'] ?? '',
      startYear: map['start_year'] ?? 0,
      endYear: map['end_year'] ?? 0,
    );
  }
}

class User {
  final int user_id;
  final String name;
  final String email;
  final bool is_cr;
  final String program_id;
  final Program? program;

  User({
    required this.user_id,
    required this.name,
    required this.email,
    required this.is_cr,
    required this.program_id,
    this.program,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      user_id: map['user_id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      program_id: map['program_id'] ?? '',
      is_cr: map['is_cr'] ?? false,
      program: map['programs'] != null
          ? Program.fromMap(map['programs'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'name': name,
      'is_cr': is_cr,
      'email': email,
      'program_id': program_id,
    };
  }
}
