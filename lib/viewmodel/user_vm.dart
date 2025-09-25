import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../model/user.dart';

class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserViewModel extends StateNotifier<UserState> {
  final SupabaseClient _supabase;

  UserViewModel(this._supabase) : super(const UserState());

  /// Fetch user by email
  Future<void> fetchUser(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _supabase
          .from('users')
          .select('*, programs(program_name, section, start_year, end_year)')
          .eq('email', email)
          .single();

      final appUser = User.fromMap(data); // make sure User model handles programs
      state = state.copyWith(user: appUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Insert new user
  Future<void> createUser(User user) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('users').insert(user.toMap());
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Update existing user
  Future<void> updateUser(User user) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase
          .from('users')
          .update(user.toMap())
          .eq('user_id', user.user_id);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Delete user
  Future<void> deleteUser(int userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabase.from('users').delete().eq('user_id', userId);
      state = const UserState(); // reset
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final userViewModelProvider =
StateNotifierProvider<UserViewModel, UserState>((ref) {
  final supabase = Supabase.instance.client;
  return UserViewModel(supabase);
});
