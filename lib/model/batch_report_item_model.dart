class BatchProductItem {
  final String serialNumber;
  final bool isSold;
  final String productName;
  final double soldAt;
  final double costPrice;
  final double? actualSoldPrice;
  final String? soldDate;

  BatchProductItem({
    required this.serialNumber,
    required this.isSold,
    required this.productName,
    required this.soldAt,
    required this.costPrice,
    this.actualSoldPrice,
    this.soldDate,
  });

  factory BatchProductItem.fromMap(Map<String, dynamic> map) {
    return BatchProductItem(
      serialNumber: map['serial_number']?.toString() ?? '',
      isSold: (map['is_sold'] as int) == 1,
      productName: map['product_name']?.toString() ?? '',
      soldAt: double.tryParse(map['sold_at']?.toString() ?? '0') ?? 0.0,
      costPrice: double.tryParse(map['cost_price']?.toString() ?? '0') ?? 0.0,
      actualSoldPrice: map['actual_sold_price'] != null
          ? double.tryParse(map['actual_sold_price'].toString())
          : null,
      soldDate: map['sold_date']?.toString(),
    );
  }
}