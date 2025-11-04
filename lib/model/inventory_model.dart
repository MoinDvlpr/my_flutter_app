import '../utils/app_constant.dart';

class InventoryModel {
  int? id;
  int? purchaseOrderID;
  int productId;
  int remaining;
  double costPerUnit;
  double? sellingPrice;
  bool isReadyForSale;
  DateTime purchaseDate;
  InventoryModel({
    this.id,
    this.sellingPrice,
    this.purchaseOrderID,
    required this.costPerUnit,
    required this.isReadyForSale,
    required this.remaining,
    required this.productId,
    required this.purchaseDate,
  });

  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map[INVENTORY_ID],
      purchaseOrderID: map[PURCHASE_ORDER_ID],
      remaining: map[REMAINING],
      productId: map[PRODUCT_ID],
      costPerUnit:map[COST_PER_UNIT],
      sellingPrice: map[SELLING_PRICE],
      isReadyForSale: map[IS_READY_FOR_SALE] == 1,
      purchaseDate: DateTime.parse(map[PURCHASE_DATE].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      INVENTORY_ID:id,
      PURCHASE_ORDER_ID:purchaseOrderID,
      REMAINING:remaining,
      PRODUCT_ID: productId,
      COST_PER_UNIT:costPerUnit,
      SELLING_PRICE: sellingPrice,
      IS_READY_FOR_SALE: isReadyForSale ? 1:0,
      PURCHASE_DATE:purchaseDate.toIso8601String(),
    };
  }
}
