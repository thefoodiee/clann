import 'package:clann/constants/colors.dart';
import 'package:clann/viewmodel/auth/auth_vm.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodel/user_vm.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final email = ref.read(authProvider.notifier).getEmail();
      if (email != null) {
        ref.read(userViewModelProvider.notifier).fetchUser(email);
      }
    });
  }

  String _isCR(bool isCR){
    if(isCR) return "CR";
    return "Student";
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);

    if (userState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userState.error != null) {
      return Center(child: Text("Error: ${userState.error}"));
    }

    if (userState.user == null) {
      return const Center(child: Text("No user found"));
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Icon(
                    Icons.supervisor_account_rounded
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Account",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: IconButton(
                  onPressed: () => context.push("/settings"),
                  icon: Icon(Icons.settings),
                ),
              )
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 20.h),
                    decoration: BoxDecoration(
                        border: BoxBorder.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(15.r)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email_rounded, size: 25.sp,),
                        Column(
                          children: [
                            Text(
                              userState.user?.email ?? "No email",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                        color: Colors.grey,
                        radius: Radius.circular(15.r),
                        dashPattern: [10,6],
                        padding: EdgeInsets.zero
                    ),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 20.h),
                      decoration: BoxDecoration(
                        // border: BoxBorder.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(15.r),
                          color: Color(0xffEBF3FF)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isCR(userState.user?.is_cr ?? false),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.sp
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _leftInfoHolder("Name", userState.user?.name ?? "Unknown"),
                              _rightInfoHolder("Roll no.", userState.user?.user_id.toString() ?? "000")
                            ],
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _leftInfoHolder("Course", userState.user?.program?.programName ?? "Unknown"),
                              _rightInfoHolder("Section", userState.user?.program?.section ?? "Unknown")
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 45.h),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 20.w),
                  //   child: Container(
                  //     padding: EdgeInsetsGeometry.fromLTRB(0, 20.h, 0, 20.h),
                  //     decoration: BoxDecoration(
                  //         color: mainBlue,
                  //         boxShadow: [BoxShadow(color: Color(0xff6A6464), offset: Offset(0, 4), blurRadius: 4)],
                  //         borderRadius: BorderRadius.circular(25.r)
                  //     ),
                  //     width: double.infinity,
                  //     child: Column(
                  //       children: [
                  //         Text(
                  //           "Class Code",
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 20.sp,
                  //             color: Colors.white,
                  //           ),
                  //         ),
                  //         SizedBox(height: 10.h,),
                  //         Text(
                  //           "BCSEAIMLE2327",
                  //           style: TextStyle(
                  //               fontSize: 20.sp,
                  //               color: Colors.white,
                  //               fontFamily: "Inter"
                  //           ),
                  //         ),
                  //         SizedBox(height: 10.h,),
                  //         Container(
                  //           decoration: BoxDecoration(
                  //             border: Border.all(),
                  //             borderRadius: BorderRadius.circular(20.r),
                  //           ),
                  //           child: ClipRRect(
                  //             borderRadius: BorderRadius.circular(20.r),
                  //             child: QrImageView(
                  //               data: 'BCSEAIMLE2327',
                  //               version: QrVersions.auto,
                  //               size: 250.h,
                  //               backgroundColor: Colors.white,
                  //             ),
                  //           ),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // )
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: TextButton(
                      onPressed: null,
                      // onPressed: () {
                      //   // showDialog(context: context, builder:(context) => classJoinAlert(
                      //   //   onCameraPressed: () {
                      //   //     Navigator.of(context).pop();
                      //   //     context.push("/scan_code");
                      //   //   },
                      //   //   onTextPressed: () {
                      //   //     Navigator.of(context).pop();
                      //   //     context.push("/enter_code");
                      //   //   }
                      //   // ),);
                      // },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.grey; // disabled color
                            }
                            return mainBlue; // enabled color
                          },
                        ),
                        padding: WidgetStateProperty.all(
                          EdgeInsetsGeometry.symmetric(horizontal: 45.w),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      child: Text(
                        "Join Clan",
                        style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}

Widget _leftInfoHolder(String heading, String info){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        heading,
        style: TextStyle(
            color: Color(0xff6F7278),
            fontSize: 20.sp
        ),
      ),
      Text(
        info,
        style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold
        ),
      )
    ],
  );
}

Widget _rightInfoHolder(String heading, String info){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        heading,
        style: TextStyle(
            color: Color(0xff6F7278),
            fontSize: 20.sp
        ),
      ),
      Text(
        info,
        style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold
        ),
      )
    ],
  );
}

Widget classJoinAlert({
  VoidCallback? onCameraPressed,
  VoidCallback? onTextPressed
}) {
  return AlertDialog(
    title: const Text(
      "Pick a source:",
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.qr_code),
          title: const Text(
            "Scan QR Code",
          ),
          onTap: onCameraPressed,
        ),
        ListTile(
          leading: const Icon(Icons.edit_rounded),
          title: const Text(
            "Enter code manually",
          ),
          onTap: onTextPressed,
        ),
      ],
    ),
  );
}