import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharma_bros/common/screen_size_controller.dart';
import 'package:pharma_bros/root_screen.dart';

/**
 * 
 * Dart         : 3.2.3
 * Flutter      : 3.16.4
 * GetX         : 4.6.6
 */




void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final ScreenSizeController screenSizeController = Get.put(ScreenSizeController());

  @override
  Widget build(BuildContext context) {
    screenSizeController.updateScreenSize(context);
    return GetMaterialApp(
      navigatorKey: Get.key,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        fontFamily: 'NotoSansKR-Regular',
        textTheme: const TextTheme(
          bodyLarge : TextStyle(color:  Color(0xFF202022)),
          bodyMedium : TextStyle(color: Color(0xFF202022)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF202022),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFFFFFF),
          unselectedItemColor: Color(0xFFB3B5BB),
          selectedItemColor: Color(0xFF202022),
          unselectedLabelStyle: TextStyle(color: Color(0xFFB3B5BB)),
          selectedLabelStyle: TextStyle(color: Color(0xFF202022)),
        ),
      ),
      home: RootScreen(),
    );
  }
}
