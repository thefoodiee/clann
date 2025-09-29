import 'package:clann/constants/colors.dart';
import 'package:clann/viewmodel/post_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WritePostScreen extends ConsumerWidget {

  final TextEditingController postController = TextEditingController();

  WritePostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postState = ref.watch(postsProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 15.sp, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Create Post",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: postState.isLoading
                        ? null
                        : () async {
                      await ref
                          .read(postsProvider.notifier)
                          .createPost(postController.text.trim());
                      postController.clear();
                      if(!context.mounted) return;
                      context.pop();
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(fontSize: 15.sp, color: mainBlue),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey.shade300,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: TextField(
                  autofocus: true,
                  controller: postController,
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 15.sp,
                  ),
                  maxLines: null,
                  minLines: 1,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 8.w),
                      child: Icon(Icons.edit_rounded, size: 20.sp),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    hintText: "Write your message...",
                    hintStyle: TextStyle(fontFamily: "Inter")
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
