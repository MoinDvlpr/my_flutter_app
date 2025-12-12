import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../controllers/supplier_controller.dart';
import '../../../model/purchase_order_model.dart';
import '../../../model/supplier_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/suppliers_purchase_order_card.dart';
import 'add_edit_supplier_screen.dart';
import 'supplier_po_screen.dart';

class SupplierInfoScreen extends StatelessWidget {
  final SupplierModel supplier;
  SupplierInfoScreen({super.key, required this.supplier});
  final supplierController = Get.find<SupplierController>();

  final PagingController<int, PurchaseOrderModel> pagingController =
      PagingController<int, PurchaseOrderModel>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => Get.find<SupplierController>()
            .fetchSupplierPurchaseOrders(page: pageKey),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supplier Info', style: AppTextStyle.semiBoldTextstyle),
        backgroundColor: bg,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: primary),
            onPressed: () {
              supplierController.clearControllers();
              supplierController.supplierNameController.text =
                  supplier.supplierName;
              supplierController.supplierContactController.text = supplier
                  .contact
                  .toString();
              Get.to(
                () => AddEditSupplierScreen(supplierID: supplier.supplierId),
              );
            },
          ),
        ],
      ),
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Supplier Info Card
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primary.withOpacity(0.1),
                      radius: 30,
                      child: Icon(Icons.business, color: primary, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                supplier.supplierName,
                                style: AppTextStyle.boldTextstyle.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              (supplierController.isSupplierActive[supplier
                                          .supplierId!] ??
                                      supplier.isActive)
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          'Active',
                                          style: AppTextStyle.semiBoldTextstyle
                                              .copyWith(
                                                color: Colors.green,
                                                fontSize: 12,
                                              ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          'Inactive',
                                          style: AppTextStyle.semiBoldTextstyle
                                              .copyWith(
                                                color: Colors.red,
                                                fontSize: 12,
                                              ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: grey),
                              const SizedBox(width: 4),
                              Text(
                                supplier.contact.toString(),
                                style: AppTextStyle.lableStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Stats Section
                Obx(
                  () => supplierController.isLoadingStats.value
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(color: primary),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => _statItem(
                              'Total Orders',
                              '${supplierController.totalOrders.value}',
                              Icons.shopping_cart,
                              Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => _statItem(
                              'Total Spent',
                              '₹${supplierController.totalSpent.value.toStringAsFixed(2)}',
                              Icons.currency_rupee,
                              Colors.green,
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
                            () => _statItem(
                              'Total Units',
                              '${supplierController.totalUnits.value}',
                              Icons.inventory_2,
                              Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => _statItem(
                              'Avg Cost/Unit',
                              '₹${supplierController.avgCostPerUnit.value.toStringAsFixed(2)}',
                              Icons.analytics,
                              Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Purchase Orders Section
          // Enhanced Title Row with "View All" Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Purchase Orders',
                  style: AppTextStyle.boldTextstyle.copyWith(fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: () {
                    Get.to(
                      () => SupplierPurchaseOrdersScreen(supplier: supplier),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: PagingListener(
              builder: (context, state, fetchNextPage) =>
                  PagedListView<int, PurchaseOrderModel>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate:
                        PagedChildBuilderDelegate<PurchaseOrderModel>(
                          itemBuilder: (context, order, index) {
                            return purchaseOrderCard(order);
                          },
                          firstPageErrorIndicatorBuilder: (context) => Center(
                            child: Text(
                              'Failed to load purchase orders',
                              style: AppTextStyle.regularTextstyle,
                            ),
                          ),
                          noItemsFoundIndicatorBuilder: (context) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 64,
                                  color: grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No purchase orders found',
                                  style: AppTextStyle.regularTextstyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
              controller: pagingController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyle.lableStyle.copyWith(fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyle.boldTextstyle.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}
