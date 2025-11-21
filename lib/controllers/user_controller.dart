import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_flutter_app/utils/app_constant.dart';
import '../dbservice/db_helper.dart';
import '../model/usermodel.dart';
import '../widgets/app_snackbars.dart';

class UserController extends GetxController {
  // PagingController for infinite scroll
  final PagingController<int, UserModel> pagingController =
      PagingController<int, UserModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllUsers(page: pageKey),
      );

  @override
  void onInit() async {
    // await fetchAllUsers(isInitial: true);
    fetchUser();
    super.onInit();
    pagingController.refresh();
  }

  @override
  void onClose() {
    pagingController.dispose();
    super.onClose();
  }

  RxBool isLoading = false.obs;
  RxList<UserModel> users = <UserModel>[].obs;

  // fetch all users
  RxInt currentPage = 0.obs;
  int pageSize = 10;
  RxInt totalPages = 0.obs;
  String searchQuery = "";

  // fetch all paginate users
  static Future<List<UserModel>> fetchAllUsers({required int page}) async {
    try {
      final controller = Get.find<UserController>();
      controller.isLoading.value = true;
      final query = controller.searchQuery.isNotEmpty
          ? controller.searchQuery
          : null;
      final newUsers = await DatabaseHelper.instance.getAllUsers(
        limit: controller.pageSize,
        offset: (page - 1) * controller.pageSize,
        searchQuery: query,
      );
      controller.totalPages.value = await DatabaseHelper.instance
          .getUsersTotalPages(
            pageSize: controller.pageSize,
            searchQuery: query,
          );
      return newUsers;
    } catch (e) {
      log("error (fetchAllUsers) : : : :: : : ${e.toString()}");
      return [];
    } finally {
      Get.find<UserController>().isLoading.value = false;
    }
  }

  // Update search query and refresh the list
  void updateSearchQuery(String query) {
    searchQuery = query;
    pagingController.refresh(); // Refresh the list when search changes
  }

  // Add OR Edit User
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController oldPassController = TextEditingController();
  TextEditingController repassController = TextEditingController();
  // fetch single user for edit
  Future<void> fetchUserForEdit() async {
    try {
      var result = await DatabaseHelper.instance.getUserByID(
        userid: storage.read(USERID),
      );
      if (result != null && result.isNotEmpty) {
        final UserModel user = UserModel.fromMap(result);
        nameController.text = user.userName;
        contactController.text = user.contact.toString();
        emailController.text = user.email;
        passController.text = user.password;
      }
    } catch (e) {
      log("error (fetchUserForEdit) : : : --> ${e.toString()}");
    }
  }

  GetStorage storage = GetStorage();

  RxString userName = "".obs;
  RxString userEmail = "".obs;

  // addEditUser
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final user = UserModel(
        userId: storage.read(USERID),
        userName: nameController.text.trim(),
        contact: int.parse(contactController.text.trim()),
        email: emailController.text.trim(),
        password: passController.text.trim(),
        role: "User",
      );
      var result = await DatabaseHelper.instance.updateUser(
        user: user,
        userid: storage.read(USERID),
      );
      if (result != null && result != 0) {
        Get.back();
        storage.write(CONTACT, int.parse(contactController.text));
        storage.write(USERNAME, nameController.text);
        storage.write(EMAIL, emailController.text);
        fetchUser();
        clearControllers();
        AppSnackbars.success('Success', 'Profile updated successfully!');
        log("User updated successfully!");
      } else if (result == null) {
        AppSnackbars.error('Failed', 'Failed to update profile!');
        log("failed to update user!");
      }
    } catch (e) {
      AppSnackbars.error('Error!', 'Something went wrong!');
      log("error (addEditUser) : : : --> ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchUser() {
    if (storage.hasData(USERNAME) && storage.hasData(EMAIL)) {
      userName.value = storage.read(USERNAME);
      userEmail.value = storage.read(EMAIL);
    }
  }

  // Delete user
  Future<void> deleteUser({required int id}) async {
    try {
      var result = await DatabaseHelper.instance.deleteUser(userid: id);
      if (result != null && result != 0) {
        AppSnackbars.success('Success', 'User deleted successfully!');
        log("user deleted successfully!");
        pagingController.refresh();
      } else {
        AppSnackbars.error('Failed', 'failed to delete user!');
        log("failed to delete user!");
      }
    } catch (e) {
      AppSnackbars.error('Error!', "Something went wrong!");
      log("error (deleteUser (controller)) : : :  -- > ${e.toString()}");
    }
  }

  // update password
  Future<void> changePassword() async {
    try {
      isLoading.value = true;
      if (oldPassController.text == storage.read(PASSWORD)) {
        if (passController.text == repassController.text) {
          var result = await DatabaseHelper.instance.updatePassword(
            newPassword: repassController.text,
            userID: storage.read(USERID),
          );
          if (result != null && result != 0) {
            Get.back();
            storage.write(PASSWORD, repassController.text);
            clearControllers();
            Get.closeAllSnackbars();
            AppSnackbars.success("Success!", "Password changed successfully!");
          } else {
            Get.closeAllSnackbars();
            AppSnackbars.error("Failed", "Failed to change password!");
          }
        } else {
          Get.closeAllSnackbars();
          AppSnackbars.warning(
            "Password Mismatch!",
            "Repeat password do not matched",
          );
        }
      } else {
        Get.closeAllSnackbars();
        AppSnackbars.warning('Oops!', "Old password is invalid");
      }
    } catch (e) {
      Get.closeAllSnackbars();
      AppSnackbars.error("Error!", "Something went wrong!");
      log("error (changePassword) : : : : : : ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // clear all controllers
  clearControllers() {
    nameController.clear();
    contactController.clear();
    emailController.clear();
    oldPassController.clear();
    passController.clear();
    passController.clear();
    repassController.clear();
  }
}
