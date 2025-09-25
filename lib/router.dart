import 'package:clann/screens/account/code/camera.dart';
import 'package:clann/screens/account/code/manual.dart';
import 'package:clann/screens/account/manage_students.dart';
import 'package:clann/screens/account/settings.dart';
import 'package:clann/screens/auth/login.dart';
import 'package:clann/screens/auth/sign_up.dart';
import 'package:clann/screens/home/write_post.dart';
import 'package:clann/screens/init/post_splash.dart';
import 'package:clann/screens/timetable/edit_timetable.dart';
import 'package:clann/screens/home/home.dart';
import 'package:clann/screens/init/landing.dart';
import 'package:clann/scan_timetable.dart';
import 'package:clann/test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final router = GoRouter(
  initialLocation: "/post_splash",
  routes: [
    GoRoute(
      path: '/test',
      builder: (context, state) => TestScreen(),
    ),

    GoRoute(
      path: '/landing',
      builder: (context, state) => LandingScreen(),
    ),

    GoRoute(
      path: '/post_splash',
      builder: (context, state) => PostSplashScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),

    GoRoute(
      path: '/signup',
      builder: (context, state) => SignUpScreen(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),

    GoRoute(
      path: '/post',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: WritePostScreen(),
          transitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          reverseTransitionDuration: Duration(milliseconds: 300)
        );
      },
    ),

    GoRoute(
      path: '/edit_timetable',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
            key: state.pageKey,
            child: EditTimetableScreen(),
            transitionDuration: Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            reverseTransitionDuration: Duration(milliseconds: 300)
        );
      },
    ),

    GoRoute(
      path: '/scan_timetable',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
            key: state.pageKey,
            child: ScanTimetableScreen(),
            transitionDuration: Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            reverseTransitionDuration: Duration(milliseconds: 300)
        );
      },
    ),

    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsScreen(),
    ),

    GoRoute(
      path: '/manage_students',
      builder: (context, state) => ManageStudentsScreen(),
    ),

    GoRoute(
      path: '/scan_code',
      builder: (context, state) => CameraCodeScreen(),
    ),

    GoRoute(
      path: '/enter_code',
      builder: (context, state) => ManualCodeScreen(),
    ),
  ],
);