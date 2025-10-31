
import '../utils/app_constant.dart';

class SupplierModel {
  int? supplierId;
  final String supplierName;
  final int contact;
  int isDeleted;

  SupplierModel({
    this.supplierId,
    required this.supplierName,
    required this.contact,
    required this.isDeleted,
  });

  // Convert Map from DB to UserModel
  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      supplierId: map[SUPPLIER_ID],
      supplierName: map[SUPPLIER_NAME],
      contact: map[CONTACT],
        isDeleted:map[IS_DELETED]
    );
  }

  // Convert UserModel to Map for DB insert/update
  Map<String, dynamic> toMap() {
    return {
      SUPPLIER_ID: supplierId,
      SUPPLIER_NAME: supplierName,
      CONTACT:contact,
      IS_DELETED: isDeleted
    };
  }
}
