class DiscountGroupModel {
  final int? groupId;
  final String groupName;
  final double discountPercentage;

  DiscountGroupModel({
    this.groupId,
    required this.groupName,
    required this.discountPercentage,
  });

  // Convert from Map (from DB)
  factory DiscountGroupModel.fromMap(Map<String, dynamic> map) {
    return DiscountGroupModel(
      groupId: map['group_id'],
      groupName: map['group_name'],
      discountPercentage: map['discount_percentage']?.toDouble() ?? 0.0,
    );
  }

  // Convert to Map (for DB insert/update)
  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'group_name': groupName,
      'discount_percentage': discountPercentage,
    };
  }
}
