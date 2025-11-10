import 'package:my_flutter_app/utils/app_constant.dart';

/// product report model that will get by product id
class ProductReportModel {
  final int productId;
  final String productName;
  final double marketRate;
  final double averageCost;
  final double averageSellingPrice;
  final int totalBatches;
  final int totalSoldQty;
  final int totalRemaining;
  final double totalRevenue;
  final double totalProfit;
  final List<ReportItemModel> reportItems;

  ProductReportModel({
    required this.productId,
    required this.productName,
    required this.marketRate,
    required this.averageCost,
    required this.averageSellingPrice,
    required this.totalBatches,
    required this.totalSoldQty,
    required this.totalRemaining,
    required this.totalRevenue,
    required this.totalProfit,
    required this.reportItems,
  });

  factory ProductReportModel.fromMap(
    Map<String, dynamic> map,
    List<ReportItemModel> items,
  ) {
    return ProductReportModel(
      productId: map[PRODUCT_ID],
      productName: map[PRODUCT_NAME] ?? '',
      marketRate: (map[MARKET_RATE] ?? 0.0).toDouble(),
      averageCost: (map['average_cost'] ?? 0.0).toDouble(),
      averageSellingPrice: (map['average_selling_price'] ?? 0.0).toDouble(),
      totalBatches: map['total_batches'] ?? items.length,
      totalSoldQty: map['total_sold_qty'] ?? 0,
      totalRemaining: map['total_remaining'] ?? 0,
      totalRevenue: (map['total_revenue'] ?? 0.0).toDouble(),
      totalProfit: (map['total_profit'] ?? 0.0).toDouble(),
      reportItems: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'market_rate': marketRate,
      'average_cost': averageCost,
      'average_selling_price': averageSellingPrice,
      'total_batches': totalBatches,
      'total_sold_qty': totalSoldQty,
      'total_remaining': totalRemaining,
      'total_revenue': totalRevenue,
      'total_profit': totalProfit,
      'report_items': reportItems.map((e) => e.toMap()).toList(),
    };
  }
}

/// product report item model
class ReportItemModel {
  final int inventoryId;
  final int productId;
  final String? batchId; // Can map to PURCHASE_ORDER_ID
  final double costPrice;
  final double? sellingPrice;
  final int remaining;
  final int soldQty;
  final double totalRevenue;
  final DateTime purchaseDate;

  ReportItemModel({
    required this.inventoryId,
    required this.productId,
    this.batchId,
    required this.costPrice,
    this.sellingPrice,
    required this.remaining,
    required this.soldQty,
    required this.totalRevenue,
    required this.purchaseDate,
  });

  factory ReportItemModel.fromMap(Map<String, dynamic> map) {
    return ReportItemModel(
      inventoryId: map['inventory_id'],
      productId: map['product_id'],
      batchId: map['purchase_order_id']?.toString(),
      costPrice: (map['cost_per_unit'] ?? 0.0).toDouble(),
      sellingPrice: map['selling_price'] != null
          ? (map['selling_price'] as num).toDouble()
          : null,
      remaining: map['remaining'] ?? 0,
      soldQty: map['sold_qty'] ?? 0,
      totalRevenue: (map['total_revenue'] ?? 0.0).toDouble(),
      purchaseDate:
          DateTime.tryParse(map['purchase_date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inventory_id': inventoryId,
      'product_id': productId,
      'purchase_order_id': batchId,
      'cost_per_unit': costPrice,
      'selling_price': sellingPrice,
      'remaining': remaining,
      'sold_qty': soldQty,
      'total_revenue': totalRevenue,
      'purchase_date': purchaseDate.toIso8601String(),
    };
  }
}
