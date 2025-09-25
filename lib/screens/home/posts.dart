import 'package:clann/constants/colors.dart';
import 'package:clann/viewmodel/auth/auth_vm.dart';
import 'package:clann/viewmodel/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/post_vm.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  @override
  void initState() {
    super.initState();
    // fetch once on launch
    Future.microtask(() {
      ref.read(postsProvider.notifier).fetchPosts();
      final email = ref.read(authProvider.notifier).getEmail();
      ref.read(userViewModelProvider.notifier).fetchUser(email!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);
    final postsState = ref.watch(postsProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 0),
      child: Stack(
        children: [
          Column(
            children: [
              Text(
                "Posts",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(postsProvider.notifier).fetchPosts();
                  },
                  child: postsState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : postsState.errorMessage != null
                      ? Center(
                    child: Text(
                      "Error: ${postsState.errorMessage}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                      : postsState.posts.isEmpty
                      ? const Center(child: Text("No posts yet."))
                      : ListView.builder(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    itemCount: postsState.posts.length,
                    itemBuilder: (context, index) {
                      final post = postsState.posts[index];
                      return _postContainer(
                        name: post.author,
                        content: post.content,
                        time: post.formattedTime,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (userState.user?.is_cr ?? false)
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 20.h),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () => context.push("/post"),
                  backgroundColor: mainBlue,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.edit_rounded),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _postContainer({
  required String name,
  required String content,
  required String time
}) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          color: lightBlue,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: Colors.grey, offset: Offset(0, 2), blurRadius: 7),
          ],
        ),
        padding: EdgeInsetsGeometry.fromLTRB(20.w, 20.h, 20.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.account_circle_rounded, size: 30.sp),
                SizedBox(width: 5.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(name, style: TextStyle(fontSize: 16.sp)),
                        Text(
                            " $time",
                          style: TextStyle(
                            fontFamily: "Inter",
                            color: Colors.grey.shade700,
                            fontSize: 10.sp
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Class Representative",
                      style: TextStyle(fontFamily: "Inter", fontSize: 12.sp),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(content),
          ],
        ),
      ),
      SizedBox(height: 20.h),
    ],
  );
}
