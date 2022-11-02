import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app/routes/app_pages.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.amber,
  );

  ThemeData _lightTheme =
      ThemeData(brightness: Brightness.light, primaryColor: Colors.blue);
  runApp(
    GetMaterialApp(
      title: "ETS",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      // themeMode: ThemeMode.dark,
    ),
  );
}
