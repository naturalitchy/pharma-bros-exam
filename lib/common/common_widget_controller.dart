import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharma_bros/my_info_screen.dart';
import 'package:pharma_bros/root_screen.dart';

class CommonWidgetController extends GetxController {
  
  Future<dynamic> customFailDialog({
    required String? title,
    required String message,
    required VoidCallback? tryAgainFunction,
  }) async {
    return Get.dialog(
      Theme(
        data: ThemeData(
          useMaterial3: false,
          dialogBackgroundColor: const Color(0xFFECECEE),
        ),
        child: AlertDialog(
          title: title != null
          ? Text(
            title,
            style: const TextStyle(
              color: Color(0xFF202022),
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          )
          : const SizedBox.shrink(),
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xFF202022),
              fontSize: 14.0,
            ),
          ),
          actions: [
            Column(
              children: [
                if(tryAgainFunction != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: const Color(0xFFFFA722),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      Get.back();
                      tryAgainFunction();
                    },
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFECECEE)
                      ),
                    )
                  ),
                ),
                const SizedBox(height: 10.0,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: tryAgainFunction != null ? const Color(0xFFECECEE) : const Color(0xFFFFA722),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: tryAgainFunction != null ? const Color(0xFF202022) : const Color(0xFFECECEE)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container customBottomNavigationBar(int currentIndex) {
    return Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFECECEE),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          onTap: (index) {
            if (index == currentIndex) {
              return;
            }
            switch (index) {
              case 0:
                Get.offAll(() => RootScreen());
                break;
              case 1:
                Get.offAll(() => MyInfoScreen());
                break;
              default:
                break;
            }
          },
          currentIndex: currentIndex,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: currentIndex == 1 ? const Icon(Icons.person) : const Icon(Icons.person_outline),
              label: '내 정보',
            ),
          ],
        ),
    );
  }



}