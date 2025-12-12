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
import 'user_orders_screen.dart';

class UserInfoScreen extends StatelessWidget {
  final UserModel user;
  final int index;
  UserInfoScreen({super.key, required this.user, required this.index});

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
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Align(
                              alignment: Alignment
                                  .centerLeft, // Vertically center the text
                              child: Text(
                                'Status',
                                style: AppTextStyle.lableStyle,
                              ),
                            ),
                          ),

                          Transform.scale(
                            scale: 0.7,
                            child: Switch(
                              padding: EdgeInsets.zero,
                              trackColor: WidgetStatePropertyAll(
                                userController.isUserActive[user.userId!] ??
                                        user.isActive
                                    ? Colors.green
                                    : primary,
                              ),
                              inactiveThumbColor: white,
                              value:
                                  userController.isUserActive[user.userId!] ??
                                  user.isActive,
                              thumbIcon: WidgetStatePropertyAll(
                                userController.isUserActive[user.userId!] ??
                                        user.isActive
                                    ? Icon(Icons.check, color: Colors.green)
                                    : Icon(Icons.close, color: primary),
                              ),
                              onChanged: (bool val) {
                                userController.activeInactiveHandle(
                                  id: user.userId!,
                                  index: index,
                                  isActive: val,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Discount Group Assignment
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
            const SizedBox(height: 24),

            // Purchase History Section
            Text(
              'Purchase History',
              style: AppTextStyle.boldTextstyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Stats Cards
            Obx(() {
              if (userController.isLoadingStats.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: primary),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _statsCard(
                          'Total Revenue',
                          '₹${userController.totalRevenue.value.toStringAsFixed(2)}',
                          Icons.currency_rupee,
                          Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => _statsCard(
                          'Discount Gained',
                          '₹${userController.totalDiscount.value.toStringAsFixed(2)}',
                          Icons.discount,
                          Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    userController.userID = user.userId!;
                    Get.to(() => UserOrdersScreen(user: user));
                  },
                  child: Obx(
                    () => _statsCard(
                      'Total Orders',
                      '${userController.totalOrders.value}',
                      Icons.shopping_bag,
                      Colors.blue,
                      isFullWidth: true,
                    ),
                  ),
                ),
              ],
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

  Widget _statsCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (isFullWidth) const Spacer(),
              if (isFullWidth)
                Icon(Icons.arrow_forward_ios, size: 16, color: grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyle.lableStyle.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18)),
        ],
      ),
    );
  }
}
