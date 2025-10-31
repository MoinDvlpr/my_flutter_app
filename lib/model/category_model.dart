import 'package:my_flutter_app/utils/app_constant.dart';

class CategoryModel {
  final dynamic categoryId; // nullable for insert (autoincrement)
  final dynamic categoryName;

  CategoryModel({
    this.categoryId,
    required this.categoryName,
  });

  // Convert from Map (from DB)
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      categoryId: map[CATEGORY_ID],
      categoryName: map[CATEGORY_NAME].toString().isEmpty ? '':map[CATEGORY_NAME],
    );
  }

  // Convert to Map (for DB insert/update)
  Map<String, dynamic> toMap() {
    return {
      if (categoryId != null) CATEGORY_ID: categoryId,
      CATEGORY_NAME: categoryName,
    };
  }
}
