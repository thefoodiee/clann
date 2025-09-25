import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/post.dart';

class PostState {
  final bool isLoading;
  final String? errorMessage;
  final List<Post> posts;

  PostState({
    this.isLoading = false,
    this.errorMessage,
    this.posts = const [],
  });

  PostState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Post>? posts,
  }) {
    return PostState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      posts: posts ?? this.posts,
    );
  }
}

class PostsViewModel extends StateNotifier<PostState> {

  final SupabaseClient _supabase;

  PostsViewModel(this._supabase) : super(PostState());

  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userEmail = _supabase.auth.currentUser?.email;
      if (userEmail == null) throw Exception("User not logged in");

      // Get program_id
      final userData = await _supabase
          .from('users')
          .select('program_id')
          .eq('email', userEmail)
          .single();

      final programId = userData['program_id'];

      // Fetch posts
      final response = await _supabase
          .from('posts')
          .select('post_id, content, created_at, users(name)')
          .eq('program_id', programId)
          .order('created_at', ascending: false);

      final posts = (response as List<dynamic>)
          .map((post) => Post.fromMap(post as Map<String, dynamic>))
          .toList();

      state = state.copyWith(isLoading: false, posts: posts);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createPost(String content) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userEmail = _supabase.auth.currentUser?.email;
      if (userEmail == null) throw Exception("User not logged in");

      // Get user's program & id
      final userData = await _supabase
          .from('users')
          .select('program_id, user_id')
          .eq('email', userEmail)
          .single();

      final programId = userData['program_id'];
      final userId = userData['user_id'];

      // Insert post and return the row with join
      final inserted = await _supabase.from('posts').insert({
        'content': content,
        'program_id': programId,
        'user_id': userId,
      }).select('post_id, content, created_at, users(name)').single();

      final newPost = Post.fromMap(inserted);

      // Prepend new post to list
      state = state.copyWith(
        isLoading: false,
        posts: [newPost, ...state.posts],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final postsProvider =
StateNotifierProvider<PostsViewModel, PostState>((ref) {
  final supabase = Supabase.instance.client;
  return PostsViewModel(supabase);
});