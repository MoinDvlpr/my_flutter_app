import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/appbar_with_cart.dart';
import '../../../widgets/confirm_dialog.dart';
import '../myorders/my_orders_screen.dart';
import 'change_password.dart';
import 'shipping_address_screen.dart';
import 'update_profile.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({super.key});
  final AuthController authController = Get.put(AuthController());
  final UserController userController = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: appBarWithCart(title: "My profile", onTap: () {}),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          GestureDetector(
            onTap: () async {
              userController.clearControllers();
              await userController.fetchUserForEdit();
              Get.to(() => UpdateProfileScreen());
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${userController.userName}",
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${userController.userEmail}",
                        style: AppTextStyle.lableStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTile(
            'My orders',
            onTap: () {
              Get.to(() => MyOrdersScreen());
            },
          ),
          _buildTile(
            'Shipping addresses',
            onTap: () async {
              Get.to(() => ShippingAddressesScreen());
              await authController.fetchAllAddress();
            },
          ),
          _buildTile(
            'Change password',
            onTap: () {
              userController.clearControllers();
              Get.to(() => ChangePasswordScreen());
            },
          ),
          _buildTile(
            'Logout',
            onTap: () {
              showDeleteConfirmationDialog(
                confirmLabel: 'Logout',
                title: 'Logout',
                message: 'Are you sure ?',
                onConfirm: () async {
                  await authController.logout();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile(String title, {void Function()? onTap}) {
    return ListTile(
      title: Text(title, style: AppTextStyle.semiBoldTextstyle),

      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      onTap: onTap,
    );
  }
}
