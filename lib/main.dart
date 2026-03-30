import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/app.dart';
import 'package:omvrti_app/core/constants/app_colors.dart';

void main() {
  // this ensures that flutter is ready before app starts
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // white background
      statusBarIconBrightness: Brightness.dark, // dark icons on Android
      statusBarBrightness: Brightness.light, // dark icons on iOS
    ),
  );

  // wrap the entire app with ProviderScope so that it manages state globally
  runApp(const ProviderScope(child: OmVrtiApp()));
}
