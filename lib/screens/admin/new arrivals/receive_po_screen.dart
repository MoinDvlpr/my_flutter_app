import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../controllers/purchase_order_controller.dart';
import '../../../model/purchase_order_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../utils/date_formator.dart';
import '../../../widgets/appsubmitbtn.dart';
import '../purchase_order/create_po_screen.dart';
import 'start_receiving_order.dart';

class ReceivePOsScreen extends StatelessWidget {
  ReceivePOsScreen({super.key});
  final poController = Get.find<PurchaseOrderController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Receive POs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            padding: EdgeInsets.only(right: 8.0),
            width: 60,
            child: GlobalAppSubmitBtn(
              title: 'Add',
              onTap: () {
                poController.clearControllers();
                Get.to(() => CreatePoScreen());
              },
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          children: [
            // // Search bar
            // SearchBar(
            //   onTapOutside: (event) {
            //     FocusManager.instance.primaryFocus?.unfocus();
            //   },
            //   backgroundColor: WidgetStatePropertyAll(bg),
            //   hintText: 'Search by PO # or location',
            //   onChanged: (value) async {
            //     // _debouncer.run(
            //     //       () => productController.updateSearchQuery(value.trim()),
            //     // );
            //   },
            //   hintStyle: WidgetStatePropertyAll(AppTextStyle.lableStyle),
            //   elevation: WidgetStatePropertyAll(0.0),
            //   side: WidgetStatePropertyAll(BorderSide(width: 1, color: grey)),
            // ),
            //
            // const SizedBox(height: 20),

            // PO Cards
            Expanded(
              child: PagingListener(
                controller: poController.pagingController,
                builder: (context, state, fetchNextPage) =>
                    PagedListView<int, PurchaseOrderModel>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, po, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildPOCard(
                              poNumber: 'ID #${po.id}',
                              items: '${po.totalQty} Items',
                              status: 'Arrived',
                              date: DateFormator.formateDate(po.orderDate),
                              supplier: '${po.supplier}',
                              buttonColor: primary.withAlpha(30),
                              textColor: primary,
                              onBtnTap: () async {
                                Get.to(() => StartReceivingOrder(po: po));
                                poController.poItems.clear();
                              },
                            ),
                          );
                        },
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card Widget
  Widget _buildPOCard({
    required String poNumber,
    required String items,
    required String status,
    required String date,
    required String supplier,
    required Color buttonColor,
    required Color textColor,
    required void Function() onBtnTap,
  }) {
    return GestureDetector(
      onTap: onBtnTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row (PO #, Items)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(poNumber, style: AppTextStyle.semiBoldTextstyle),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      items,
                      style: AppTextStyle.regularTextstyle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                    if (status.isNotEmpty)
                      Text(
                        status,
                        style: AppTextStyle.lableStyle.copyWith(fontSize: 14),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Special Order • Default Truck - HVAC Team',
              style: AppTextStyle.lableStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: AppTextStyle.lableStyle.copyWith(fontSize: 14),
                ),
                Text(
                  supplier,
                  style: AppTextStyle.lableStyle.copyWith(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Button
            Container(
              width: double.infinity,
              height: 38,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: textColor, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Add to stock',
                      style: AppTextStyle.semiBoldTextstyle.copyWith(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
