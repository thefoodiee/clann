import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/colors.dart';

class ManualCodeScreen extends StatelessWidget {
  const ManualCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: Stack(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back_rounded, color: mainBlue),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.5,
                  child: SvgPicture.asset(
                    "assets/images/manual_code.svg",
                    height: 250.h,
                  ),
                ),
                SizedBox(height: 15.h),
                TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsetsGeometry.all(10.h),
                    fillColor: tfGrey,
                    hintText: "Class code",
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                TextButton(
                  onPressed: () {
                    //   TODO: submit code
                    //   context.go("/home");
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
                    style: TextStyle(color: Colors.white, fontSize: 18.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
