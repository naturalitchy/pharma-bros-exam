import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pharma_bros/common/common_widget_controller.dart';
import 'package:pharma_bros/common/screen_size_controller.dart';
import 'package:pharma_bros/data_transfer_object/product.dart';
import 'package:pharma_bros/my_info_screen.dart';
import 'package:pharma_bros/product_detail_screen.dart';

class RootController extends GetxController {
  final commonWidget = Get.put(CommonWidgetController());
  final String endPoint = 'https://api.friendly-pharmacist.com/search/product';
  final int size = 10;
  var page = 1.obs;
  var totalCount = 0.obs;
  RxList<Product> productsList = <Product>[].obs;
  var isFetchedProduct = true.obs;
  final int maxRetries = 3;           // Maximum number of retries when occurred error
  var retryCount = 0.obs;             // Current retry count

  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  FocusNode searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  String lastSearchedWord = 'YDY';    // Initial last searched word

  @override
  void onInit() {
    super.onInit();
    _textEditingController.text = 'YDY';
    _fetchProducts(targetWord: 'YDY', isScrolling: false);
    _scrollController.addListener(_onScroll);
    _textEditingController.addListener(_onTextChanged);
  }

  @override
  void onClose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textEditingController.removeListener(_onTextChanged);
    _textEditingController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }

  // === ListView Scroll Event ===
  void _onScroll() {
    searchFocusNode.unfocus();
    if(!isFetchedProduct.value) return;   // Prevent multiple calls
    // Check if scroll position is 80% of the max scroll extent
    // And if the total count of products is greater than the current list
    if (_scrollController.position.extentAfter < 500 && productsList.length < totalCount.value) {
      _fetchProducts(
          targetWord: _textEditingController.text, 
          isScrolling: true
      );
    }
  }

  // === Open keyboard ===
  void openKeyboard() {
    searchFocusNode.requestFocus();
  }

  // === Detect if the text has changed in search TextField === 
  void _onTextChanged() {
    String trimmedText = _textEditingController.text.trim();
    if (lastSearchedWord == trimmedText || trimmedText.isEmpty) return;
    lastSearchedWord = _textEditingController.text;
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    // Start or reset the debounce timer
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      // Recheck the latest text. Cause the debounce timer is asynchronous
      String latestTrimmedText = _textEditingController.text.trim();
      // Check if the text is empty
      if (latestTrimmedText.isEmpty) return;
      page.value = 1;         // Reset page number. Cause it's a new search
      productsList.clear();   // Clear the list. Cause it's a new search
      _fetchProducts(
          targetWord: _textEditingController.text, 
          isScrolling: false
      );
    });
  }

  // === Fetch products === 
  Future<void> _fetchProducts({required String targetWord,required bool isScrolling}) async {
    if (!isFetchedProduct.value)  return;    // Prevent multiple calls
    isFetchedProduct(false);

    if(isScrolling) {
      page.value += 1;
    }

    try {
      final response = await http.get(Uri.parse('$endPoint?target_word=$targetWord&page=${page.value}&size=$size'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        productsList.addAll((data['data']['product_list'] as List)
            .map((product) => Product.fromJson(product))
            .toList());
        // Initialize only on the first call and when a new search is entered
        isScrolling ? null : totalCount.value = data['data']['total_count'];
        retryCount.value = 0;
      } else {
        throw const HttpException('failed-to-load-products');
      }
    } on SocketException catch (_) {
      if (retryCount.value < maxRetries) {
        commonWidget.customFailDialog(
          title: null,
          message: '인터넷이 연결이 좋지 않아요! \n다시 시도해 주세요!',
          tryAgainFunction: () {
            _fetchProducts(targetWord: targetWord, isScrolling: isScrolling);
          }
        );
      }
    } on HttpException catch (err, stack) {
      if (retryCount.value < maxRetries) {
        commonWidget.customFailDialog(
          title: null,
          message: '약품을 불러오지 못했어요! \n잠시 후 다시 시도해 주세요!',
          tryAgainFunction: () {
            _fetchProducts(targetWord: targetWord, isScrolling: isScrolling);
          }
        );
      }
      print('ERROR (fetching products) => \n$err \nSTACK => \n$stack');
    } catch (err, stack) {
      if (retryCount.value < maxRetries) {
        commonWidget.customFailDialog(
          title: null,
          message: '약품을 불러오지 못했어요! \n잠시 후 다시 시도해 주세요!',
          tryAgainFunction: () {
            _fetchProducts(targetWord: targetWord, isScrolling: isScrolling);
          }
        );
      }
      print('ERROR (fetching products) => \n$err \nSTACK => \n$stack');
      // Send error message (For example Sentry)
    } finally {
      isFetchedProduct(true);
    }
  }
}

class RootScreen extends StatelessWidget {
  RootScreen({Key? key}) : super(key: key);

  final controller = Get.put(RootController());
  final screenSizeController = Get.find<ScreenSizeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            controller.searchFocusNode.unfocus();
          },
          child: Stack(   // For loading indicator
            children: [
              Container(
                color: const Color(0xFFFFFFFF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // === Search TextField ===

                    Container(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: TextField(
                        controller: controller._textEditingController,
                        focusNode: controller.searchFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFECECEE),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          hintText: '검색어를 입력해주세요',
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              controller._textEditingController.text = '';  // Clear text
                              controller.openKeyboard();                    // Open keyboard
                            },
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 24.0,
                                maxWidth: 24.0,
                              ),
                              padding: const EdgeInsets.all(5.0),
                              child: const Icon(
                                Icons.cancel,
                                color: Color(0xFFC6C7CC),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // === Search result texts ===

                    Obx(() {
                      if(controller.totalCount.value == 0) {
                        return Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Container(
                                  width: screenSizeController.screenWidth.value * 0.3,
                                  height: screenSizeController.screenWidth.value * 0.3,
                                  margin: EdgeInsets.only(top: screenSizeController.screenWidth.value * 0.4),
                                  child: Image.asset(
                                    'assets/images/no_product.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Text(
                                  '검색 결과가 없어요',
                                  style: TextStyle(
                                    fontSize: screenSizeController.screenWidth.value * 0.0425,
                                    color: const Color(0xFFA1A2AA),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFFECECEE),
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                color: Color(0xFFECECEE),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Obx(() => Text(
                            '검색 결과 ${controller.totalCount.value}건',
                            style: TextStyle(
                              fontSize: screenSizeController.screenWidth.value * 0.0425,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF202022),
                            ),
                          )),
                        );
                      }
                    }),
                    

                    // === Search products result list ===

                    Obx(() {
                      if(controller.totalCount.value != 0) {
                        return Expanded(
                          child: ListView.builder(
                            controller: controller._scrollController,
                            itemCount: controller.productsList.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  // Get.to(() => ProductDetailScreen(), arguments: controller.productsList[index]['id']);
                                  Get.to(() => ProductDetailScreen(), arguments: controller.productsList[index].id);
                                },
                                child: Container(
                                  // key: ValueKey(controller.productsList[index]['image_url']),
                                  padding: const EdgeInsets.all(16.0),
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFECECEE),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: screenSizeController.screenWidth.value * 0.24,
                                        height: screenSizeController.screenWidth.value * 0.24,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8.0),
                                          color: const Color(0xFFECECEE)
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: CachedNetworkImage(
                                            // imageUrl: controller.productsList[index]['image_url'],
                                            imageUrl: controller.productsList[index].imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                            // cacheKey: controller.productsList[index]['image_url'],
                                            cacheKey: controller.productsList[index].imageUrl,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: screenSizeController.screenWidth.value * 0.66,
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              controller.productsList[index].brandName,
                                              style: TextStyle(
                                                fontSize: screenSizeController.screenWidth.value * 0.038,
                                                color: const Color(0xFFA1A2AA),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              controller.productsList[index].name,
                                              style: TextStyle(
                                                fontSize: screenSizeController.screenWidth.value * 0.0425,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(top: 2.0, right: 8.0, bottom: 2.0, left: 8.0),
                                              margin: const EdgeInsets.only(top: 5.0),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4.0),
                                                border: Border.all(
                                                  color: controller.productsList[index].isDomestic == true 
                                                  ? const Color(0xFFFFA722)
                                                  : const Color(0xFF1FAF96),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Text(
                                                controller.productsList[index].isDomestic == true ? '국내' : '해외',
                                                style: TextStyle(
                                                  fontSize: screenSizeController.screenWidth.value * 0.032,
                                                  color: controller.productsList[index].isDomestic == true 
                                                  ? const Color(0xFFFFA722)
                                                  : const Color(0xFF1FAF96),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                              
                            },
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),

              // === Loading Indicator ===

              Obx(() {
                if (!controller.isFetchedProduct.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue,),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: controller.commonWidget.customBottomNavigationBar(0),
    );
  }
}



/**
 
 {
  "data": {
    "product_list": [
      {
        "id": 34910,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 퓨어리포좀 글루타치온 5g x 30포",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/34910.jpeg",
        
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/373357358",
        "is_domestic": true,
        "pick_type": ""
      },
      {
        "id": 34708,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 풀스펙 멀티비타민 1150g × 60정",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/34708.png",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/372857221",
        "is_domestic": true,
        "pick_type": "친약추천"
      },
      {
        "id": 28239,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 썬 비타민D3 2500IU",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/28239.png",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/360992532",
        "is_domestic": true,
        "pick_type": "친약추천"
      },
      {
        "id": 27487,
        "brand_name": "YDY뉴트리션",
        "name": "내몸에 효소가득",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/27487.png",
        "is_purchase_available": false,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "",
        "is_domestic": true,
        "pick_type": "친약추천"
      },
      {
        "id": 27031,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 면역 그린프로폴리스",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/27031.png",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/343986232",
        "is_domestic": true,
        "pick_type": "친약추천"
      },
      {
        "id": 26759,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 파이토 레드큐민",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/26759.jpeg",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/327194311",
        "is_domestic": true,
        "pick_type": ""
      },
      {
        "id": 26671,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 프로바이오 에스엘비(SLB)",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/manual_22638.png",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/327179393",
        "is_domestic": true,
        "pick_type": "친약추천"
      },
      {
        "id": 26215,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 코랄칼마디 1,200mg x 60정",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/manual_22182.jpeg",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/327159177",
        "is_domestic": true,
        "pick_type": "친약추천"
      },
      {
        "id": 26214,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 퓨어 리포좀 비타민C 3gx30포",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/manual_22181.jpeg",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/327131337",
        "is_domestic": true,
        "pick_type": "친약추천"
      },
      {
        "id": 25717,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 폴라 초임계 오메가3 1256mg x 30캡슐",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/manual_21684_1716256714695.png",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/327177147",
        "is_domestic": true,
        "pick_type": "친약추천"
      }
    ],
    "total_count": 13
  },
  "message": "<...>"
}

 */

/**
 
{
  "data": {
    "product_list": [
      {
        "id": 25123,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 오큐클리어 800mgX60캡슐(48g)",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/manual_21109.jpeg",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/327122260",
        "is_domestic": true,
        "pick_type": "친약추천"
      },
      {
        "id": 25118,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 마그듀오",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/manual_21104.jpeg",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/327161489",
        "is_domestic": true,
        "pick_type": "친약추천"
      },
      {
        "id": 24271,
        "brand_name": "YDY뉴트리션",
        "name": "YDY 액티브비큐텐",
        "image_url": "https://d1r0f51o4pfsh8.cloudfront.net/crwal_product/image/manual_input_126.jpeg",
        "is_purchase_available": true,
        "is_sold_out": false,
        "discount_product_percent": 5,
        "buy_shop_link": "https://store.kakao.com/befpharm/products/327126014",
        "is_domestic": true,
        "pick_type": "친약추천"
      }
    ],
    "total_count": 13
  },
  "message": "<…>"
}

 */