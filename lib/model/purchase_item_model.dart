import '../utils/app_constant.dart';

class PurchaseOrderItemModel {
  int? purchaseOrderId;
  String? itemName;
  String? srNo;
  int productId;
  int quantity;
  int isReceived;
  double costPerUnit;
  double? marketPrice;
  double? sellingPrice;

  PurchaseOrderItemModel({

    this.itemName,
    this.srNo,
    this.marketPrice,
    this.sellingPrice,
    this.purchaseOrderId,
    required this.isReceived,
    required this.productId,
    required this.quantity,
    required this.costPerUnit,
  });

  factory PurchaseOrderItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderItemModel(

      itemName: map[PRODUCT_NAME],
      srNo: map[SERIAL_NUMBER],
      isReceived: map[IS_RECEIVED],
      purchaseOrderId: map[PURCHASE_ORDER_ID],
      productId: map[PRODUCT_ID],
      quantity: map[QUANTITY],
      costPerUnit: map[COST_PER_UNIT],
    );
  }

  Map<String, dynamic> toMap() {
    return {

      SERIAL_NUMBER: srNo,
      PURCHASE_ORDER_ID: purchaseOrderId,
      IS_RECEIVED: isReceived,
      PRODUCT_ID: productId,
      QUANTITY: quantity,
      COST_PER_UNIT: costPerUnit,
    };
  }

  PurchaseOrderItemModel copyWith({
    int? id,
    int? purchaseOrderId,
    String? itemName,
    String? srNo,
    int? productId,
    int? quantity,
    int? isReceived,
    double? costPerUnit,
    double? marketPrice,
    double? sellingPrice,
  }) {
    return PurchaseOrderItemModel(
      purchaseOrderId: purchaseOrderId ?? this.purchaseOrderId,
      itemName: itemName ?? this.itemName,
      srNo: srNo ?? this.srNo,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      isReceived: isReceived ?? this.isReceived,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      marketPrice: marketPrice ?? this.marketPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
    );
  }
}