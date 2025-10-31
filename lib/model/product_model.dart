import '../utils/app_constant.dart';

class ProductModel {
  final int? productId; // nullable for insert (autoincrement)
  final String productName;
  final String? description;
  String? srNo;
  final String insertDate;
  final double price;
  final double marketPrice;
  final int stockQty;
  final int soldQty;
  final int categoryId;
  final String? categoryName;
  final String productImage; // now required
  bool isFavorite;

  final double? discountedPrice;
  final double? discountPercentage;

  ProductModel({
    this.productId,
    required this.productName,
    required this.marketPrice,
    required this.insertDate,
    this.isFavorite = false,

    this.description,
    this.srNo,
    required this.price,
    required this.stockQty,
    required this.soldQty,
    required this.categoryId,
    required this.productImage,
    this.categoryName,
    this.discountedPrice,
    this.discountPercentage,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map[PRODUCT_ID],
      marketPrice: map[MARKET_RATE],
      productName: map[PRODUCT_NAME],
      description: map[DESCRIPTION],
      srNo: map[SERIAL_NUMBER],
      price: (map[PRICE] is int) ? (map[PRICE] as int).toDouble() : map[PRICE],
      stockQty: map[STOCK_QTY],
      soldQty: map[SOLD_QTY],
      categoryId: map[CATEGORY_ID],
      productImage: map[PRODUCT_IMAGE],
      categoryName: map[CATEGORY_NAME],
      insertDate: map[INSERT_DATE],
      isFavorite: map[IS_FAVORITE] == 1,

      discountedPrice: map['discounted_price'] != null
          ? (map['discounted_price'] as num).toDouble()
          : null,
      discountPercentage: map['discount_percentage'] != null
          ? double.tryParse(map['discount_percentage'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (productId != null) PRODUCT_ID: productId,
      PRODUCT_NAME: productName,
      SERIAL_NUMBER: srNo,
      DESCRIPTION: description,
      PRICE: price,
      MARKET_RATE: marketPrice,
      STOCK_QTY: stockQty,
      SOLD_QTY: soldQty,
      CATEGORY_ID: categoryId,
      PRODUCT_IMAGE: productImage,
      INSERT_DATE: insertDate,
    };
  }
}
