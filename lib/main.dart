import 'package:clann/constants/colors.dart';
import 'package:clann/router.dart';
import 'package:clann/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.top,
    SystemUiOverlay.bottom,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));

  await Supabase.initialize(
    url: 'https://drijtusuhzbqxkqplpee.supabase.co',
    anonKey: 'sb_publishable_oE89EC9eHUXq3VU9gKFXDQ_KrJyM395',
  );

  await NotificationService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      child: SafeArea(
        child: ProviderScope(
          child: MaterialApp.router(
            theme: ThemeData(
              fontFamily: "Poppins",
              colorSchemeSeed: mainBlue,
            ),
            // darkTheme: ThemeData(
            //   colorSchemeSeed: Color(0xff283A56),
            //   brightness: Brightness.dark
            // ),
            // themeMode: ThemeMode.dark,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            title: 'Clann',
          ),
        ),
      ),
    );
  }
}
