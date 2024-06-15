class ProductDetail {
  final int id;
  final String productImageUrl;
  final String productBrandName;
  final String productName;
  final bool isDomestic;
  final bool isShowRecommendType;
  final String recommendTypeName;
  final String recommendTypeNameColor;
  final String recommendContent;
  final bool isShowPurchaseSection;
  final bool isSoldOut;
  final bool isPurchaseAvailable;
  final String originProductPrice;
  final int discountProductPercent;
  final String discountProductPrice;
  final String productSalesUrl;
  final String perDailyIntakeCountText;
  final String perTimesIntakeAmountText;
  final List<IntakeMethod> intakeMethod;
  final List<PerDailyIntakeIngredientContent> perDailyIntakeIngredientContent;
  final String ingredientsContent;
  final List<NutritionInformation> nutritionInformation;
  final List<String> productFeatures;

  ProductDetail({
    required this.id,
    required this.productImageUrl,
    required this.productBrandName,
    required this.productName,
    required this.isDomestic,
    required this.isShowRecommendType,
    required this.recommendTypeName,
    required this.recommendTypeNameColor,
    required this.recommendContent,
    required this.isShowPurchaseSection,
    required this.isSoldOut,
    required this.isPurchaseAvailable,
    required this.originProductPrice,
    required this.discountProductPercent,
    required this.discountProductPrice,
    required this.productSalesUrl,
    required this.perDailyIntakeCountText,
    required this.perTimesIntakeAmountText,
    required this.intakeMethod,
    required this.perDailyIntakeIngredientContent,
    required this.ingredientsContent,
    required this.nutritionInformation,
    required this.productFeatures,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      productImageUrl: json['product_image_url'],
      productBrandName: json['product_brand_name'],
      productName: json['product_name'],
      isDomestic: json['is_domestic'],
      isShowRecommendType: json['is_show_recommend_type'],
      recommendTypeName: json['recommend_type_name'] ?? '',
      recommendTypeNameColor: json['recommend_type_name_color'] ?? '',
      recommendContent: json['recommend_content'] ?? '',
      isShowPurchaseSection: json['is_show_purchase_section'],
      isSoldOut: json['is_sold_out'],
      isPurchaseAvailable: json['is_purchase_available'],
      originProductPrice: json['origin_product_price'],
      discountProductPercent: json['discount_product_percent'],
      discountProductPrice: json['discount_product_price'],
      productSalesUrl: json['product_sales_url'],
      perDailyIntakeCountText: json['per_daily_intake_count_text'],
      perTimesIntakeAmountText: json['per_times_intake_amount_text'],
      intakeMethod: (json['intake_method'] as List)
          .map((item) => IntakeMethod.fromJson(item))
          .toList(),
      perDailyIntakeIngredientContent: (json['per_daily_intake_ingredient_content'] as List)
          .map((item) => PerDailyIntakeIngredientContent.fromJson(item))
          .toList(),
      ingredientsContent: json['ingredients_content'],
      nutritionInformation: (json['nutrition_information'] as List)
          .map((item) => NutritionInformation.fromJson(item))
          .toList(),
      productFeatures: List<String>.from(json['product_features']),
    );
  }
}

class IntakeMethod {
  final String time;
  final String detailTime;
  final String intakeUnit;

  IntakeMethod({
    required this.time,
    required this.detailTime,
    required this.intakeUnit,
  });

  factory IntakeMethod.fromJson(Map<String, dynamic> json) {
    return IntakeMethod(
      time: json['time'],
      detailTime: json['detail_time'],
      intakeUnit: json['intake_unit'],
    );
  }
}

class PerDailyIntakeIngredientContent {
  final String ingredientName;
  final String content;

  PerDailyIntakeIngredientContent({
    required this.ingredientName,
    required this.content,
  });

  factory PerDailyIntakeIngredientContent.fromJson(Map<String, dynamic> json) {
    return PerDailyIntakeIngredientContent(
      ingredientName: json['ingredient_name'],
      content: json['content'],
    );
  }
}

class NutritionInformation {
  final String nutritionName;
  final List<String> description;

  NutritionInformation({
    required this.nutritionName,
    required this.description,
  });

  factory NutritionInformation.fromJson(Map<String, dynamic> json) {
    return NutritionInformation(
      nutritionName: json['nutrition_name'],
      // Check for a single string or a list of strings
      description: json['description'] is String
          ? [json['description']]
          : List<String>.from(json['description']),
    );
  }
}