import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../screens/customer/cart/my_cart_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_textstyles.dart';

PreferredSizeWidget appBarWithCart({
  void Function()? onTap,
  required String title,

}) {
  final CartController cartController = Get.put(CartController());
  final AuthController authController = Get.put(AuthController());
  return AppBar(
    title: Text(title),
    elevation: 0,

    actions: [
      Obx(
        () => Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () async {
                Get.to(() => MyCartScreen());
                await authController.fetchDefaultAddress();
              },
              icon: Icon(Icons.shopping_cart_outlined, color: grey),
            ),
            Visibility(
              visible: cartController.cartItems.isNotEmpty,
              child: Positioned(
                right: 4,
                top: 4,
                child: CircleAvatar(
                  backgroundColor: primary,
                  radius: 8,
                  child: Text(
                    cartController.cartItems.length.toString(),
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      color: white,
                      fontSize: 10, // reduced font size to fit in small badge
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
