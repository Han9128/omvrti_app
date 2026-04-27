import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/app.dart';

void main() {
  // this ensures that flutter is ready before app starts. it is required to have every thing like native device features or anything setup before code loads
  WidgetsFlutterBinding.ensureInitialized();

  // this removes the debug colored outlines around every widget. when this is on then every widget is outlined to debug any style mismatch or issue.
  debugPaintSizeEnabled = false;

// this sets the system UI to edge to edge mode, which allows the app to draw behind the system status bar and navigation bar, creating a more immersive experience. It also sets the status bar and navigation bar colors to transparent and adjusts the icon brightness for better visibility.
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
