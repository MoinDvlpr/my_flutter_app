import 'package:my_flutter_app/utils/app_constant.dart';

class DiscountGroupModel {
  final int? groupId;
  final String groupName;
  final double discountPercentage;
  final bool isActive;

  DiscountGroupModel({
    this.groupId,
    required this.groupName,
    required this.discountPercentage,
    required this.isActive,
  });

  // Convert from Map (from DB)
  factory DiscountGroupModel.fromMap(Map<String, dynamic> map) {
    return DiscountGroupModel(
      groupId: map[GROUP_ID],
      groupName: map[GROUP_NAME],
      isActive: map[IS_ACTIVE] == 1,
      discountPercentage: map[DISCOUNT_PERCENTAGE]?.toDouble() ?? 0.0,
    );
  }

  // Convert to Map (for DB insert/update)
  Map<String, dynamic> toMap() {
    return {
      GROUP_ID: groupId,
      GROUP_NAME: groupName,
      DISCOUNT_PERCENTAGE: discountPercentage,
      IS_ACTIVE: isActive ? 1 : 0,
    };
  }
}
