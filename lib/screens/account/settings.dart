import 'package:app_settings/app_settings.dart';
import 'package:clann/constants/colors.dart';
import 'package:clann/viewmodel/auth/auth_vm.dart';
import 'package:clann/viewmodel/user_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  final toggle = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_rounded, color: mainBlue),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
            if(userState.user?.is_cr ?? false)
            _settingsTile(
              Icons.school_outlined,
              "Manage Students",
              () => context.push("/manage_students"),
            ),
            _settingsTile(
              Icons.notifications_none_rounded,
              "Notifications",
              () {
                AppSettings.openAppSettings(type: AppSettingsType.notification);
              },
            ),
            // Divider(),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            //   child: Row(
            //     children: [
            //       Icon(Icons.brightness_6, color: mainBlue),
            //       SizedBox(width: 10.w),
            //       Text(
            //         "Dark Mode",
            //         style: TextStyle(
            //           fontWeight: FontWeight.w600,
            //           color: Colors.black,
            //           fontSize: 20.sp,
            //         ),
            //       ),
            //       Spacer(),
            //       SizedBox(
            //         height: 20.h,
            //         child: Switch(
            //           value: toggle,
            //           onChanged: (value) {
            //           },
            //           padding: EdgeInsetsGeometry.zero,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            _settingsTile(
              Icons.logout_rounded,
              "Logout",
              () => ref.watch(authProvider.notifier).signOut(context),
              textColor: Color(0xffFE7474),
            ),
            SizedBox(height: 20.h),
            Opacity(
              opacity: 0.5,
              child: SvgPicture.asset("assets/images/settings.svg"),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _settingsTile(
  IconData icon,
  String title,
  VoidCallback onPressed, {
  Color? textColor,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Column(
      children: [
        Divider(),
        Container(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Row(
              children: [
                Icon(icon, color: mainBlue),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.black,
                    fontSize: 20.sp,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
