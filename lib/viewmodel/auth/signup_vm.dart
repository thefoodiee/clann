import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpState {
  final bool isLoading;
  final String? errorMessage;

  final List<String> programNames; // Unique program names
  final Map<String, List<String>> programSections; // programName -> sections

  final String? selectedProgram;
  final String? selectedSection;

  SignUpState({
    this.isLoading = false,
    this.errorMessage,
    this.programNames = const [],
    this.programSections = const {},
    this.selectedProgram,
    this.selectedSection,
  });

  SignUpState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<String>? programNames,
    Map<String, List<String>>? programSections,
    String? selectedProgram,
    String? selectedSection,
  }) {
    return SignUpState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      programNames: programNames ?? this.programNames,
      programSections: programSections ?? this.programSections,
      selectedProgram: selectedProgram ?? this.selectedProgram,
      selectedSection: selectedSection ?? this.selectedSection,
    );
  }
}

class SignUpViewModel extends StateNotifier<SignUpState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  SignUpViewModel() : super(SignUpState());

  // Fetch unique program names and sections
  Future<void> fetchPrograms() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Fetch all programs
      final response = await _supabase.from('programs').select();

      // if (response.error != null) {
      //   throw response.error!;
      // }
      //
      // final data = response.data as List<dynamic>;

      // Extract unique program names and sections
      final Map<String, Set<String>> temp = {};
      for (var row in response) {
        final name = row['program_name'] as String;
        final section = row['section'] as String;
        temp.putIfAbsent(name, () => {}).add(section);
      }

      // Convert Set to List for easier UI use
      final Map<String, List<String>> programSections = {
        for (var key in temp.keys) key: temp[key]!.toList()..sort()
      };

      state = state.copyWith(
        isLoading: false,
        programNames: programSections.keys.toList(),
        programSections: programSections,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Example: Set selected program & section
  void selectProgram(String program) {
    state = state.copyWith(
      selectedProgram: program,
      selectedSection: null, // reset section when program changes
    );
  }

  void selectSection(String section) {
    state = state.copyWith(selectedSection: section);
  }
}

final signUpProvider = StateNotifierProvider<SignUpViewModel, SignUpState>(
      (ref) => SignUpViewModel(),
);
