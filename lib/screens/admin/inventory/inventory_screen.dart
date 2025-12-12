import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../controllers/inventory_controller.dart';
import '../../../model/inventory_model.dart';
import '../../../model/product_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../new arrivals/calculate_price.dart';
import 'product_report_screen.dart';

class InventoryScreen extends StatelessWidget {
  InventoryScreen({super.key});

  final inventoryController = Get.find<InventoryController>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: const Text("Inventory"),
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: primary,
            labelColor: primary,
            unselectedLabelColor: grey,
            tabs: [
              Tab(
                child: Text(
                  "All Inventory",
                  style: AppTextStyle.regularTextstyle.copyWith(fontSize: 16),
                ),
              ),
              Tab(
                child: Text(
                  "All Products",
                  style: AppTextStyle.regularTextstyle.copyWith(fontSize: 16),
                ),
              ),

              Tab(
                child: Text(
                  "Out of stoke",
                  style: AppTextStyle.regularTextstyle.copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: All Products
            _buildBatchList(inventoryController.pagingController),
            // Tab 2: In Sale Products
            _buildProductList(
              inventoryController.pagingControllerForAllProducts,
            ),

            // Tab 3: Sold out Products
            _buildProductList(inventoryController.pagingControllerForSoldOuts),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchList(
    PagingController<int, InventoryModel> pagingController,
  ) {
    return PagingListener<int, InventoryModel>(
      controller: pagingController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, InventoryModel>(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) {
                return _buildProductBatchCard(
                  context,
                  item: item,
                  showSoldOut: item.remaining <= 0,
                  index: index,
                );
              },
              firstPageErrorIndicatorBuilder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: grey),
                    const SizedBox(height: 10),
                    Text(
                      "Error loading products",
                      style: AppTextStyle.lableStyle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => pagingController.refresh(),
                      style: ElevatedButton.styleFrom(backgroundColor: primary),
                      child: const Text(
                        "Retry",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              noItemsFoundIndicatorBuilder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2, size: 48, color: grey),
                    const SizedBox(height: 10),
                    Text(
                      "No products available",
                      style: AppTextStyle.lableStyle.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              newPageProgressIndicatorBuilder: (context) => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(color: primary)),
              ),
              firstPageProgressIndicatorBuilder: (context) => const Center(
                child: CircularProgressIndicator(color: primary),
              ),
            ),
          ),
    );
  }

  Widget _buildProductBatchCard(
    BuildContext context, {
    required InventoryModel item,
    required bool showSoldOut,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header: Product Name with Batch ID and Quantity
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName ?? "Unknown Product",
                            style: AppTextStyle.semiBoldTextstyle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Batch ID: ${item.productBatch}",
                            style: AppTextStyle.lableStyle.copyWith(
                              fontSize: 13,
                              color: grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Qty: ${item.remaining}",
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          fontSize: 14,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Second Row: Cost and Market Headings
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Cost",
                        style: AppTextStyle.lableStyle.copyWith(
                          fontSize: 13,
                          color: grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Market",
                        style: AppTextStyle.lableStyle.copyWith(
                          fontSize: 13,
                          color: grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// Third Row: Cost Price and Market Price Values
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          "₹${item.costPerUnit.toStringAsFixed(2)}",
                          style: AppTextStyle.semiBoldTextstyle.copyWith(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          "₹${item.marketPrice?.toStringAsFixed(2)}",
                          style: AppTextStyle.semiBoldTextstyle.copyWith(
                            fontSize: 14,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Fourth Row: Current Selling Rate (Highlighted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Current Selling Rate",
                            style: AppTextStyle.lableStyle.copyWith(
                              fontSize: 12,
                              color: Colors.orange.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${(item.sellingPrice ?? 0.0).toStringAsFixed(2)}",
                            style: AppTextStyle.semiBoldTextstyle.copyWith(
                              fontSize: 16,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),

                      showSoldOut
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Sold Out",
                                style: AppTextStyle.semiBoldTextstyle.copyWith(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                inventoryController.reset();
                                inventoryController.setData(
                                  inventory: item,
                                  isFromInventory: true,
                                );
                                Get.to(
                                  () => CalculatePrice(
                                    inv: item,
                                    isFromInventory: true,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade600,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.sellingPrice == null
                                      ? "Calculate"
                                      : "Modify",
                                  style: AppTextStyle.semiBoldTextstyle
                                      .copyWith(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Rotated Badge on left side
          if (item.remaining > 0 && item.isReadyForSale)
            Positioned(
              left: -40,
              top: 10,
              child: Transform.rotate(
                angle: -0.7854, // 45 degrees in radians
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "IN SALE",
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 11,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            )
          else if (showSoldOut)
            Positioned(
              left: -40,
              top: 10,
              child: Transform.rotate(
                angle: -0.7854, // 45 degrees in radians
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "SOLD",
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 11,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductList(
    PagingController<int, ProductModel> pagingController,
  ) {
    return PagingListener<int, ProductModel>(
      controller: pagingController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, ProductModel>(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) {
                return _buildProductCard(context, item: item, index: index);
              },
              firstPageErrorIndicatorBuilder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: grey),
                    const SizedBox(height: 10),
                    Text(
                      "Error loading products",
                      style: AppTextStyle.lableStyle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => pagingController.refresh(),
                      style: ElevatedButton.styleFrom(backgroundColor: primary),
                      child: const Text(
                        "Retry",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              noItemsFoundIndicatorBuilder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2, size: 48, color: grey),
                    const SizedBox(height: 10),
                    Text(
                      "No products available",
                      style: AppTextStyle.lableStyle.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              newPageProgressIndicatorBuilder: (context) => const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(color: primary)),
              ),
              firstPageProgressIndicatorBuilder: (context) => const Center(
                child: CircularProgressIndicator(color: primary),
              ),
            ),
          ),
    );
  }

  Widget _buildProductCard(
    BuildContext context, {
    required ProductModel item,
    required int index,
  }) {
    List<File> images = [];
    if (item.productImage.isNotEmpty) {
      // On load from DB
      List<String> imagePaths = item.productImage.split(',');
      images = imagePaths.map((p) => File(p)).toList();
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header Row: Product Image, Name, ID, Quantity
                Row(
                  children: [
                    /// Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        images[0],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// Product Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: AppTextStyle.semiBoldTextstyle.copyWith(
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Product ID: ${item.productId ?? '-'}",
                            style: AppTextStyle.lableStyle.copyWith(
                              fontSize: 13,
                              color: grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Quantity Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Qty: ${item.stockQty}",
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          fontSize: 14,
                          color: primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// Pricing Section - Market Price & Selling Rate
                Row(
                  children: [
                    /// Market Price
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Market Price",
                              style: AppTextStyle.lableStyle.copyWith(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "₹${item.marketPrice.toStringAsFixed(2)}",
                              style: AppTextStyle.semiBoldTextstyle.copyWith(
                                fontSize: 16,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// Current Selling Rate
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selling Rate",
                              style: AppTextStyle.lableStyle.copyWith(
                                fontSize: 12,
                                color: Colors.orange.shade600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "₹${item.price.toStringAsFixed(2)}",
                              style: AppTextStyle.semiBoldTextstyle.copyWith(
                                fontSize: 16,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Report Button
                GestureDetector(
                  onTap: () async {
                    Get.to(
                      () => ProductReportScreen(
                        productId: item.productId.toString(),
                        productName: item.productName ?? "Unknown Product",
                        totalSold: item.soldQty,
                      ),

                    );
                    await inventoryController.fetchProductReport(
                      item.productId!,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.analytics_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "View Report",
                          style: AppTextStyle.semiBoldTextstyle.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Status Badge (IN SALE / SOLD)
          if (item.stockQty > 0)
            Positioned(
              left: -40,
              top: 10,
              child: Transform.rotate(
                angle: -0.7854, // 45 degrees
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "IN SALE",
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 11,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              left: -40,
              top: 10,
              child: Transform.rotate(
                angle: -0.7854,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "SOLD",
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 11,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
