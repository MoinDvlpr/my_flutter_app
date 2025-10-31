import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/discount_group_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../model/discount_group_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../model/usermodel.dart';
import '../../../utils/debouncer.dart';
import '../../../widgets/global_textfield.dart';
import '../../../widgets/search_dropdown_with_pagination.dart';

class UserInfoScreen extends StatelessWidget {
  final UserModel user;
  UserInfoScreen({super.key, required this.user});
  final discountGroupController = Get.find<DiscountGroupController>();
  final userController = Get.find<UserController>();
  final _dbouncer = Debouncer(delay: Duration(milliseconds: 500));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Info', style: AppTextStyle.semiBoldTextstyle),
        backgroundColor: bg,
        elevation: 0,
      ),
      backgroundColor: bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        const AssetImage('assets/images/profile.jpg')
                            as ImageProvider,
                    backgroundColor: primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.userName,
                      style: AppTextStyle.semiBoldTextstyle.copyWith(
                        fontSize: 16,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // User Info
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Name", user.userName),
                  _infoRow("Email", user.email),
                  _infoRow("Contact", user.contact.toString()),
                  _infoRow("Role", user.role),
                ],
              ),
            ),
            GlobalTextFormField(
              controller: discountGroupController.discountGroupNameController,
              readOnly: true,
              label: 'Select group',
              onTap: () async {
                Get.bottomSheet(
                  CustomSearchDropdown<DiscountGroupModel>(
                    title: 'Group',

                    isLoading: discountGroupController.isLoading,
                    searchController:
                        discountGroupController.groupSearchController,
                    itemLabel: (group) => group.groupName,
                    onItemSelected: (group) async {
                      discountGroupController.setGroupID = group.groupId!;
                      discountGroupController.discountGroupNameController.text =
                          group.groupName;
                      discountGroupController.setUserID = user.userId!;
                      await discountGroupController.assignGroup(
                        isFromUserInfo: true,
                      );
                      userController.pagingController.refresh();
                    },

                    onSearch: (val) {
                      _dbouncer.run(
                        () => discountGroupController.updateSearchQuery(val),
                      );
                    },
                    pagingController: discountGroupController.pagingController,
                  ),

                  backgroundColor: Colors.white,
                  isScrollControlled: true,
                );
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Group is required';
                } else if (!discountGroupController.groups.any(
                  (group) =>
                      group.groupName.toLowerCase() == value.toLowerCase(),
                )) {
                  return 'Please select a valid group from the list';
                } else {
                  return null;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyle.lableStyle),
          ),
          Expanded(
            child: Text(value ?? "-", style: AppTextStyle.regularTextstyle),
          ),
        ],
      ),
    );
  }
}
