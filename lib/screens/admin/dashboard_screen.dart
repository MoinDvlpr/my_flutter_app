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

  final dashboardController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    dashboardController.fetchDashboardData();
    GetStorage storage = GetStorage();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(),
      drawer: AdminDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Hello\n",
                            style: AppTextStyle.lableStyle.copyWith(
                              fontSize: 22,
                            ),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailsCard(
                            icon: Icons.person_outline_rounded,
                            label: 'Customers',
                            count: dashboardController.totalUsers.value,
                            onTap: () => Get.to(() => UsersScreen()),
                          ),
                        ),
                        Expanded(
                          child: _buildDetailsCard(
                            icon: Icons.store_mall_directory_outlined,
                            label: 'Products',
                            count: dashboardController.totalProducts.value,
                            onTap: () => Get.to(() => ProductsScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Report",
                      style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 10),

                    // Date Range Picker
                    Obx(() {
                      final format = DateFormat('dd MMM yyyy');
                      final dateRange =
                          "${format.format(dashboardController.startDate.value)} to ${format.format(dashboardController.endDate.value)}";

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
                              color: Colors.black.withOpacity(0.05),
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
                                    style: AppTextStyle.semiBoldTextstyle
                                        .copyWith(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
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
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Charts
                    const ProfitLossChart(),
                    Text(
                      "Order Summary",
                      style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                    ),
                    OrderStatusChart(),
                    Text(
                      'Customer Order Locations',
                      style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // Google Map (Fixed Height)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 350,
              child: Obx(() {
                // This forces the entire GoogleMap to rebuild when markers change
                final currentMarkers = dashboardController.markers.toSet();

                return GoogleMap(
                  key: ValueKey(
                    currentMarkers.length + currentMarkers.hashCode,
                  ), // Critical!
                  onTap: (_) => Get.to(() => OrdersMapScreen()),
                  markers: currentMarkers,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(20.5937, 78.9629),
                    zoom: 5,
                  ),
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: dashboardController.onMapCreated,
                );
              }),
            ),
          ),
          // Product Sections as Independent SliverLists
          _productsSliverSection(
            products: dashboardController.topProducts,
            title: "Most Selling Products",
            label: 'Sold',
          ),
          _productsSliverSection(
            products: dashboardController.topRevenueProducts,
            title: "Revenue Making Products",
            label: 'Profit',
          ),
          _productsSliverSection(
            products: dashboardController.topLossProducts,
            title: "Loss Making Products",
            label: 'Loss',
            isLoss: true,
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // Reusable Sliver Section for Product Lists
  // ──────────────────────────────────────────────────────────────
  // FIXED: Reusable Sliver Section for Product Lists (NO followedBy)
  // ──────────────────────────────────────────────────────────────
  Widget _productsSliverSection({
    required RxList products,
    required String title,
    required String label,
    bool isLoss = false,
  }) {
    return SliverMainAxisGroup(
      slivers: [
        // Title (only show when there is data)
        SliverToBoxAdapter(
          child: Obx(() {
            String heading = "Top ${products.length} $title";
            return products.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 10),
                    child: Text(
                      heading,
                      style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                    ),
                  );
          }),
        ),

        // The actual scrollable list (only if not empty)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: Obx(
            () => products.isEmpty
                ? const SliverToBoxAdapter(child: SizedBox.shrink())
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = products[index];
                      List<File> images = [];

                      if (product.productImage.isNotEmpty) {
                        List<String> imagePaths = product.productImage.split(
                          ',',
                        );
                        images = imagePaths.map((p) => File(p)).toList();
                      }

                      String displayValue = '';
                      Color valueColor = grey;

                      if (label == 'Profit') {
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

                      String percentageText = '';
                      if (product.costPrice != null && product.costPrice! > 0) {
                        percentageText = isLoss
                            ? '${product.costPrice!.toStringAsFixed(1)}% loss'
                            : '${product.costPrice!.toStringAsFixed(1)}% profit';
                      }

                      return GestureDetector(
                        onTap: () =>
                            Get.to(() => ProductDetail(product: product)),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8,
                                color: grey.withOpacity(0.1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: product.productImage.isEmpty
                                      ? Image.asset(
                                          'assets/images/noimg.png',
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          images[0],
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Image.asset(
                                                'assets/images/noimg.png',
                                                fit: BoxFit.cover,
                                              ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: AppTextStyle.semiBoldTextstyle
                                          .copyWith(fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${product.price.toStringAsFixed(0)}',
                                      style: AppTextStyle.regularTextstyle
                                          .copyWith(color: primary),
                                    ),
                                    if (percentageText.isNotEmpty)
                                      Text(
                                        percentageText,
                                        style: AppTextStyle.regularTextstyle
                                            .copyWith(
                                              fontSize: 11,
                                              color: isLoss
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
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
                                  Text(
                                    displayValue,
                                    style: AppTextStyle.semiBoldTextstyle
                                        .copyWith(
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
                    }, childCount: products.length),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(blurRadius: 16, color: grey.withOpacity(0.05))],
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 40, color: white),
            ),
            const SizedBox(height: 16),
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
