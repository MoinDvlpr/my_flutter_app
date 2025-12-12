import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/inventory_controller.dart';
import '../../../model/batch_report_item_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';

class BatchReportScreen extends StatelessWidget {
  final String batchId;
  final int inventoryId;
  final String productName;

  BatchReportScreen({
    super.key,
    required this.batchId,
    required this.productName,
    required this.inventoryId,
  });

  final controller = Get.find<InventoryController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Batch Report"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(
        () => controller.isReportLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                            "Batch ID: $batchId",
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
                            label: "Total Items",
                            value: "${controller.totalProducts.value}",
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            label: "Sold Items",
                            value: "${controller.soldProducts.value}",
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            label: "Remaining",
                            value: "${controller.remainingProducts.value}",
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            label: "Revenue",
                            value:
                                "₹${controller.totalBatchRevenue.value.toStringAsFixed(2)}",
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            label: "Total Cost",
                            value:
                                "₹${controller.totalBatchCost.value.toStringAsFixed(2)}",
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            label: "Profit",
                            value:
                                "₹${controller.totalProfit.value.toStringAsFixed(2)}",
                            color: controller.totalProfit.value >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// Filter Tabs
                    Row(
                      children: [
                        Text(
                          "Products",
                          style: AppTextStyle.semiBoldTextstyle.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        _buildFilterChip(
                          "All (${controller.totalProducts.value})",
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          "Sold (${controller.soldProducts.value})",
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          "Available (${controller.remainingProducts.value})",
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// Products List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = controller.filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ],
                ),
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

  Widget _buildFilterChip(String label) {
    return GestureDetector(
      onTap: () {
        controller.filterProducts(label.split(' ').first);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: controller.selectedFilter.value == label.split(' ').first
              ? primary
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: controller.selectedFilter.value == label.split(' ').first
                ? primary
                : grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyle.lableStyle.copyWith(
            fontSize: 12,
            color: controller.selectedFilter.value == label.split(' ').first
                ? Colors.white
                : grey,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BatchProductItem product) {
    final profit = product.isSold
        ? (product.actualSoldPrice ?? product.soldAt) - product.costPrice
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: product.isSold
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
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
          /// Top Row (Serial + Status Badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "S/N: ${product.serialNumber}",
                  style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: product.isSold
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.isSold ? "SOLD" : "AVAILABLE",
                  style: AppTextStyle.semiBoldTextstyle.copyWith(
                    fontSize: 11,
                    color: product.isSold ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn(
                  "Cost Price",
                  "₹${product.costPrice.toStringAsFixed(2)}",
                ),
              ),
              Expanded(
                child: _buildInfoColumn(
                  product.isSold ? "Sold At" : "Selling Price",
                  "₹${(product.isSold ? (product.actualSoldPrice ?? product.soldAt) : product.soldAt).toStringAsFixed(2)}",
                ),
              ),
              if (product.isSold)
                Expanded(
                  child: _buildInfoColumn(
                    "Profit",
                    profit >= 0
                        ? "₹${profit.toStringAsFixed(2)}"
                        : "-₹${profit.abs().toStringAsFixed(2)}",
                    color: profit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
            ],
          ),

          if (product.isSold && product.soldDate != null) ...[
            const SizedBox(height: 8),
            Text(
              "Sold on: ${_formatDate(product.soldDate!)}",
              style: AppTextStyle.lableStyle.copyWith(
                fontSize: 11,
                color: grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.lableStyle.copyWith(fontSize: 11, color: grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyle.semiBoldTextstyle.copyWith(
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
