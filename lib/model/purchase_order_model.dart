import '../utils/app_constant.dart';

class PurchaseOrderModel {
  int? id;
  int supplierId;

  int isPartiallyReceived;
  DateTime orderDate;
  int totalQty;
  double totalCost;
  String? supplier;
  int isReceived;

  PurchaseOrderModel({
    this.id,
    this.supplier,
    required this.isReceived,

    required this.isPartiallyReceived,
    required this.supplierId,
    required this.orderDate,
    required this.totalQty,
    required this.totalCost,
  });

  factory PurchaseOrderModel.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderModel(
      id: map[PURCHASE_ORDER_ID],
      supplier: map[SUPPLIER_NAME] ?? 'undefined',
      isReceived: map[IS_RECEIVED] ?? 0,
      supplierId: map[SUPPLIER_ID],
      orderDate: DateTime.parse(map[ORDER_DATE]),
      totalQty: map[TOTAL_QTY] ?? 0,
      totalCost: map[TOTAL_COST],

      isPartiallyReceived: map[IS_PARTIALLY_RECIEVED]
    );
  }

  Map<String, dynamic> toMap() {
    return {
      PURCHASE_ORDER_ID: id,
      SUPPLIER_ID: supplierId,
      ORDER_DATE: orderDate.toIso8601String(),
      TOTAL_QTY: totalQty,
      TOTAL_COST: totalCost,

      IS_PARTIALLY_RECIEVED: isPartiallyReceived,
      IS_RECEIVED: isReceived ?? 0
    };
  }
}
