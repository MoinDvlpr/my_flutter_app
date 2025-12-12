import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_flutter_app/utils/app_constant.dart';

import '../dbservice/db_helper.dart';
import '../model/category_model.dart';
import '../utils/dialog_utils.dart';
import '../widgets/app_snackbars.dart';

class CategoryController extends GetxController {
  // PagingController for infinite scroll
  final PagingController<int, CategoryModel> pagingController =
      PagingController<int, CategoryModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllPaginateCategories(page: pageKey),
      );

  @override
  Future<void> onInit() async {
    pagingController.refresh();
    super.onInit();
  }

  // for get current logged in user
  final storage = GetStorage();

  @override
  void onClose() {
    pagingController.dispose();
    categoryNameController.dispose();
    super.onClose();
  }

  // Fetch paginated categories from DatabaseHelper
  final pageSize = 10; // Constant page size
  static Future<List<CategoryModel>> fetchAllPaginateCategories({
    required int page,
  }) async {
    try {
      final controller = Get.find<CategoryController>();
      final query = controller.searchQuery.trim().isNotEmpty
          ? controller.searchQuery
          : null;
      final newCategories = await DatabaseHelper.instance.getAllCategories(
        searchQuery: query,
        limit: controller.pageSize,
        userId: Get.find<CategoryController>().storage.read(USERID),
        offset: (page - 1) * controller.pageSize, // Offset for pagination
      );
      return newCategories;
    } catch (e) {
      log("Error fetching categories: $e");
      return [];
    }
  }

  // Update search query and refresh the list
  void updateSearchQuery(String query) {
    searchQuery = query;
    pagingController.refresh(); // Refresh the list when search changes
  }

  // is active inactive
  RxMap<int, bool> isCatActive = <int, bool>{}.obs;

  // active inactive handle
  Future<void> activeInactiveHandle({
    required int id,
    required int index,
  }) async {
    final currentStatus =
        isCatActive[id] ?? true; // Assume active if not explicitly set
    final newStatus = !currentStatus;

    try {
      final success = await DatabaseHelper.instance.updateCategoryStatus(
        id: id,
        isActive: newStatus,
      );
      if (success) {
        isCatActive[id] = newStatus;
        AppSnackbars.success(
          'Success!',
          'Category ${newStatus ? 'activated' : 'deactivated'} successfully!',
        );
        pagingController.refresh(); // Refresh the list to reflect status change
      } else {
        // If DB call explicitly indicates failure (e.g., returns false),
        // revert or ensure UI state reflects failure.
        AppSnackbars.error(
          'Error!',
          'Failed to update category status in the database.',
        );
      }
    } catch (e) {
      log("Error updating category status for id $id: $e");
      AppSnackbars.error(
        'Error!',
        'An error occurred while updating category status: $e',
      );
    }
  }

  /// fetch all categories without infinite
  RxBool isLoading = false.obs;
  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxInt currentPage = 0.obs;
  RxInt totalPages = 0.obs;
  String searchQuery = "";

  /// simple pagination
  Future<List<CategoryModel>> fetchAllCategories({
    bool isInitial = false,
    int? page,
  }) async {
    try {
      isLoading.value = true;
      String? query = searchQuery.trim().isNotEmpty ? searchQuery : null;
      final newCategories = await DatabaseHelper.instance.getAllCategories(
        searchQuery: query,
        limit: pageSize,
        userId: storage.read(USERID),
        offset: page ?? 1 * pageSize,
      );
      totalPages.value = await DatabaseHelper.instance.getTotalCategoryPages(
        pageSize: pageSize,
        searchQuery: query,
      );

      // Append new data
      categories.addAll(newCategories);

      return newCategories;
    } catch (e) {
      log("error (fetchAllCategories) : : :  -- > ${e.toString()}");

      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /////// Add/Edit Category ////////
  // text editing controller
  TextEditingController categoryNameController = TextEditingController();
  // addOrEditCategory
  Future<void> addOrEditCategory({int? categoryID}) async {
    try {
      isLoading.value = true;
      if (categoryID == null) {
        var result = await DatabaseHelper.instance.insertCategory(
          catgoryname: categoryNameController.text.trim(),
          isActive: isActive.value,
        );
        if (result != null && result != 0) {
          categoryNameController.clear();
          Get.back();
          Get.closeAllSnackbars();
          AppSnackbars.success('Success!', "Category added successfully!");
          pagingController.refresh();
        } else if (result == null) {
          Get.closeAllSnackbars();
          AppSnackbars.error('Failed', "Failed to add category");
        }
      } else {
        var result = await DatabaseHelper.instance.updateCategory(
          catID: categoryID,
          catgoryname: categoryNameController.text.trim(),
          isActive: isActive.value,
        );
        if (result != null && result != 0) {
          categoryNameController.clear();
          Get.back();
          Get.closeAllSnackbars();
          AppSnackbars.success('Success!', "Category updated successfully!");
          pagingController.refresh();
        } else if (result == null) {
          Get.closeAllSnackbars();
          AppSnackbars.error('Failed', "Failed to update category");
        }
      }
    } catch (e) {
      Get.closeAllSnackbars();
      AppSnackbars.error("Error!", "Something went wrong!");
    } finally {
      isLoading.value = false;
    }
  }

  // delete category
  Future<void> deleteCategory({required int id, required int index}) async {
    try {
      var result = await DatabaseHelper.instance.deleteCategory(catID: id);
      if (result != null && result != 0) {
        Get.back();
        DialogUtils.showSuccessDialog(
          title: 'Success',
          message: 'Category deleted successfully!',
        );
        log("category deleted successfully!");
        pagingController.refresh();
      } else {
        Get.back();
        DialogUtils.showErrorDialog(
          title: 'Failed',
          message: 'Failed to delete category!',
        );
        log("failed to delete category!");
      }
    } catch (e) {
      Get.back();
      DialogUtils.showErrorDialog(
        title: 'Error!',
        message: 'Something went wrong!',
      );
      log("error (deleteCategory (controller)) : : :  -- > ${e.toString()}");
    }
  }

  // active inactive for edit screen
  RxBool isActive = false.obs;
  toggleActive(bool val) {
    isActive.value = val;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
