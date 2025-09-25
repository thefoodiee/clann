import 'package:intl/intl.dart';

class Post {
  final int postId;
  final String content;
  final DateTime createdAt;
  final String author;

  Post({
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.author,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['post_id'] as int,
      content: map['content'] ?? "",
      createdAt: DateTime.parse(map['created_at']).toLocal(),
      author: map['users']['name'],
    );
  }

  /// Format like: 11:11 AM · 17/09/25
  String get formattedTime {
    final time = DateFormat("hh:mm a").format(createdAt);
    final date = DateFormat("dd/MM/yy").format(createdAt);
    return "$time · $date";
  }
}
