import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../model/address_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../auth/address_screen.dart';

class ShippingAddressesScreen extends StatelessWidget {
  ShippingAddressesScreen({super.key});
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Shipping Addresses'),
        leading: const BackButton(),
        elevation: 0,
      ),
      body: Obx(
        () => authController.allAddress.isEmpty
            ? Center(
                child: Text(
                  'No address found !',
                  style: AppTextStyle.lableStyle,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: authController.allAddress.length,
                itemBuilder: (context, index) {
                  final address = authController.allAddress[index];
                  return _buildAddressCard(address);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          authController.clearController();
          Get.to(() => AddressScreen());
        },
        shape: CircleBorder(),
        backgroundColor: primary,
        child: const Icon(Icons.add, color: white),
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  address.fullName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Get.to(() => AddressScreen(addressID: address.addressId));
                  await authController.fetchAddressByID(address.addressId!);
                },
                child: Text(
                  'Edit',
                  style: AppTextStyle.regularTextstyle.copyWith(color: primary),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await authController.removeAddress(
                    address.addressId!,
                    address.isDefault,
                  );
                },
                child: Text(
                  'Remove',
                  style: AppTextStyle.regularTextstyle.copyWith(color: primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Text(address.address),

          Text("${address.city}, ${address.state} ${address.zipcode},"),

          Text(address.country),

          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: address.isDefault,
                onChanged: (val) async {
                  await authController.setAsDefault(address.addressId!);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text("Use as the shipping address"),
            ],
          ),
        ],
      ),
    );
  }
}
