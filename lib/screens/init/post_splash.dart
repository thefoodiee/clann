import 'package:clann/viewmodel/auth/auth_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class PostSplashScreen extends ConsumerStatefulWidget {
  const PostSplashScreen({super.key});

  @override
  ConsumerState<PostSplashScreen> createState() => _PostSplashScreenState();
}

class _PostSplashScreenState extends ConsumerState<PostSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    final isSignedIn = await ref.read(authProvider.notifier).isUserLoggedIn();

    if (!mounted) return;

    if (isSignedIn) {
      context.go("/home");
    } else {
      context.go("/landing");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.center,
        child: SvgPicture.asset(
          "assets/images/logo.svg",
          height: 200.h,
        ),
      ),
    );
  }
}
