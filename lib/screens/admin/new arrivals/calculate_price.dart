import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/inventory_controller.dart';
import '../../../model/inventory_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../inventory/inventory_screen.dart';

class CalculatePrice extends StatelessWidget {
  CalculatePrice({super.key, required this.inv, this.isFromInventory = false});
  final controller = Get.find<InventoryController>();
  final InventoryModel inv;
  final bool isFromInventory;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Always prevent default pop
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Show dialog if selling price isn't set
          if (controller.newSellingPrice.value == null) {
            showConfirmDialog(
              message:
                  "Selling price isn't set yet\n"
                  "Are you sure you want to continue?",
              title: "Proceed Without Selling Price?",
              onConfirm: () {
                controller.pagingController.refresh();
                controller.pagingControllerForAllProducts.refresh();
                controller.pagingControllerForSoldOuts.refresh();
                Get.back(result: true);
                if (isFromInventory) {
                  Get.back(result: true);
                } else {
                  Get.off(() => InventoryScreen());
                }
              },
            );
          } else {
            // If price is set, just go back normally
            controller.pagingController.refresh();
            controller.pagingControllerForAllProducts.refresh();
            controller.pagingControllerForSoldOuts.refresh();
            Get.back(result: true);
            if (!isFromInventory) {
              Get.off(() => InventoryScreen());
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: Text("Adjust Pricing")),
        body: Obx(() {
          // Show loading indicator while calculating WAC
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primary),
                  const SizedBox(height: 16),
                  Text(
                    "Calculating pricing...",
                    style: AppTextStyle.lableStyle.copyWith(
                      fontSize: 14,
                      color: grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Product Info Section with WAC
                _buildProductInfoCard(controller),

                const SizedBox(height: 24),

                _buildProfitMarginSection(controller),
                const SizedBox(height: 20),

                /// Price Input Section
                _buildPriceInputSection(controller),

                const SizedBox(height: 20),

                /// Price Status (Reactive)
                Obx(() {
                  if (!controller.showPriceStatus.value)
                    return const SizedBox();
                  return FadeTransition(
                    opacity: controller.fadeAnimation,
                    child: _buildPriceStatusContainer(controller),
                  );
                }),

                const SizedBox(height: 24),

                /// Update Button
                Obx(
                  () => Visibility(
                    visible: controller.newSellingPrice.value != null,
                    child: SizedBox(
                      width: double.infinity,
                      child: GlobalAppSubmitBtn(
                        onTap: () {
                          showConfirmDialog(
                            message:
                                isFromInventory &&
                                    controller.productInventoryBatches.length >
                                        1
                                ? 'This will update the selling price for ${controller.productInventoryBatches.length} batch(es) of this product. Proceed?'
                                : 'Are you sure you want to proceed with this price?',
                            onConfirm: () async {
                              await controller.updatePrice(
                                inv,
                                isFromInventory: isFromInventory,
                              );
                            },
                            title: "Confirm Selling Price?",
                          );
                        },
                        title: "Proceed",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfitMarginSection(InventoryController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primary.withValues(alpha: 0.2),
                radius: 18,
                child: Icon(Icons.percent, color: primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profit Margin',
                      style: AppTextStyle.semiBoldTextstyle.copyWith(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Set your desired profit percentage',
                      style: AppTextStyle.lableStyle.copyWith(
                        fontSize: 12,
                        color: grey,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${c.profitMargin.value.toStringAsFixed(0)}%',
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 16,
                      color: primary,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 18),
          Obx(() {
            return Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape: RoundSliderThumbShape(
                      elevation: 4,
                      enabledThumbRadius: 12,
                      disabledThumbRadius: 10,
                    ),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                    activeTrackColor: primary,
                    inactiveTrackColor: primary.withValues(alpha: 0.2),
                    thumbColor: primary,
                    overlayColor: primary.withValues(alpha: 0.2),
                    valueIndicatorColor: primary,
                    valueIndicatorStrokeColor: primary,
                    valueIndicatorTextStyle: AppTextStyle.semiBoldTextstyle
                        .copyWith(color: Colors.white, fontSize: 14),
                  ),
                  child: Slider(
                    value: c.profitMargin.value,
                    min: 0,
                    max: c.maxProfit.value,
                    divisions: 100,
                    label: '${c.profitMargin.value.toStringAsFixed(0)}%',
                    onChanged: (value) {
                      c.onSliderChanged(value);
                    },
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard(InventoryController c) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primary.withValues(alpha: 0.2),
                  radius: 20,
                  child: Icon(Icons.shopping_bag, color: primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.productName.value,
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isFromInventory && c.productInventoryBatches.length > 1
                            ? "${c.productInventoryBatches.length} batches"
                            : "Batch: ${inv.productBatch}",
                        style: AppTextStyle.lableStyle.copyWith(
                          fontSize: 13,
                          color: grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildPriceRow("Cost Price", c.costPrice.value, Colors.blue),
            const SizedBox(height: 12),
            _buildPriceRow(
              "Current Selling Price",
              c.currentSellingPrice.value,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildPriceRow("Market Price", c.marketPrice.value, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double price,
    Color color, {
    bool showIcon = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (showIcon) ...[
              Icon(Icons.calculate, color: color, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyle.lableStyle.copyWith(
                fontSize: 14,
                color: grey,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "₹${price.toStringAsFixed(2)}",
            style: AppTextStyle.semiBoldTextstyle.copyWith(
              fontSize: 15,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInputSection(InventoryController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Set New Selling Price",
              style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 15),
            ),
            if (isFromInventory && c.weightedAverageCost.value > 0) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: "Price auto-calculated using weighted average cost",
                child: Icon(Icons.info_outline, size: 18, color: primary),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: c.priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: "₹ ",
            hintText: "Enter selling price",
            hintStyle: AppTextStyle.lableStyle.copyWith(color: grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
          style: AppTextStyle.lableStyle.copyWith(fontSize: 16),
          onChanged: (value) {
            c.calculatePrice();
          },
        ),
      ],
    );
  }

  Widget _buildPriceStatusContainer(InventoryController c) {
    return Obx(() {
      final color = c.statusColor.value ?? Colors.grey;
      final icon = c.statusIcon.value ?? Icons.info;
      final message = c.statusMessage.value ?? '';

      // Check if this is the special minimize-loss scenario
      final isMinimizeLossScenario =
          c.isAutoCalculatedPrice.value &&
          c.costPrice.value > c.marketPrice.value &&
          (c.newSellingPrice.value ?? 0) >= c.costPrice.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            if (isMinimizeLossScenario) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "This price helps reduce losses while staying competitive",
                        style: AppTextStyle.lableStyle.copyWith(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    "Final Selling Price",
                    "₹${c.newSellingPrice.value?.toStringAsFixed(2) ?? '--'}",
                    primary,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    "Profit Amount",
                    "₹${c.profitAmount.value?.toStringAsFixed(2) ?? '--'}",
                    (c.profitAmount.value ?? 0) < 0 ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    "Profit Margin",
                    "${c.profitPercent.value?.toStringAsFixed(2) ?? '--'}%",
                    (c.profitPercent.value ?? 0) < 0
                        ? Colors.red
                        : (c.profitPercent.value ?? 0) <= 20
                        ? Colors.orange
                        : Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.lableStyle.copyWith(fontSize: 13)),
        Text(
          value,
          style: AppTextStyle.semiBoldTextstyle.copyWith(
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  void showConfirmDialog({
    required String message,
    required String title,
    required void Function()? onConfirm,
  }) {
    Get.defaultDialog(
      title: '',
      radius: 16,
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 38,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.semiBoldTextstyle.copyWith(
              fontSize: 18,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.lableStyle.copyWith(fontSize: 14, color: grey),
          ),

          const SizedBox(height: 24),

          // Buttons row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Get.back(result: false),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: onConfirm,
                  child: const Text(
                    "Proceed",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
