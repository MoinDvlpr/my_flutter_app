import '../utils/app_constant.dart';

class OrderItemModel {
  final int? itemId;
  final int productID;
  final int orderId;
  final String itemName;
  final String itemImage;
  final String srNo;
  final String? itemDescription;
  final double? marketPrice;
  final double itemPrice;
  final int itemQty;
  final double? discountPercentage;

  OrderItemModel({
    this.itemId,
    this.marketPrice,
    this.itemDescription,
    this.discountPercentage,
    required this.productID,
    required this.orderId,
    required this.srNo,
    required this.itemName,
    required this.itemImage,
    required this.itemPrice,
    required this.itemQty,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      itemId: map[ITEM_ID],
      discountPercentage: map[DISCOUNT_PERCENTAGE],
      productID: map[PRODUCT_ID],
      orderId: map[ORDERID],
      itemName: map[ITEM_NAME],
      srNo: map[SERIAL_NUMBER],
      itemImage: map[ITEM_IMAGE],
      itemDescription: map[ITEM_DESCRIPTION],
      itemPrice: map[ITEM_PRICE] is int
          ? (map[ITEM_PRICE] as int).toDouble()
          : map[ITEM_PRICE],
      itemQty: map[ITEM_QTY],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (itemId != null) ITEM_ID: itemId,
      PRODUCT_ID: productID,
      ORDERID: orderId,
      ITEM_NAME: itemName,
      ITEM_IMAGE: itemImage,
      DISCOUNT_PERCENTAGE: discountPercentage,
      SERIAL_NUMBER: srNo,
      ITEM_DESCRIPTION: itemDescription,
      ITEM_PRICE: itemPrice,
      ITEM_QTY: itemQty,
    };
  }
}
