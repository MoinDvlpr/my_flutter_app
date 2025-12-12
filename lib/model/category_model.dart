import 'package:my_flutter_app/utils/app_constant.dart';

class CategoryModel {
  final dynamic categoryId; // nullable for insert (autoincrement)
  final dynamic categoryName;
  final dynamic isActive;

  CategoryModel({
    this.categoryId,
    required this.categoryName,
    required this.isActive,
  });

  // Convert from Map (from DB)
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      categoryId: map[CATEGORY_ID],
      isActive: map[IS_ACTIVE] == 1,
      categoryName: map[CATEGORY_NAME].toString().isEmpty
          ? ''
          : map[CATEGORY_NAME],
    );
  }

  // Convert to Map (for DB insert/update)
  Map<String, dynamic> toMap() {
    return {
      if (categoryId != null) CATEGORY_ID: categoryId,
      CATEGORY_NAME: categoryName,
      if (isActive != null) IS_ACTIVE: isActive ? 1 : 0,
    };
  }
}
