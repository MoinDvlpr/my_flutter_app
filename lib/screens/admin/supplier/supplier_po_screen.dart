// Add this import at the top if not already there
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../controllers/supplier_controller.dart';
import '../../../model/purchase_order_model.dart';
import '../../../model/supplier_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../widgets/suppliers_purchase_order_card.dart';

// Add this new screen right below your current file or in a new file
class SupplierPurchaseOrdersScreen extends StatelessWidget {
  final SupplierModel supplier;
  SupplierPurchaseOrdersScreen({super.key, required this.supplier});

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
        title: Text(
          'Purchase Orders - ${supplier.supplierName}',
          style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 18),
        ),
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: bg,

      body: PagingListener(
        controller: pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, PurchaseOrderModel>(
              builderDelegate: PagedChildBuilderDelegate<PurchaseOrderModel>(
                itemBuilder: (context, order, index) =>
                    purchaseOrderCard(order),
                firstPageErrorIndicatorBuilder: (_) => Center(
                  child: Text(
                    'Error loading orders',
                    style: AppTextStyle.regularTextstyle,
                  ),
                ),
                noItemsFoundIndicatorBuilder: (_) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: grey),
                      const SizedBox(height: 16),
                      Text(
                        'No purchase orders found',
                        style: AppTextStyle.regularTextstyle,
                      ),
                    ],
                  ),
                ),
                newPageProgressIndicatorBuilder: (_) => const Center(
                  child: CircularProgressIndicator(color: primary),
                ),
              ),
              state: state,
              fetchNextPage: fetchNextPage,
            ),
      ),
    );
  }
}
