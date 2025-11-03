import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/purchase_order_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../../../widgets/price_calc_widget.dart';

class AllInventoryItems extends StatelessWidget {
  AllInventoryItems({super.key, required this.poID});
  final int poID;
  final poController = Get.find<PurchaseOrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("PO #$poID"),
        elevation: 0,
        actions: [
          Obx(() {
            final isSelect = poController.isSelectMode.value;
            final isAll = poController.isSelectAll.value;
            return Visibility(
              visible: isSelect,
              child: TextButton(
                onPressed: () {
                  poController.isSelectAll.value =
                  !poController.isSelectAll.value;

                  if (poController.isSelectAll.value) {
                    // Select all
                    poController.selectedItems.assignAll(
                      List.generate(
                        poController.poItems.length,
                            (index) => index,
                      ),
                    );
                  } else {
                    // Clear all
                    poController.selectedItems.clear();
                  }
                },

                child: Text(
                  isAll ? "Clear all" : "Select all",
                  style: AppTextStyle.semiBoldTextstyle.copyWith(
                    color: primary,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),
          Obx(() {
            final isSelect = poController.isSelectMode.value;
            return Visibility(
              visible: poController.poItems.isNotEmpty,
              child: TextButton(
                onPressed: () {
                  poController.isSelectMode.toggle();
                  if (!poController.isSelectMode.value) {
                    // Clear all selections when exiting select mode
                    poController.isSelectAll.value = false;
                    poController.selectedItems.clear();
                  }
                },
                child: Text(
                  isSelect ? "Cancel" : "Select",
                  style: AppTextStyle.semiBoldTextstyle.copyWith(
                    color: primary,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }),

          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await poController.fetchAllPOItemsByPOID(poID);
            },
            child: Icon(Icons.qr_code_scanner, color: primary),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          //   child: SearchBar(
          //     onTapOutside: (event) {
          //       FocusManager.instance.primaryFocus?.unfocus();
          //     },
          //     backgroundColor: WidgetStatePropertyAll(bg),
          //     hintText: 'Search by name, code or part #',
          //     onChanged: (value) async {
          //       // Add search filter logic if needed
          //     },
          //     hintStyle: WidgetStatePropertyAll(AppTextStyle.lableStyle),
          //     elevation: const WidgetStatePropertyAll(0.0),
          //     side: WidgetStatePropertyAll(BorderSide(width: 1, color: grey)),
          //   ),
          // ),
          //
          // const SizedBox(height: 10),

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
                    title: item.itemName ?? 'Undefined',
                    srNumber: item.srNo ?? 'undefined',
                    costPrice: item.costPerUnit,
                    marketPrice: item.marketPrice ?? 0.0,
                    confirmSellingPriceController:
                    poController.confirmPriceController[index],
                    index: index,
                  );
                },
              );
            }),
          ),

          // Submit Button
          Obx(
                () => Visibility(
              visible: poController.selectedItems.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18, left: 28, right: 28),
                child: GlobalAppSubmitBtn(
                  isLoading: poController.isLoading.value,
                  title:
                  "Proceed with ${poController.selectedItems.length} items",
                  onTap: () {
                    // Handle Save or Submit logic here
                    poController.saveToDB(
                      purchaseOrderId: poID,
                      isAll: poController.isSelectAll.value,
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
        required TextEditingController confirmSellingPriceController,
        required int index,
      }) {
    final poController = Get.find<PurchaseOrderController>();

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
      child: Stack(
        children: [
          /// Checkbox positioned at top-left corner (visible only in select mode)
          Obx(
                () => !(poController.isSelectMode.value)
                ? const SizedBox.shrink()
                : Positioned(
              top: 8,
              left: 8,
              child: Checkbox(
                activeColor: primary,
                value: poController.selectedItems.contains(index),
                onChanged: (value) {
                  if (value == true) {
                    poController.selectedItems.add(index);
                  } else {
                    poController.isSelectAll.value = false;
                    poController.selectedItems.remove(index);
                  }
                },
              ),
            ),
          ),

          /// Main content
          Obx(
                () => Padding(
              padding: EdgeInsets.fromLTRB(
                poController.isSelectMode.value ? 50 : 16,
                14,
                16,
                14,
              ), // ← left padding increased for checkbox space
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

                  const SizedBox(height: 12),

                  /// Cost & Market Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cost Price: ₹${costPrice.toStringAsFixed(2)}",
                        style: AppTextStyle.regularTextstyle.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Market Price: ₹${marketPrice.toStringAsFixed(2)}",
                        style: AppTextStyle.regularTextstyle.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// Selling Price Field
                  Obx(() {
                    final isManual = poController.isManualPrice[index] ?? false;
                    return TextFormField(
                      controller: confirmSellingPriceController,
                      enabled: isManual,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.currency_rupee),
                        hintText: "Selling Price",
                        hintStyle: AppTextStyle.lableStyle,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isManual ? Icons.lock_open : Icons.lock,
                            color: isManual ? Colors.green : Colors.grey,
                          ),
                          onPressed: () =>
                              poController.toggleManualPrice(index),
                        ),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) =>
                          poController.checkConfirmPrice(index),
                    );
                  }),

                  /// Pricing Calc
                  Obx(() {
                    final isCalcVisible =
                        poController.isCalcVisible[index] ?? false;
                    return AnimatedCrossFade(
                      firstChild: PricingCalculatorWidget(
                        controller: poController,
                        index: index,
                      ),
                      secondChild: const SizedBox.shrink(),
                      crossFadeState: isCalcVisible
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 250),
                    );
                  }),

                  /// Pricing Status Card
                  Obx(() {
                    if ((poController.pricingStatus[index] ?? '').isEmpty) {
                      return const SizedBox.shrink();
                    }
                    Color statusColor;
                    IconData statusIcon;

                    switch (poController.pricingStatus[index]) {
                      case 'error':
                        statusColor = primary;
                        statusIcon = Icons.error;
                        break;
                      case 'warning':
                        statusColor = Colors.orange;
                        statusIcon = Icons.warning;
                        break;
                      case 'success':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusIcon = Icons.info;
                    }

                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, color: statusColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              poController.pricingMessage[index] ?? '',
                              style: AppTextStyle.regularTextstyle.copyWith(
                                color: statusColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 10),

                  /// Action Buttons (Calc / Manual)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            poController.toggleCalcVisibility(index),
                        icon: Icon(
                          poController.isCalcVisible[index] ?? false
                              ? Icons.expand_less
                              : Icons.calculate,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          poController.isCalcVisible[index] ?? false
                              ? "Close Calc"
                              : "Show Calc",
                          style: AppTextStyle.regularTextstyle.copyWith(
                            color: Colors.redAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton.icon(
                        onPressed: () => poController.toggleManualPrice(index),
                        icon: const Icon(Icons.edit, color: primary),
                        label: Text(
                          "Enter Manually",
                          style: AppTextStyle.regularTextstyle.copyWith(
                            color: primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
