import '../utils/app_constant.dart';

class InventoryItemModel {
  int? id;

  int productId;
  int invQuantity;
  String serialNumber;
  double sellingPrice;

  InventoryItemModel({
    this.id,
    required this.invQuantity,

    required this.productId,
    required this.serialNumber,
    required this.sellingPrice,
  });

  factory InventoryItemModel.fromMap(Map<String, dynamic> map) {
    return InventoryItemModel(
      id: map[INVENTORY_ITEM_ID],
      invQuantity: map[INVENTORY_QUANTITY],

      productId: map[PRODUCT_ID],
      serialNumber: map[SERIAL_NUMBER],
      sellingPrice: map[SELLING_PRICE],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      INVENTORY_ITEM_ID: id,
      INVENTORY_QUANTITY: invQuantity,

      PRODUCT_ID: productId,
      SERIAL_NUMBER: serialNumber,
      SELLING_PRICE: sellingPrice,
    };
  }
}
