import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/inventory_controller.dart';
import '../../../model/inventory_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';

class CalculatePrice extends StatelessWidget {
  CalculatePrice({super.key,required this.inventory});
  final controller = Get.find<InventoryController>();
  final InventoryModel inventory;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          "Adjust Pricing",
          style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 18),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Info Section
            _buildProductInfoCard(controller),

            const SizedBox(height: 24),

            /// Price Input Section
            _buildPriceInputSection(controller),

            const SizedBox(height: 20),

            /// Price Status (Reactive)
            Obx(() {
              if (!controller.showPriceStatus.value) return const SizedBox();
              return FadeTransition(
                opacity: controller.fadeAnimation,
                child: _buildPriceStatusContainer(controller),
              );
            }),

            const SizedBox(height: 24),

            /// Update Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.updatePrice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Update Price",
                  style: AppTextStyle.semiBoldTextstyle.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard(InventoryController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primary.withOpacity(0.2),
                radius: 20,
                child: Icon(Icons.shopping_bag, color: primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.productName.value,
                        style: AppTextStyle.semiBoldTextstyle
                            .copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text("Batch: ${c.batchId.value}",
                        style: AppTextStyle.lableStyle
                            .copyWith(fontSize: 13, color: grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceRow("Cost Price", c.costPrice.value, Colors.blue),
          const SizedBox(height: 12),
          _buildPriceRow(
              "Current Selling Price", c.currentSellingPrice.value, Colors.orange),
          const SizedBox(height: 12),
          _buildPriceRow("Market Price", c.marketPrice.value, Colors.green),
        ],
      )),
    );
  }

  Widget _buildPriceRow(String label, double price, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyle.lableStyle.copyWith(fontSize: 14, color: grey)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "₹${price.toStringAsFixed(2)}",
            style: AppTextStyle.semiBoldTextstyle
                .copyWith(fontSize: 15, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceInputSection(InventoryController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Set New Selling Price",
            style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        TextField(
          controller: c.priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: "₹ ",
            hintText: "Enter selling price",
            hintStyle: AppTextStyle.lableStyle.copyWith(color: grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: grey.withOpacity(0.3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: primary, width: 2),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          style: AppTextStyle.lableStyle.copyWith(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildPriceStatusContainer(InventoryController c) {
    return Obx(() {
      final color = c.statusColor.value ?? Colors.grey;
      final icon = c.statusIcon.value ?? Icons.info;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(c.statusMessage.value ?? '',
                    style: AppTextStyle.semiBoldTextstyle
                        .copyWith(fontSize: 14, color: color)),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(children: [
                _buildInfoRow(
                    "Final Selling Price",
                    "₹${c.newSellingPrice.value?.toStringAsFixed(2) ?? '--'}",
                    primary),
                const SizedBox(height: 10),
                _buildInfoRow(
                    "Profit Amount",
                    "₹${c.profitAmount.value?.toStringAsFixed(2) ?? '--'}",
                    (c.profitAmount.value ?? 0) < 0
                        ? Colors.red
                        : Colors.green),
                const SizedBox(height: 10),
                _buildInfoRow(
                    "Profit Margin",
                    "${c.profitPercent.value?.toStringAsFixed(2) ?? '--'}%",
                    (c.profitPercent.value ?? 0) < 0
                        ? Colors.red
                        : (c.profitPercent.value ?? 0) <= 20
                        ? Colors.orange
                        : Colors.green),
              ]),
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
        Text(value,
            style: AppTextStyle.semiBoldTextstyle
                .copyWith(fontSize: 16, color: color)),
      ],
    );
  }
}
