class Product {
  final int id;
  final String brandName;
  final String name;
  final String imageUrl;
  final bool isPurchaseAvailable;
  final bool isSoldOut;
  final int discountProductPercent;
  final String buyShopLink;
  final bool isDomestic;
  final String pickType;

  Product({
    required this.id,
    required this.brandName,
    required this.name,
    required this.imageUrl,
    required this.isPurchaseAvailable,
    required this.isSoldOut,
    required this.discountProductPercent,
    required this.buyShopLink,
    required this.isDomestic,
    required this.pickType,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      brandName: json['brand_name'],
      name: json['name'],
      imageUrl: json['image_url'],
      isPurchaseAvailable: json['is_purchase_available'],
      isSoldOut: json['is_sold_out'],
      discountProductPercent: json['discount_product_percent'],
      buyShopLink: json['buy_shop_link'],
      isDomestic: json['is_domestic'],
      pickType: json['pick_type'] ?? '',
    );
  }
}