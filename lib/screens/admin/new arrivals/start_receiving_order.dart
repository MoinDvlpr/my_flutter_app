import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/inventory_controller.dart';
import '../../../controllers/purchase_order_controller.dart';
import '../../../model/purchase_order_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/appsubmitbtn.dart';
import 'calculate_price.dart';

class StartReceivingOrder extends StatelessWidget {
  StartReceivingOrder({super.key, required this.po});
  final PurchaseOrderModel po;
  final poController = Get.find<PurchaseOrderController>();
  final inventoryController = Get.find<InventoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("PO #${po.id}"),
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () async {
              await poController.assignSR(po);
            },
            child: Icon(Icons.qr_code_scanner, color: primary),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [

          // List of PO Items
          Expanded(
            child: Obx(() {
              final items = poController.poItems;
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 48, color: grey),
                      SizedBox(height: 10),
                      Text(
                        "Scan qr code to add items",
                        style: AppTextStyle.lableStyle.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildItemCard(
                    context,
                    title: item.productName ?? 'Undefined',
                    srNumber: item.serialNumber ?? 'undefined',
                    costPrice: item.costPerUnit ?? 0.0,
                    marketPrice: item.marketPrice ?? 0.0,
                    index: index,
                  );
                },
              );
            }),
          ),

          // Submit Button
          Obx(
            () => Visibility(
              visible: poController.poItems.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18, left: 28, right: 28),
                child: GlobalAppSubmitBtn(
                  isLoading: poController.isLoading.value,
                  title:
                      "Continue",
                  onTap: () {
                    // Handle Save or Submit logic here
                    poController.saveToDB(
                      po: po,
                    );
                  },
                ),
              ),

            ),
          ),

        ],
      ),
    );
  }

  Widget _buildItemCard(
      BuildContext context, {
        required String title,
        required String srNumber,
        required double costPrice,
        required double marketPrice,
        required int index,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Item Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  radius: 18,
                  child: const Icon(
                    Icons.inventory_2,
                    color: primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              srNumber,
              style: AppTextStyle.lableStyle.copyWith(fontSize: 14),
            ),

            const SizedBox(height: 16),

            /// Highlighted Cost Price
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                "Cost Price: ₹${costPrice.toStringAsFixed(2)}",
                style: AppTextStyle.semiBoldTextstyle.copyWith(
                  fontSize: 15,
                  color: Colors.blue.shade700,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// Highlighted Market Price
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Text(
                "Market Price: ₹${marketPrice.toStringAsFixed(2)}",
                style: AppTextStyle.semiBoldTextstyle.copyWith(
                  fontSize: 15,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
