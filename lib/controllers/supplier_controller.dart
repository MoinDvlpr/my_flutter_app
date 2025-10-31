import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../dbservice/db_helper.dart';
import '../model/supplier_model.dart';
import '../utils/dialog_utils.dart';
import '../widgets/app_snackbars.dart';

class SupplierController extends GetxController {
  // PagingController for infinite scroll
  final PagingController<int, SupplierModel> pagingController =
  PagingController<int, SupplierModel>(
    // Start with page 1
    getNextPageKey: (state) =>
    state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => fetchAllActiveSuppliers(page: pageKey),
  );

  @override
  void onInit() async {
    super.onInit();
    pagingController.refresh();
  }

  @override
  void onClose() {
    pagingController.dispose();
    super.onClose();
  }

  // Update search query and refresh the list
  void updateSearchQuery(String query) {
    searchQuery = query;
    pagingController.refresh(); // Refresh the list when search changes
  }


  // fetch all active suppliers
  final pageSize = 20;
  String searchQuery = "";

  static Future<List<SupplierModel>> fetchAllActiveSuppliers({
    required int page,
  }) async {
    try {
      final controller = Get.find<SupplierController>();
      final query = controller.searchQuery.trim().isNotEmpty
          ? controller.searchQuery
          : null;
      final newSuppliers = await DatabaseHelper.instance.getSuppliers(
        searchQuery: query,
        limit: controller.pageSize,
        offset: (page - 1) * controller.pageSize, // Offset for pagination
      );
      return newSuppliers;
    } catch (e) {
      log("Error fetching categories: $e");
      return [];
    }
  }

  // add OR edit supplier
  RxBool isLoading = false.obs;
  TextEditingController supplierNameController = TextEditingController();
  TextEditingController supplierContactController = TextEditingController();

  TextEditingController dropdownSearchController = TextEditingController();

Future<void> addEditSupplier({int? supplierID}) async {
    try {
      final supplier = SupplierModel(supplierName: supplierNameController.text.trim(), contact: int.parse(supplierContactController.text.toString()), isDeleted: 0);
      if(supplierID == null){
        final result = await DatabaseHelper.instance.insertSupplier(supplier);
        if(result != 0){
          clearControllers();
          Get.back();
          Get.closeAllSnackbars();
          AppSnackbars.success('Success!', "Supplier added successfully!");
          pagingController.refresh();
        } else {
          Get.closeAllSnackbars();
          AppSnackbars.error('Failed', "Failed to add supplier");
        }
      } else {
        supplier.supplierId = supplierID;
        final result = await DatabaseHelper.instance.updateSupplier(supplierID, supplier);
        if(result != 0){
          clearControllers();
          Get.back();
          Get.closeAllSnackbars();
          AppSnackbars.success('Success!', "Supplier updated successfully!");
          pagingController.refresh();
        } else {
          Get.closeAllSnackbars();
          AppSnackbars.error('Failed', "Failed to update supplier");
        }
      }

    } catch(e) {
log("error (addEditSupplier) :: :: :: errors ${e.toString()}");
    }
}

// delete supplier (make soft delete only)
  Future<void> deleteSupplier(int supplierID,SupplierModel supplier) async {
  supplier.isDeleted = 1;
  final result = await DatabaseHelper.instance.updateSupplier(supplierID, supplier);
  if(result != 0){
    Get.back();
    DialogUtils.showSuccessDialog(
      title: 'Success',
      message: 'Supplier deleted successfully!',
    );
    log("supplier deleted successfully!");
    pagingController.refresh();
  } else {
    Get.back();
    DialogUtils.showErrorDialog(
      title: 'Failed',
      message: 'Failed to delete supplier!',
    );
    log("failed to delete supplier!");
  }
  }

// clear controllers
clearControllers(){
  supplierNameController.clear();
  supplierContactController.clear();
}

}
