import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  const AuthState({this.isLoading = false, this.errorMessage, this.user});

  AuthState copyWith({bool? isLoading, String? errorMessage, User? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthViewmodel extends StateNotifier<AuthState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthViewmodel()
    : super(AuthState(user: Supabase.instance.client.auth.currentUser));

  //   signup
  Future<void> signUp({
    required String email,
    required String password,
    required int rollno,
    required String name,
    // ignore: non_constant_identifier_names
    required String program_id,
    required BuildContext context
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw Exception("Sign up failed. Please try again.");
      }

      await _supabase.from('users').insert({
        'user_id': rollno,
        'name': name,
        'email': email,
        'is_cr': false,
        'program_id': program_id,
      });
      if(!context.mounted) return;
      context.go("/home");

      state = state.copyWith(isLoading: false, user: res.user);
    } on AuthException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } on PostgrestException catch (e) {
      Fluttertoast.showToast(msg: e.message);
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      Fluttertoast.showToast(msg: "Something went wrong. Please try again.");
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
  // sign in

  Future<void> signIn(String email, String password, BuildContext context) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false, user: res.user);
      if(!context.mounted) return;
      context.go("/home");
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // sign out

  Future<void> signOut(BuildContext context) async {
    await _supabase.auth.signOut();
    state = const AuthState(user: null);
    if(!context.mounted) return;
    context.go("/landing");
  }

  Future<bool> isUserLoggedIn() async {
    final session = _supabase.auth.currentSession;

    // If session exists and user is not null → logged in
    return session != null;
  }

  // get user email
  String? getEmail() => state.user?.email;
}

final authProvider = StateNotifierProvider<AuthViewmodel, AuthState>(
  (ref) => AuthViewmodel(),
);
