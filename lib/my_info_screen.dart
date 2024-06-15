import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:pharma_bros/common/common_widget_controller.dart';
import 'package:pharma_bros/common/screen_size_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vibration/vibration.dart';

class MyInfoController extends GetxController {
  final commonWidget = Get.find<CommonWidgetController>();
  
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  _vibrate() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(duration: 100, amplitude: 64);
    }
  }
}

class MyInfoScreen extends StatelessWidget {
  MyInfoScreen({Key? key}) : super(key: key);

  final controller = Get.put(MyInfoController());
  final screenSizeController = Get.find<ScreenSizeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [

            // === Title ===
            
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFECECEE),
                    width: 1.0,
                  ),
                ),
              ),
              child: Text(
                '내 정보',
                style: TextStyle(
                  fontSize: screenSizeController.screenWidth * 0.0425,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // === Name and Email === 
            
            GestureDetector(
              onTap: () {
                controller._vibrate();
              },
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MYUNGWAN KIM',
                            style: TextStyle(
                              fontSize: screenSizeController.screenWidth * 0.0425,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'nsubway635@gmail.com',
                            style: TextStyle(
                              fontSize: screenSizeController.screenWidth * 0.0425,
                              color: const Color(0xFFA1A2AA),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_outlined, color: Color(0xFFA1A2AA),),
                  ],
                ),
              ),
            ),

            // === Border line === 

            Container(
              width: double.infinity,
              height: 8.0,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F5),
                border: Border(top: BorderSide(width: 1.0, color: Color(0xFFECECEE))),
              ),
            ),

            // === Consultation Record ===

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '상담 기록',
                    style: TextStyle(
                      fontSize: screenSizeController.screenWidth * 0.0425,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0,),
                  Text(
                    '지금까지 상담 기록을 모두 볼 수 있어요',
                    style: TextStyle(
                      fontSize: screenSizeController.screenWidth.value * 0.038,
                      color: const Color(0xFFA1A2AA),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller._vibrate();
                          },
                          child: Container(
                            width: screenSizeController.screenWidth * 0.42,
                            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 24.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F5),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              '나의 상담',
                              style: TextStyle(
                                fontSize: screenSizeController.screenWidth * 0.0425,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller._vibrate();
                          },
                          child: Container(
                            width: screenSizeController.screenWidth * 0.42,
                            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 24.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F5),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              '관심 상담',
                              style: TextStyle(
                                fontSize: screenSizeController.screenWidth * 0.0425,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // === Border line === 

            Container(
              width: double.infinity,
              height: 8.0,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F5),
                border: Border(top: BorderSide(width: 1.0, color: Color(0xFFECECEE))),
              ),
            ),

            // === Set take notice ===

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: GestureDetector(
                onTap: () {
                  controller._vibrate();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F5),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg_alarm.svg',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(width: 10.0,),
                            Text(
                              '섭취 알림 설정하기',
                              style: TextStyle(
                                fontSize: screenSizeController.screenWidth * 0.038,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_outlined,
                        color: Color(0xFFA1A2AA),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // === Border line === 

            Container(
              width: double.infinity,
              height: 8.0,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F5),
                border: Border(top: BorderSide(width: 1.0, color: Color(0xFFECECEE))),
              ),
            ),

            // === My participation ===

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '나의 참여',
                    style: TextStyle(
                      fontSize: screenSizeController.screenWidth * 0.0425,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller._vibrate();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      margin: const EdgeInsets.only(top: 16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F5),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/svg_announce.svg',
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox(width: 10.0,),
                                Text(
                                  '친한 이벤트 활동 내역',
                                  style: TextStyle(
                                    fontSize: screenSizeController.screenWidth * 0.038,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_outlined,
                            color: Color(0xFFA1A2AA),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                ],
              ),
            ),

            // === Border line === 

            Container(
              width: double.infinity,
              height: 8.0,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F5),
                border: Border(top: BorderSide(width: 1.0, color: Color(0xFFECECEE))),
              ),
            ),

            // ===  ===

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      controller._vibrate();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        '공지사항',
                        style: TextStyle(
                          fontSize: screenSizeController.screenWidth * 0.0425,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller._vibrate();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        '문의/제보하기',
                        style: TextStyle(
                          fontSize: screenSizeController.screenWidth * 0.0425,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller._vibrate();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        '친한약사 앱 칭찬하기',
                        style: TextStyle(
                          fontSize: screenSizeController.screenWidth * 0.0425,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // === Footer ===
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F5)
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            String _url = 'https://www.pharma-bros.com/terms';
                            if (await canLaunchUrlString(_url)) {
                              await launchUrlString(_url);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '이용약관',
                              style: TextStyle(
                                fontSize: screenSizeController.screenWidth * 0.038,
                                color: const Color(0xFF808288),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '\u00B7',
                          style: TextStyle(
                            fontSize: screenSizeController.screenWidth * 0.038,
                            color: const Color(0xFF808288),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            String _url = 'https://www.pharma-bros.com/privacy';
                            if (await canLaunchUrlString(_url)) {
                              await launchUrlString(_url);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              '개인정보처리방침',
                              style: TextStyle(
                                fontSize: screenSizeController.screenWidth * 0.038,
                                color: const Color(0xFF808288),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '버전 정보 v0.1.0',
                    style: TextStyle(
                      fontSize: screenSizeController.screenWidth.value * 0.032,
                      color: const Color(0xFF808288),
                    ),
                  )
                ],
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: controller.commonWidget.customBottomNavigationBar(1),
    );
  }
}
  