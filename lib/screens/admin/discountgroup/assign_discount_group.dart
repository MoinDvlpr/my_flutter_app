import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/discount_group_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../model/discount_group_model.dart';
import '../../../model/usermodel.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/debouncer.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../../../widgets/global_textfield.dart';
import '../../../widgets/search_dropdown_with_pagination.dart';

class AssignDiscountGroup extends StatelessWidget {
  AssignDiscountGroup({super.key});
  final UserController userController = Get.find<UserController>();
  final DiscountGroupController discountGroupController =
      Get.find<DiscountGroupController>();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _dbouncer = Debouncer(delay: Duration(milliseconds: 500));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Discount Group')),

      backgroundColor: bg,
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 10),
                GlobalTextFormField(
                  controller: discountGroupController.userNameController,
                  readOnly: true,
                  label: 'Select customer',
                  onTap: () async {
                    Get.bottomSheet(
                      CustomSearchDropdown<UserModel>(
                        title: 'Customer',
                        searchController:
                            discountGroupController.userSearchController,

                        isLoading: userController.isLoading,
                        itemLabel: (user) => user.userName,
                        onItemSelected: (user) {
                          discountGroupController.setUserID = user.userId!;
                          discountGroupController.userNameController.text =
                              user.userName;
                        },

                        onSearch: (val) {
                          _dbouncer.run(
                            () => userController.updateSearchQuery(val),
                          );
                        },
                        pagingController: userController.pagingController,
                      ),

                      backgroundColor: Colors.white,
                      isScrollControlled: true,
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'User is required';
                    } else {
                      return null;
                    }
                  },
                ),

                GlobalTextFormField(
                  controller:
                      discountGroupController.discountGroupNameController,
                  readOnly: true,
                  label: 'Select group',
                  onTap: () async {
                    // await discountGroupController.fetchAllGroups(
                    //   isInitial: true,
                    // );
                    Get.bottomSheet(
                      CustomSearchDropdown<DiscountGroupModel>(
                        title: 'Group',

                        isLoading: discountGroupController.isLoading,
                        searchController:
                            discountGroupController.groupSearchController,
                        itemLabel: (group) => group.groupName,
                        onItemSelected: (group) {
                          discountGroupController.setGroupID = group.groupId!;
                          discountGroupController
                                  .discountGroupNameController
                                  .text =
                              group.groupName;
                        },

                        onSearch: (val) {
                          discountGroupController.searchQuery = val;
                        },
                        pagingController:
                            discountGroupController.pagingController,
                      ),

                      backgroundColor: Colors.white,
                      isScrollControlled: true,
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Group is required';
                    } else {
                      return null;
                    }
                  },
                ),

                // TypeAheadField<DiscountGroupModel>(
                //   controller: discountGroupController.discountGroupNameController,
                //   scrollController: _scrollController,
                //
                //   itemBuilder: (context, discount) {
                //     return Container(padding: EdgeInsets.all(8.0),child: Text(discount.groupName,style: AppTextStyle.regularTextstyle,));
                //   },
                //   onSelected: (discount) {
                //       discountGroupController.setGroupID = discount.groupId!;
                //       discountGroupController.discountGroupNameController.text = discount.groupName;
                //   },
                //   suggestionsCallback: (search) async {
                //     await discountGroupController.fetchAllGroups();
                //     if (search.isNotEmpty) {
                //       return discountGroupController.groups
                //           .where(
                //             (group) => group.groupName
                //             .toString()
                //             .toLowerCase()
                //             .contains(search.toString().toLowerCase()),
                //       )
                //           .toList();
                //     } else {
                //       return discountGroupController.groups;
                //     }
                //     return null;
                //   },
                //   builder: (context, controller, focusNode) =>
                //       GlobalTextFormField(
                //         focusNode: focusNode,
                //         controller: discountGroupController.discountGroupNameController,
                //         label: 'Select group',
                //           validator: (value) {
                //             if (value == null || value.isEmpty) {
                //               return 'Group is required';
                //             } else if (!discountGroupController.groups.any((group) =>
                //             group.groupName.toLowerCase() == value.toLowerCase())) {
                //               return 'Please select a valid group from the list';
                //             } else {
                //               return null;
                //             }
                //           },
                //       ),
                // ),
                SizedBox(height: 35),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GlobalAppSubmitBtn(
                      isLoading: discountGroupController.isLoading.value,
                      height: 55,
                      title: 'Assign',
                      onTap: () async {
                        if (_formkey.currentState!.validate()) {
                          await discountGroupController.assignGroup();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
