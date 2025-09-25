import 'package:clann/constants/colors.dart';
import 'package:clann/viewmodel/auth/auth_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  bool showPass = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 10.h),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Opacity(
                  opacity: 0.5,
                  child: SvgPicture.asset(
                    "assets/images/time_clock.svg",
                    height: 150.h,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email"),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsetsGeometry.all(10.h),
                      fillColor: tfGrey,
                      hintText: "2****@krmu.edu.in",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Password"),
                  TextField(
                    controller: passwordController,
                    obscureText: showPass,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsetsGeometry.all(10.h),
                      fillColor: tfGrey,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showPass = !showPass;
                          });
                        },
                        icon: showPass
                            ? Icon(Icons.visibility_off_rounded)
                            : Icon(Icons.visibility_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 80.h),
              TextButton(
                onPressed: () async{
                  await ref.read(authProvider.notifier).signIn(emailController.text, passwordController.text, context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(mainBlue),
                  padding: WidgetStateProperty.all(
                    EdgeInsetsGeometry.symmetric(horizontal: 40.w),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => context.pushReplacement("/signup"),
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        EdgeInsetsGeometry.zero,
                      ),
                    ),
                    child: Text("Sign up", style: TextStyle(color: mainBlue)),
                  ),
                ],
              ),
              Spacer(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     _buildTab(
              //       "Login as CR",
              //       isCrSelected,
              //       () => setState(() => isCrSelected = true),
              //     ),
              //     SizedBox(width: 50.w),
              //     _buildTab(
              //       "Login as Student",
              //       !isCrSelected,
              //       () => setState(() => isCrSelected = false),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget _buildTab(String text, bool isSelected, VoidCallback onTap) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           text,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: isSelected ? mainBlue : Colors.grey,
//           ),
//         ),
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           height: 3,
//           width: isSelected
//               ? text.length * 8.0
//               : 0, // underline width based on text length
//           margin: const EdgeInsets.only(top: 4),
//           color: Colors.blue,
//         ),
//       ],
//     ),
//   );
// }
