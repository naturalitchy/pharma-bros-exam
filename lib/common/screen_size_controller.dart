import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenSizeController extends GetxController {
  var screenWidth = 0.0.obs;
  var screenHeight = 0.0.obs;

  void updateScreenSize(BuildContext context) {
    screenWidth.value = MediaQuery.of(context).size.width;
    screenHeight.value = MediaQuery.of(context).size.height;
  }
}