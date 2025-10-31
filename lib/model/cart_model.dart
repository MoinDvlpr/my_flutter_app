import '../utils/app_constant.dart';

class CartItemModel {
  final int cartId;
  final int productId;
  final String productName;
  final String productImage;

  final double originalPrice;
  final double? discountPercentage;
  final double discountedPrice;
  final int qty;
  final double totalPrice;

  CartItemModel({
    required this.cartId,
    required this.productId,
    required this.productName,

    required this.productImage,
    required this.originalPrice,
    required this.discountedPrice,
    required this.qty,
    required this.totalPrice,
    this.discountPercentage,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      cartId: map[CART_ID],

      productId: map[PRODUCT_ID],
      productName: map[PRODUCT_NAME],
      productImage: map[PRODUCT_IMAGE],
      originalPrice: (map['original_price'] as num).toDouble(),
      discountPercentage: map[DISCOUNT_PERCENTAGE] != null
          ? (map[DISCOUNT_PERCENTAGE] as num).toDouble()
          : null,
      discountedPrice: (map['discounted_price'] as num).toDouble(),
      qty: map[PRODUCT_QTY],
      totalPrice: (map['total_price'] as num).toDouble(),
    );
  }
}
