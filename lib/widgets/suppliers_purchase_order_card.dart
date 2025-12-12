import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/purchase_order_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_textstyles.dart';

Widget purchaseOrderCard(PurchaseOrderModel order) {
  final dateFormat = DateFormat('dd MMM yyyy');

  // Helper to get status color and text
  Color getStatusColor() {
    if (order.isReceived == 1) return Colors.green;
    if (order.isPartiallyReceived == 1) return Colors.orange;
    return Colors.grey.shade600;
  }

  String getStatusText() {
    if (order.isReceived == 1) return 'Received';
    if (order.isPartiallyReceived == 1) return 'Partially Received';
    return 'Pending';
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    padding: const EdgeInsets.all(18.0),
    decoration: BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(16.0),
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
        // PO Header: PO# + Status Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PO #${order.id}',
              style: AppTextStyle.semiBoldTextstyle.copyWith(
                fontSize: 18,
                color: primary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: getStatusColor().withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: getStatusColor().withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    order.isReceived == 1
                        ? Icons.check_circle
                        : order.isPartiallyReceived == 1
                        ? Icons.access_time
                        : Icons.schedule,
                    size: 14,
                    color: getStatusColor(),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    getStatusText(),
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 12,
                      color: getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Product Name - Highlighted Section
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
                      order.productName ?? "Unnamed Product",
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

        // Details Row: Date, Qty, Price per unit
        Row(
          children: [
            Expanded(
              child: _buildInfoChip(
                icon: Icons.calendar_today_rounded,
                label: "Order Date",
                value: order.orderDate != null
                    ? dateFormat.format(order.orderDate!)
                    : 'N/A',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoChip(
                icon: Icons.inventory_2_rounded,
                label: "Quantity",
                value: '${order.totalQty} units',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildInfoChip(
                icon: Icons.paid_rounded,
                label: "Unit Price",
                value: '₹${order.costPerUnit.toStringAsFixed(2)}',
                valueColor: Colors.green.shade700,
              ),
            ),
          ],
        ),

        const Divider(height: 32, thickness: 1),

        // Total Cost - Highlighted
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Amount',
              style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 17),
            ),
            Text(
              '₹${order.totalCost.toStringAsFixed(2)}',
              style: AppTextStyle.boldTextstyle.copyWith(
                fontSize: 20,
                color: primary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Reusable chip-style info row
Widget _buildInfoChip({
  required IconData icon,
  required String label,
  required String value,
  Color? valueColor,
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
            style: AppTextStyle.semiBoldTextstyle.copyWith(
              fontSize: 14,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    ],
  );
}
