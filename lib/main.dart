import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omvrti_app/app.dart';

void main() {
  // this ensures that flutter is ready before app starts
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;
  // wrap the entire app with ProviderScope so that it manages state globally
  runApp(const ProviderScope(child: OmVrtiApp()));
}
