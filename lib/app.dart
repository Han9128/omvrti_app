import 'package:flutter/material.dart';
import 'package:omvrti_app/core/router/app_router.dart';
import 'package:omvrti_app/core/theme/app_theme.dart';
import 'package:flutter/services.dart';

class OmVrtiApp extends StatelessWidget {
  const OmVrtiApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'OmVrti.ai',
      // this removes the default debug modes shown on emulator when we run
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // This hands navigation control to go_router completely
      // AppRouter.router decides which screen to show based on current path
      routerConfig: AppRouter.router,
    );
  }
}
