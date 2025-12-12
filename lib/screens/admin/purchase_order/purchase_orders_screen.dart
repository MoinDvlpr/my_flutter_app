import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../controllers/purchase_order_controller.dart';
import '../../../model/purchase_order_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../../../utils/date_formator.dart';

class PurchaseOrdersScreen extends StatelessWidget {
  PurchaseOrdersScreen({super.key});
  final poController = Get.find<PurchaseOrderController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Purchase orders',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          children: [
            // PO Cards
            Expanded(
              child: PagingListener(
                controller: poController.pagingControllerForReceived,
                builder: (context, state, fetchNextPage) =>
                    PagedListView<int, PurchaseOrderModel>(
                      state: state,
                      fetchNextPage: fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, po, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildPOCard(
                              poNumber: 'Order #${po.id}',
                              items: '${po.totalQty} Items',
                              productName: po.productName ?? 'N/A',
                              status: 'Received',
                              date: DateFormator.formateDate(po.orderDate),
                              supplier: '${po.supplier}',
                              buttonColor: primary.withAlpha(30),
                              textColor: primary,
                              onBtnTap: () async {},
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

  Widget _buildPOCard({
    required String poNumber,
    required String items,
    required String status,
    required String date,
    required String supplier,
    required String productName,
    required Color buttonColor,
    required Color textColor,
    required void Function() onBtnTap,
  }) {
    return GestureDetector(
      onTap: onBtnTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: grey.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: PO Number + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  poNumber,
                  style: AppTextStyle.semiBoldTextstyle.copyWith(
                    fontSize: 18,
                    color: primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        status.toLowerCase().contains('received')
                            ? Icons.check_circle
                            : status.toLowerCase().contains('partial')
                            ? Icons.access_time
                            : Icons.schedule,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Product Name — Highlighted & Prominent
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withOpacity(0.3), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Product",
                          style: AppTextStyle.lableStyle.copyWith(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          productName,
                          style: AppTextStyle.semiBoldTextstyle.copyWith(
                            fontSize: 16,
                            color: primary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Items Count
            Row(
              children: [
                Icon(Icons.shopping_cart_outlined, size: 16, color: grey),
                const SizedBox(width: 8),
                Text(
                  items,
                  style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date & Supplier Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: "Date",
                    value: date,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.business_rounded,
                    label: "Supplier",
                    value: supplier,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text(
              'Special Order • Default Truck - HVAC Team',
              style: AppTextStyle.lableStyle.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onBtnTap,
                icon: const Icon(Icons.check_circle, size: 20),
                label: Text(
                  status.toLowerCase().contains('received')
                      ? 'Already Received'
                      : 'Mark as Received',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: textColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable info row (same as previous card)
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyle.lableStyle.copyWith(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
