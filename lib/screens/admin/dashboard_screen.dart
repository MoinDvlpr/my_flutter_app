import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_flutter_app/utils/app_constant.dart';
import 'package:my_flutter_app/utils/app_textstyles.dart';
import '../../controllers/dashboard_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/admin_drawer.dart';
import '../../widgets/order_summary_chart.dart';
import '../../widgets/reportchart.dart';
import 'order/orders_map_screen.dart';
import 'product/product_detail.dart';
import 'product/products.dart';
import 'user/users_screen.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});
  final dashboardController = Get.find<DashboardController>();
  @override
  Widget build(BuildContext context) {
    dashboardController.fetchDashboardData();
    GetStorage storage = GetStorage();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(),
      drawer: AdminDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Hello\n",
                        style: AppTextStyle.lableStyle.copyWith(fontSize: 22),
                      ),
                      TextSpan(
                        text: "${storage.read(USERNAME)} !",
                        style: AppTextStyle.boldTextstyle.copyWith(
                          color: black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailsCard(
                        icon: Icons.person_outline_rounded,
                        label: 'Customers',
                        count: dashboardController.totalUsers.value,
                        onTap: () {
                          Get.to(() => UsersScreen());
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildDetailsCard(
                        icon: Icons.store_mall_directory_outlined,
                        label: 'Products',
                        count: dashboardController.totalProducts.value,
                        onTap: () {
                          Get.to(() => ProductsScreen());
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  "Report",
                  style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                ),
                SizedBox(height: 10),
                // Date Range Picker
                Obx(() {
                  final format = DateFormat('dd MMM yyyy');
                  final dateRange =
                      "${format.format(dashboardController.startDate.value)} → ${format.format(dashboardController.endDate.value)}";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Selected Date Range",
                                style: AppTextStyle.lableStyle.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateRange,
                                style: AppTextStyle.semiBoldTextstyle.copyWith(
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              dashboardController.pickDateRange(context),
                          icon: const Icon(Icons.date_range, size: 18),
                          label: const Text("Change"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: bg,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: AppTextStyle.lableStyle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                // Profit-Loss Chart
                ProfitLossChart(),
                Text(
                  "Order Summary",
                  style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                ),
                OrderStatusChart(),
                Text(
                  'Customer Order Locations',
                  style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                ),
                SizedBox(height: 8.0),

                SizedBox(
                  height: 350, // Set desired height
                  width: double.infinity, // Full width or set a specific value

                  child: GoogleMap(
                    onTap: (argument) => Get.to(() => OrdersMapScreen()),
                    markers: dashboardController.markers,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(20.5937, 78.9629),
                      zoom: 5,
                    ),
                    mapType: MapType.normal,
                    myLocationEnabled: true, // Optional: Show user location
                    myLocationButtonEnabled: true, // Optional: Location button
                    onMapCreated: dashboardController.onMapCreated,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Most Selling Products",
                  style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                ),
                _itemList(
                  products: dashboardController.topProducts,
                  label: 'Sold',
                ),
                SizedBox(height: 20),
                Text(
                  "Top 5 Revenue Making Products",
                  style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                ),
                SizedBox(height: 10),
                _itemList(
                  products: dashboardController.topRevenueProducts,
                  label: 'Profit',
                  isLoss: false,
                ),

                SizedBox(height: 20),
                Text(
                  "Top 5 Loss Making Products",
                  style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                ),
                SizedBox(height: 10),
                _itemList(
                  products: dashboardController.topLossProducts,
                  label: 'Loss',
                  isLoss: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemList({
    required products,
    required String label,
    bool isLoss = false,
  }) {
    return SizedBox(
      height: 300,
      child: products.isEmpty
          ? Center(
              child: Text(
                'No data available',
                style: AppTextStyle.regularTextstyle.copyWith(color: grey),
              ),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                List<File> images = [];

                if (product.productImage.isNotEmpty) {
                  List<String> imagePaths = product.productImage.split(',');
                  images = imagePaths.map((p) => File(p)).toList();
                }

                // Determine what value to display based on label
                String displayValue = '';
                Color valueColor = grey;

                if (label == 'Revenue' || label == 'Profit') {
                  displayValue =
                      '₹${product.totalRevenue?.toStringAsFixed(2) ?? '0.00'}';
                  valueColor = Colors.green;
                } else if (label == 'Loss') {
                  displayValue =
                      '₹${product.totalLoss?.toStringAsFixed(2) ?? '0.00'}';
                  valueColor = Colors.red;
                } else if (label == 'Sold') {
                  displayValue = '${product.soldQty}';
                  valueColor = grey;
                }

                // Get percentage if available
                String percentageText = '';
                if (product.costPrice != null && product.costPrice! > 0) {
                  percentageText = isLoss
                      ? '${product.costPrice!.toStringAsFixed(1)}% loss'
                      : '${product.costPrice!.toStringAsFixed(1)}% profit';
                }

                return GestureDetector(
                  onTap: () {
                    Get.to(() => ProductDetail(product: product));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          spreadRadius: 1,
                          color: grey.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Product Image
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: product.productImage.isEmpty
                                ? Image.asset(
                                    'assets/images/noimg.png',
                                    height: 80,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    images[0],
                                    height: 80,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              'assets/images/noimg.png',
                                              height: 80,
                                              width: 100,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Name + Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName,
                                style: AppTextStyle.semiBoldTextstyle.copyWith(
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: AppTextStyle.regularTextstyle.copyWith(
                                  color: primary,
                                ),
                              ),
                              if (percentageText.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  percentageText,
                                  style: AppTextStyle.regularTextstyle.copyWith(
                                    fontSize: 11,
                                    color: isLoss ? Colors.red : Colors.green,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Value (Sold/Profit/Loss)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              label,
                              style: AppTextStyle.lableStyle.copyWith(
                                fontSize: 11,
                                color: grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayValue,
                              style: AppTextStyle.semiBoldTextstyle.copyWith(
                                color: valueColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailsCard({
    required IconData icon,
    required String label,
    required int count,
    required void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              blurRadius: 16.0,
              spreadRadius: 2.0,
              color: grey.withValues(alpha: 0.05),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(icon, size: 40, color: white),
            ),
            SizedBox(height: 16),
            Text(
              label,
              style: AppTextStyle.semiBoldTextstyle.copyWith(
                fontSize: 18,
                color: primary,
              ),
            ),
            Text(
              '$count',
              style: AppTextStyle.semiBoldTextstyle.copyWith(
                color: black,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
