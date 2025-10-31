import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/order_controller.dart';
import '../../../model/cart_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/app_snackbars.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../../auth/address_screen.dart';
import '../profile/shipping_address_screen.dart';

class MyCartScreen extends StatelessWidget {
  MyCartScreen({super.key});
  final CartController cartController = Get.put(CartController());
  final OrderController orderController = Get.put(OrderController());
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('My Cart')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Obx(
                  () => cartController.isLoading.value
                      ? Center(child: CircularProgressIndicator(color: primary))
                      : cartController.cartItems.isEmpty
                      ? Center(
                          child: Text(
                            "Cart is empty!",
                            style: AppTextStyle.lableStyle,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              cartController.cartItems.length +
                              1, // extra 1 for total summary
                          itemBuilder: (context, index) {
                            if (index < cartController.cartItems.length) {
                              final item = cartController.cartItems[index];
                              return _buildCartItem(context, item);
                            } else {
                              return Visibility(
                                visible: cartController.cartItems.isNotEmpty,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    _buildShippingAddressSection(),
                                    const SizedBox(height: 16),
                                    _buildOrderSummarySection(),
                                    const SizedBox(
                                      height: 80,
                                    ), // Space for the bottom button
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible:
                      cartController.cartItems.isNotEmpty &&
                      authController.shippingAddress.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlobalAppSubmitBtn(
                      height: 50,
                      title: 'Checkout',
                      isLoading: cartController.isPaymentLoading.value,
                      onTap: () async {
                        var isAvailable = await cartController.checkStock();
                        if (isAvailable) {
                          cartController.createOrderFromCart();
                        } else {
                          Get.closeAllSnackbars();
                          AppSnackbars.warning(
                            'Limited stock',
                            "Limited stock available",
                          );
                          print("value is false");
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItemModel item) {
    List<File> images = [];
    if (item.productImage.isNotEmpty) {
      // On load from DB
      List<String> imagePaths = item.productImage.split(',');
      images = imagePaths.map((p) => File(p)).toList();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.productImage.isEmpty
                ? Image.asset(
                    'assets/images/noimg.png',
                    height: 80,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : images[0].existsSync()
                ? Image.file(
                    images[0],
                    height: 80,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/noimg.png',
                    height: 80,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.semiBoldTextstyle,
                      ),
                    ),
                  ],
                ),

                Text(
                  "₹${item.discountedPrice.toStringAsFixed(0)}",
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: AppTextStyle.semiBoldTextstyle,
                ),

                SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await cartController.decreaseQty(
                            item.cartId,
                            cartController.cartItemQty[item.productId] ?? 1,
                            item.productId,
                            item.discountedPrice,
                          );
                        },
                        child: _buildQuantityButton(Icons.remove),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${cartController.cartItemQty[item.productId] ?? 1}",
                        style: AppTextStyle.regularTextstyle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () async {
                          await cartController.increaseQty(
                            productID: item.productId,

                            price: item.discountedPrice,
                          );
                        },
                        child: _buildQuantityButton(Icons.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await cartController.deleteFromCart(item.cartId);
            },
            child: Icon(Icons.delete_outline, color: primary),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressSection() {
    return Obx(
      () => authController.shippingAddress.isEmpty
          ? GestureDetector(
              onTap: () {
                Get.to(() => AddressScreen());
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(width: 1, color: primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "+ Add shipping address",
                        style: AppTextStyle.lableStyle,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping address',
                  style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    authController.fullName.value,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.boldTextstyle.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    authController.shippingAddress.value,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${authController.cityName.value}, ${authController.stateName.value},${authController.zipcode.value},',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Handle change address
                          Get.to(() => ShippingAddressesScreen());
                          await authController.fetchAllAddress();
                        },
                        child: Text(
                          'Change',
                          style: AppTextStyle.semiBoldTextstyle.copyWith(
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOrderSummarySection() {
    TextStyle normal = AppTextStyle.regularTextstyle.copyWith(fontSize: 15);
    TextStyle bold = AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 16);
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Order summary',
            style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order:', style: normal),
              Text(
                '₹${cartController.subTotal.value.toStringAsFixed(0)}',
                style: normal,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery:', style: normal),
              Text(
                '₹${cartController.deliveryCharge.value.toStringAsFixed(0)}',
                style: normal,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Summary:', style: bold),
              Text(
                '₹${cartController.total.value.toStringAsFixed(0)}',
                style: bold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18),
    );
  }
}
