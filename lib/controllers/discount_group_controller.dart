import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../dbservice/db_helper.dart';
import '../model/discount_group_model.dart';
import '../widgets/app_snackbars.dart';

class DiscountGroupController extends GetxController {
  // PagingController for infinite scroll
  final PagingController<int, DiscountGroupModel> pagingController =
      PagingController<int, DiscountGroupModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllGroups(page: pageKey),
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

  RxBool isLoading = false.obs;
  RxList<DiscountGroupModel> groups = <DiscountGroupModel>[].obs;
  RxList<DiscountGroupModel> filterGroups = <DiscountGroupModel>[].obs;

  RxInt currentPage = 0.obs;
  int pageSize = 20;
  RxInt totalPages = 0.obs;
  String searchQuery = "";

  // fetch all groups
  static Future<List<DiscountGroupModel>> fetchAllGroups({
    required int page,
  }) async {
    try {
      final controller = Get.find<DiscountGroupController>();
      controller.isLoading.value = true;
      String? query = controller.searchQuery.trim().isNotEmpty
          ? controller.searchQuery
          : null;
      final newGroups = await DatabaseHelper.instance.getAllGroups(
        searchQuery: query,
        limit: controller.pageSize,
        offset: (page - 1) * controller.pageSize,
      );
      return newGroups;
    } catch (e) {
      log("error (fetchAllGroups) : : :  -- > ${e.toString()}");
      return [];
    } finally {
      Get.find<DiscountGroupController>().isLoading.value = false;
    }
  }

  // Update search query and refresh the list
  void updateSearchQuery(String query) {
    searchQuery = query;
    pagingController.refresh(); // Refresh the list when search changes
  }

  /////// Add/Edit Group ////////
  // text editing controller
  TextEditingController groupNameController = TextEditingController();
  TextEditingController percentageController = TextEditingController();

  // addOrEditGroup
  Future<void> addOrEditGroup({int? groupID}) async {
    try {
      isLoading.value = true;
      if (groupID == null) {
        DiscountGroupModel group = DiscountGroupModel(
          groupName: groupNameController.text,
          discountPercentage: double.parse(percentageController.text),
        );
        var result = await DatabaseHelper.instance.insertGroup(group: group);
        if (result != null && result != 0) {
          clearControllers();
          AppSnackbars.success('Success!', "Group added successfully!");
          pagingController.refresh();
        } else {
          AppSnackbars.error('Failed', "Failed to add group");
        }
      } else {
        DiscountGroupModel group = DiscountGroupModel(
          groupId: groupID,
          groupName: groupNameController.text,
          discountPercentage: double.parse(percentageController.text),
        );

        var result = await DatabaseHelper.instance.updateGroup(group: group);
        if (result != null && result != 0) {
          clearControllers();
          AppSnackbars.success('Success!', "Group updated successfully!");
          pagingController.refresh();
        } else {
          AppSnackbars.error('Failed', "Failed to update group");
        }
      }
    } catch (e) {
      AppSnackbars.error("Error!", "Something went wrong!");
    } finally {
      isLoading.value = false;
    }
  }

  // fetch discount group by id
  Future<void> fetchGroupByID({required int groupID}) async {
    try {
      var result = await DatabaseHelper.instance.getGroupByID(groupID: groupID);
      if (result != null) {
        groupNameController.text = result.groupName;
        discountGroupNameController.text = result.groupName;
        percentageController.text = result.discountPercentage.toString();
      }
    } catch (e) {
      log("error (fetchGroupByID) : : : --> ${e.toString()}");
    }
  }

  // delete group
  Future<void> deleteGroup({required int id, required int index}) async {
    try {
      var result = await DatabaseHelper.instance.deleteGroup(groupID: id);
      if (result != null && result != 0) {
        Get.back();
        groups.removeAt(index);
        AppSnackbars.success('Success', 'Group deleted successfully!');
        log("group deleted successfully!");
      } else {
        AppSnackbars.error('Failed', 'failed to delete group!');
        log("failed to delete group!");
      }
    } catch (e) {
      AppSnackbars.error('Error!', "Something went wrong!");
      log("error (deleteGroup (controller)) : : :  -- > ${e.toString()}");
    }
  }

  void clearControllers() {
    groupNameController.clear();
    percentageController.clear();
  }

  // search group
  void search() {
    groups.clear();
    if (searchQuery.isNotEmpty) {
      for (var element in filterGroups) {
        if (element.groupName.toLowerCase().contains(
          searchQuery.toLowerCase(),
        )) {
          groups.add(element);
        }
      }
    } else {
      groups.addAll(filterGroups);
    }
  }

  // assign discount group
  // Text editing controller
  TextEditingController userNameController = TextEditingController();
  TextEditingController discountGroupNameController = TextEditingController();
  // variables
  int? _userID;
  int? _groupID;

  TextEditingController groupSearchController = TextEditingController();

  TextEditingController userSearchController = TextEditingController();

  // setters
  set setUserID(int value) {
    _userID = value;
  }

  set setGroupID(int value) {
    _groupID = value;
  }

  // getters
  int? get userID => _userID;
  int? get groupID => _groupID;

  // Assign Group
  Future<void> assignGroup({bool isFromUserInfo = false}) async {
    try {
      isLoading.value = true;
      var result = await DatabaseHelper.instance.updateUserGroup(
        groupID: groupID!,
        userID: userID!,
      );
      if (result != null && result != 0) {
        AppSnackbars.success("Success!", "Group assigned successfully!");
        if (!isFromUserInfo) {
          clearAssignControllers();
        }
      } else {
        AppSnackbars.error('Failed!', "Failed to assign group");
      }
    } catch (e) {
      log("error (assignGroup) :: :: :: -> ${e.toString()}");
      AppSnackbars.error('Error!', "Something went wrong!");
    } finally {
      isLoading.value = false;
    }
  }

  clearAssignControllers() {
    discountGroupNameController.clear();
    userNameController.clear();
    _userID = null;
    _groupID = null;
  }
}
