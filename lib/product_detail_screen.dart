import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pharma_bros/common/common_widget_controller.dart';
import 'package:pharma_bros/common/screen_size_controller.dart';
import 'package:pharma_bros/data_transfer_object/product_detail.dart';

class ProductDetailController extends GetxController {
  final productId = Get.arguments;
  final commonWidget = Get.put(CommonWidgetController());
  final screenSizeController = Get.find<ScreenSizeController>();
  var productDetail = Rxn<ProductDetail>();
  final String endPoint = 'https://api.friendly-pharmacist.com/product/detail';
  var isFetchedProduct = true.obs;
  final int maxRetries = 3;           // Maximum number of retries when occurred error
  var retryCount = 0.obs;             // Current retry count
  var takeTimeImage = ''.obs;
  var takeTimeText = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _fetchProductDetail(productId: productId);
  }

  @override
  void onClose() {
    super.onClose();
  }

  // === Fetch product detail === 
  Future<void> _fetchProductDetail({required int productId}) async {
    if (!isFetchedProduct.value) return;    // Prevent multiple calls
    isFetchedProduct(false);
    
    try {
      final response = await http.get(Uri.parse('$endPoint?product_id=$productId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(' >>> data => \n$data');
        productDetail.value = ProductDetail.fromJson(data['data']);
        productDetail.value == null ? throw Exception('fetched-product-details-is-null => product_id = $productId') : null;
      } else {
        throw const HttpException('failed-to-load-products');
      }
    } on SocketException catch (_) {
      if (retryCount.value < maxRetries) {
        commonWidget.customFailDialog(
          title: null,
          message: '인터넷이 연결이 좋지 않아요! \n다시 시도해 주세요!',
          tryAgainFunction: () {
            _fetchProductDetail(productId: productId);
          }
        );
      }
    } on HttpException catch (err, stack) {
      if (retryCount.value < maxRetries) {
        commonWidget.customFailDialog(
          title: null,
          message: '약품을 불러오지 못했어요! \n잠시 후 다시 시도해 주세요!',
          tryAgainFunction: () {
            _fetchProductDetail(productId: productId);
          }
        );
      }
      print('ERROR (fetching product details) => \n$err \nSTACK => \n$stack');
    } catch (err, stack) {
      if (retryCount.value < maxRetries) {
        commonWidget.customFailDialog(
          title: null,
          message: '약품을 불러오지 못했어요! \n잠시 후 다시 시도해 주세요!',
          tryAgainFunction: () {
            _fetchProductDetail(productId: productId);
          }
        );
      }
      print('ERROR (fetching product details) => \n$err \nSTACK => \n$stack');
      // Send error message (For example Sentry)
    } finally {
      isFetchedProduct(true);
    }
  }

  String _returnTakeTimeImage({required String time}) {
    switch (time) {
      case '아침':
        return 'assets/images/svg_Time-Morning.svg';
      case '점심':
        return 'assets/images/svg_Time-Noon.svg';
      case '저녁':
        return 'assets/images/svg_Time-Night.svg';
      default:
        return 'assets/images/default-image.png';
    }
  }

  Color _returnMealTimeColor({required String mealTime}) {
    switch (mealTime) {
      case '식전':
        return const Color(0xFF1FAF96);
      case '식후':
        return const Color(0xFFFFA722);
      case '취침전':
        return const Color(0xFFFF6683);
      default:
        return const Color(0xFFFFA722);
    }
  }

  Container leftSideDosageInstructions({required String title}) {
    return Container(
      width: screenSizeController.screenWidth.value * 0.22,
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 14.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          bottomLeft: Radius.circular(24.0),
        ),
        color: Color(0xFFF4F4F5),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenSizeController.screenWidth.value * 0.038,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Container rightSideDosageInstructions({required String takeAmount}) {
    return Container(
      width: screenSizeController.screenWidth.value * 0.22,
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 14.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
        color: Color(0xFFFFE0E6),
      ),
      child: Text(
        takeAmount.isEmpty ? '0개' : takeAmount,
        style: TextStyle(
          fontSize: screenSizeController.screenWidth.value * 0.038,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

}

class ProductDetailScreen extends StatelessWidget {
  ProductDetailScreen({Key? key}) : super(key: key);

  final controller = Get.put(ProductDetailController());
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '제품 정보',
          style: TextStyle(
            fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
            color: const Color(0xFF202022),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF202022),
            size: 24.0,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFECECEE),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() => 
          controller.isFetchedProduct.value
          ? ListView(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0,),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    /// TODO: Pending ... 
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: const Color(0xFF000000).withOpacity(0.15),
                    //     offset: const Offset(0, 2),
                    //     blurRadius: 10.0,
                    //     spreadRadius: 0.0,
                    //   ),
                    // ],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0),
                    ),
                    border: Border(bottom: BorderSide(width: 1.0, color: Color(0xFFECECEE))),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: controller.screenSizeController.screenWidth.value * 0.40,
                        height: controller.screenSizeController.screenWidth.value * 0.40,
                        child: Image.network(
                          controller.productDetail.value?.productImageUrl ?? 'basic image if there is no image',
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            }
                          },
                        ),
                      ),

                      // === Brand name ===
                      
                      Container(
                        margin: const EdgeInsets.only(top: 30.0),
                        child: Text(
                          controller.productDetail.value!.productBrandName,
                          style: TextStyle(
                            fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                            color: const Color(0xFFA1A2AA),
                          ),
                        ),
                      ),

                      // === Product name ===

                      Container(
                        margin: const EdgeInsets.only(top: 8.0),
                        child: Center( 
                          child: Container(
                            alignment: Alignment.center, 
                            child: RichText(
                              textAlign: TextAlign.center, 
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: controller.productDetail.value!.productName,
                                    style: TextStyle(
                                      fontSize: controller.screenSizeController.screenWidth.value * 0.055,
                                      color: const Color(0xFF202022),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: controller.productDetail.value!.productName));
                                        Get.snackbar('', '',
                                          backgroundColor: const Color(0xFF202022),
                                          snackPosition: SnackPosition.BOTTOM,
                                          titleText: const SizedBox.shrink(),
                                          messageText: const Text('Text copied to clipboard!', style: TextStyle(color: Colors.yellow)),
                                          margin: const EdgeInsets.all(30)
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                                        child: Icon(
                                          Icons.copy,
                                          color: const Color(0xFFA1A2AA),
                                          size: controller.screenSizeController.screenWidth.value * 0.055,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // === Product isDomestic ===

                      Container(
                        padding: const EdgeInsets.only(top: 2.0, right: 8.0, bottom: 2.0, left: 8.0),
                        margin: const EdgeInsets.only(top: 15.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: controller.productDetail.value!.isDomestic == true 
                            ? const Color(0xFFFFA722)
                            : const Color(0xFF1FAF96),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          controller.productDetail.value!.isDomestic == true  ? '국내' : '해외',
                          style: TextStyle(
                            fontSize: controller.screenSizeController.screenWidth.value * 0.032,
                            color: controller.productDetail.value!.isDomestic == true  
                            ? const Color(0xFFFFA722)
                            : const Color(0xFF1FAF96),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // === Product information ===

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0,),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg_Icon-pill.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8.0,),
                            Text(
                              '섭취 용법',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(  
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  controller.leftSideDosageInstructions(title: '1일'),
                                  controller.rightSideDosageInstructions(takeAmount: controller.productDetail.value!.perDailyIntakeCountText),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  controller.leftSideDosageInstructions(title: '1회'),
                                  controller.rightSideDosageInstructions(takeAmount: controller.productDetail.value!.perTimesIntakeAmountText),
                                ],
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

                // === How to take ===

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0,),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg_Icon-pill.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8.0,),
                            Text(
                              '섭취 방법',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // === intakeMethod === 
                      
                      for(var intakeMethod in controller.productDetail.value!.intakeMethod)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        margin: const EdgeInsets.only(top: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: const Color(0xFFF4F4F5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    controller._returnTakeTimeImage(time: intakeMethod.time),
                                    width: 40,
                                    height: 40,
                                  ),
                                  const SizedBox(width: 10.0,),
                                  Text(
                                    intakeMethod.time,
                                    style: TextStyle(
                                      fontSize: controller.screenSizeController.screenWidth.value * 0.038,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: controller._returnMealTimeColor(mealTime: intakeMethod.detailTime),
                                    ),
                                    child: Text(
                                      intakeMethod.detailTime,
                                      style: TextStyle(
                                        fontSize: controller.screenSizeController.screenWidth.value * 0.032,
                                        color: const Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10.0,),
                                  Text(
                                    intakeMethod.intakeUnit,
                                    style: TextStyle(
                                      fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                                      color: const Color(0xFFFF6683),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
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

                // === per_daily_intake_ingredient_content ===

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0,),
                      margin: const EdgeInsets.only(top: 24.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6683),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '1일 섭취량당',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFFFFF),
                                fontSize: controller.screenSizeController.screenWidth.value * 0.038,
                              ),
                            ),
                            TextSpan(
                              text: ' 함량',
                              style: TextStyle(
                                color: const Color(0xFFFFFFFF),
                                fontSize: controller.screenSizeController.screenWidth.value * 0.038,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0,),
                  child: Column(
                    children: [
                      for(var ingredientContent in controller.productDetail.value!.perDailyIntakeIngredientContent)
                      Container(
                        padding: const EdgeInsets.only(bottom: 24.0,),
                        child: Row(
                          children: [
                            SizedBox(
                              width: controller.screenSizeController.screenWidth.value * 0.50 - 16.0,
                              child: Text(
                                ingredientContent.ingredientName,
                                style: TextStyle(
                                  fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                                  color: const Color(0xFF202022),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: controller.screenSizeController.screenWidth.value * 0.50 - 16.0,
                              child: Text(
                                ingredientContent.content,
                                style: TextStyle(
                                  fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                                  color: const Color(0xFFFF6683),
                                ),
                              ),
                            ),
                          ],
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

                // === Nutrition information === 

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0,),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg_Icon-pill.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8.0,),
                            Text(
                              '영양 기능 정보',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          '국가별 기능성표기가 상이하여, 해외/국내 건강기능식품의 기능성 표기가 다를 수 있습니다.',
                          style: TextStyle(
                            fontSize: controller.screenSizeController.screenWidth.value * 0.038,
                            color: const Color(0xFFA1A2AA),
                          ),
                        ),
                      ),

                      for(var nutritionInfo in controller.productDetail.value!.nutritionInformation) ... [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0,),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: const Color(0xFFD9DADD),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              // === Custom widget Class ===
                              DynamicBackgroundText(
                                text: nutritionInfo.nutritionName,
                                backgroundColor: const Color(0xFFFFE0E6),
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                                ),
                                horizontalPadding: 10,
                              ),
                              for(var description in nutritionInfo.description) ... [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  child: Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                                      color: const Color(0xFF202022),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
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

                // === Product features ===

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0,),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg_Icon-pill.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8.0,),
                            Text(
                              '제품 특징',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                              ),
                            ),
                          ],
                        ),
                      ),
                      for(var feature in controller.productDetail.value!.productFeatures)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          color: const Color(0xFFF4F4F5),
                        ),
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: controller.screenSizeController.screenWidth.value * 0.0425,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // === End ( empty space )

                const SizedBox(height: 80.0,),

              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.blue)),
        ),
      ),
    );
  }

}

// === Dynamic background text ===

class DynamicBackgroundText extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final TextStyle textStyle;
  final double horizontalPadding;

  const DynamicBackgroundText({
    required this.text,
    required this.backgroundColor,
    required this.textStyle,
    this.horizontalPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final textWidth = textPainter.width;
        final textHeight = textPainter.height;
        final halfHeight = textHeight / 2;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 0, // 텍스트의 하단에 배경을 위치시킵니다.
              child: Container(
                color: backgroundColor,
                width: textWidth + horizontalPadding * 2, // 텍스트 너비 + 여유 공간
                height: halfHeight,
                margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                text,
                style: textStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}


/**
{
  "data": {
    "id": 26214,
    "product_image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/manual_22181.jpeg",
    "product_brand_name": "YDY뉴트리션",
    "product_name": "YDY 퓨어 리포좀 비타민C 3gx30포",
    "is_domestic": true,
    "is_show_recommend_type": false,
    "recommend_type_name": "",
    "recommend_type_name_color": "",
    "recommend_content": "",
    "is_show_purchase_section": true,
    "is_sold_out": false,
    "is_purchase_available": true,
    "origin_product_price": "29,000",
    "discount_product_percent": 5,
    "discount_product_price": "27,550",
    "product_sales_url": "https://store.kakao.com/befpharm/products/327131337",
    "per_daily_intake_count_text": "1회",
    "per_times_intake_amount_text": "1포",
    "intake_method": [
      {
        "time": "아침",
        "detail_time": "식후",
        "intake_unit": "1 포"
      }
    ],
    "per_daily_intake_ingredient_content": [
      {
        "ingredient_name": "비타민C",
        "content": "500 mg (500 %)"
      }
    ],
    "ingredients_content": "one_day",
    "nutrition_information": [
      {
        "nutrition_name": "비타민C",
        "description": [
          "- 결합조직 형성과 기능유지에 필요",
          "- 철의 흡수에 필요",
          "- 유해산소로부터 세포를 보호하는데 필요"
        ]
      }
    ],
    "product_features": [
      "가루로 된 타입",
      "물없이도 섭취 가능",
      "흡수율이 좋은 리포좀 형태의 비타민C",
      "하루 1포로 비타민C 500mg 섭취 가능"
    ]
  },
  "message": ""
}
 */