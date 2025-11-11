import '../utils/app_constant.dart';

class InventoryModel {
  int? id;
  int? purchaseOrderID;
  String? productName;
  int productBatch;
  int productId;
  int remaining;
  double costPerUnit;
  double? marketPrice;
  double? sellingPrice;
  double? currentSellingPrice;
  bool isReadyForSale;
  DateTime purchaseDate;
  InventoryModel({
    this.id,
    this.sellingPrice,
    this.purchaseOrderID,
    required this.productBatch,
    this.productName,
    this.marketPrice,
    this.currentSellingPrice,
    required this.costPerUnit,
    required this.isReadyForSale,
    required this.remaining,
    required this.productId,
    required this.purchaseDate,
  });

  factory InventoryModel.fromMap(Map<String, dynamic> map) {
    return InventoryModel(
      id: map[INVENTORY_ID],
      productBatch: map[PRODUCT_BATCH],
      productName: map[PRODUCT_NAME],
      marketPrice: map[MARKET_RATE],
      currentSellingPrice: map[PRICE],
      purchaseOrderID: map[PURCHASE_ORDER_ID],
      remaining: map[REMAINING],
      productId: map[PRODUCT_ID],
      costPerUnit: map[COST_PER_UNIT],
      sellingPrice: map[SELLING_PRICE],
      isReadyForSale: map[IS_READY_FOR_SALE] == 1,
      purchaseDate: DateTime.parse(map[PURCHASE_DATE].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      INVENTORY_ID: id,
      PRODUCT_BATCH: productBatch,
      PURCHASE_ORDER_ID: purchaseOrderID,
      REMAINING: remaining,
      PRODUCT_ID: productId,
      COST_PER_UNIT: costPerUnit,
      SELLING_PRICE: sellingPrice,
      IS_READY_FOR_SALE: isReadyForSale ? 1 : 0,
      PURCHASE_DATE: purchaseDate.toIso8601String(),
    };
  }
}
