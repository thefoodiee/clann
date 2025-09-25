import 'package:clann/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SvgPicture.asset("assets/images/landing.svg"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 90.h, 0, 0),
                  child: Text(
                    "Welcome to Clann",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(17.w, 0, 17.w, 130.h),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => context.push("/login"),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(mainBlue),
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                          iconSize: WidgetStateProperty.all(30.h),
                          padding: WidgetStateProperty.all(EdgeInsetsGeometry.symmetric(vertical: 22.h, horizontal: 20.w)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded),
                            Text(
                              " Login",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_rounded)
                          ],
                        ),
                      ),
                      SizedBox(height: 33.h),
                      ElevatedButton(
                        onPressed: () => context.push("/signup"),
                        style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(mainBlue),
                            foregroundColor: WidgetStateProperty.all(Colors.white),
                            iconSize: WidgetStateProperty.all(30.h),
                            padding: WidgetStateProperty.all(EdgeInsetsGeometry.symmetric(vertical: 22.h, horizontal: 20.w))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_rounded),
                            Spacer(),
                            Text(
                              "Signup ",
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                            Icon(Icons.account_circle_outlined)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
