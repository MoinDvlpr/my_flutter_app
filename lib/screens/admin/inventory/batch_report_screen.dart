import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/inventory_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';

class ProductReportScreen extends StatelessWidget {
  final String productId;
  final String productName;
  final int totalSold;

  ProductReportScreen({
    super.key,
    required this.productId,
    required this.productName,
    required this.totalSold,
  });

  // inventory controller for showing report with reactive variables
  final controller = Get.find<InventoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Product Report"),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Product ID: $productId",
                    style: AppTextStyle.lableStyle.copyWith(
                      fontSize: 14,
                      color: grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Key Metrics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    label: "Total Sold",
                    value: "$totalSold Units",
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => _buildMetricCard(
                      label: "Total Revenue",
                      value:
                          "₹${controller.totalRevenue.value.toStringAsFixed(2)}",
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _buildMetricCard(
                      label: "Total Remaining",
                      value: "${controller.totalRemaining.value}",
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => _buildMetricCard(
                      label: "Total Cost",
                      value:
                          "₹${controller.totalCost.value.abs().toStringAsFixed(2)}",
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Batches List Header
            Text(
              "Batches",
              style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 16),
            ),

            const SizedBox(height: 12),

            /// Batches List
            Obx(
              () => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.reportItems.length,
                itemBuilder: (context, index) {
                  final batch = controller.reportItems[index];
                  final batchSoldQuantity = batch.soldQty;
                  final batchProfit =
                      ((batch.sellingPrice ?? 0) - batch.costPrice) *
                      batchSoldQuantity;
                  return _buildBatchCard(
                    batchId: batch.batchId ?? 'initial',
                    remainingQuantity: batch.remaining,
                    soldQuantity: batchSoldQuantity,
                    soldAt: batch.sellingPrice ?? 0.0,

                    profit: batchProfit,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyle.lableStyle.copyWith(fontSize: 12, color: grey),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyle.semiBoldTextstyle.copyWith(
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard({
    required String batchId,
    required int remainingQuantity,
    required int soldQuantity,
    required double soldAt,
    required double profit,
  }) {
    // Calculate profit margin percentage safely
    final profitMargin = soldAt > 0
        ? (profit / (soldAt * soldQuantity)) * 100
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top Row (Batch ID + Profit Badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Batch ID: $batchId",
                style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: profit >= 0
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profit >= 0
                      ? "₹${profit.toStringAsFixed(2)}"
                      : "-₹${profit.abs().toStringAsFixed(2)}",
                  style: AppTextStyle.semiBoldTextstyle.copyWith(
                    fontSize: 12,
                    color: profit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Info Columns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Remaining", "$remainingQuantity units"),
              _buildInfoColumn("Sold", "$soldQuantity units"),
              _buildInfoColumn(
                "Profit Margin",
                "${profitMargin.isNaN ? 0 : profitMargin.toStringAsFixed(2)}%",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.lableStyle.copyWith(fontSize: 12, color: grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
