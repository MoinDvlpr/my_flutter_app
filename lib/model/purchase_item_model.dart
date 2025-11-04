import '../utils/app_constant.dart';

class PurchaseOrderItemModel {
  String? itemName;
  String? srNo;
  double costPerUnit;
  double? marketPrice;
  double? sellingPrice;

  PurchaseOrderItemModel({
    this.itemName,
    this.srNo,
    this.marketPrice,
    this.sellingPrice,
    required this.costPerUnit,
  });

  factory PurchaseOrderItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderItemModel(
      itemName: map[PRODUCT_NAME],
      srNo: map[SERIAL_NUMBER],

      costPerUnit: map[COST_PER_UNIT],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      SERIAL_NUMBER: srNo,
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
      itemName: itemName ?? this.itemName,
      srNo: srNo ?? this.srNo,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      marketPrice: marketPrice ?? this.marketPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
    );
  }
}