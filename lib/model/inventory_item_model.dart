import '../utils/app_constant.dart';

class InventoryItemModel {
  int? id;
  int? inventoryID;
  int productId;
  String? productName;
  double? costPerUnit;
  double? marketPrice;
  String serialNumber;
  double? sellingPrice;
  bool isSold;
  InventoryItemModel({
    this.id,
    this.costPerUnit,
    this.productName,
    this.marketPrice,
    this.inventoryID,
    required this.isSold,
    required this.productId,
    required this.serialNumber,
    this.sellingPrice,
  });

  factory InventoryItemModel.fromMap(Map<String, dynamic> map) {
    return InventoryItemModel(
      id: map[INVENTORY_ITEM_ID],
      inventoryID: map[INVENTORY_ID],
      isSold: map[IS_SOLD] == 1,
      productName: map[PRODUCT_NAME],
      marketPrice: map[MARKET_RATE],
      costPerUnit :map[COST_PER_UNIT],
      productId: map[PRODUCT_ID],
      serialNumber: map[SERIAL_NUMBER],
      sellingPrice: map[SELLING_PRICE],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      INVENTORY_ITEM_ID: id,
      INVENTORY_ID:inventoryID,
      IS_SOLD:isSold ? 1:0,
      SERIAL_NUMBER: serialNumber,
    };
  }

  InventoryItemModel copyWith({
    int? id,
    int? productId,
    String? productName,
    double? costPerUnit,
    String? serialNumber,
    double? sellingPrice,
    bool? isSold
  }) {
    return InventoryItemModel(
      isSold: isSold ?? this.isSold,
      productId: productId ?? this.productId,
      id: id ?? this.id,
      productName: productName ?? this.productName,
      serialNumber: serialNumber ?? this.serialNumber,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      marketPrice: marketPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
    );
  }
}
