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

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // wrap the entire app with ProviderScope so that it manages state globally
  runApp(const ProviderScope(child: OmVrtiApp()));
}
