import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/order_controller.dart';
import '../../../model/order_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';

class OrderDetails extends StatelessWidget {
  OrderDetails({super.key, required this.orderID, required this.order});
  final orderController = Get.find<OrderController>();
  final int orderID;
  final OrderModel order;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text("Order Details")),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 16),
            Text(
              "${orderController.orderItems.length} items",
              style: AppTextStyle.semiBoldTextstyle,
            ),
            SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: orderController.orderItems.length,
              itemBuilder: (context, index) {
                final item = orderController.orderItems[index];
                List<File> images = [];
                if (item.itemImage.isNotEmpty) {
                  // On load from DB
                  List<String> imagePaths = item.itemImage.split(',');
                  images = imagePaths.map((p) => File(p)).toList();
                }
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  leading: // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.itemImage.isEmpty
                        ? Image.asset(
                            'assets/images/noimg.png',
                            height: 80,
                            width: 100,
                            fit: BoxFit.contain,
                          )
                        : images[0].existsSync()
                        ? Image.file(
                            images[0],
                            height: 80,
                            width: 100,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            'assets/images/noimg.png',
                            height: 80,
                            width: 100,
                            fit: BoxFit.contain,
                          ),
                  ),
                  title: Text(
                    item.itemName,
                    style: AppTextStyle.semiBoldTextstyle,
                  ),
                  subtitle: Text(
                    "Qty: ${item.itemQty} • ₹${item.itemPrice.toStringAsFixed(0)}",
                    style: AppTextStyle.regularTextstyle.copyWith(fontSize: 14),
                  ),
                  trailing: Text(
                    "₹${(item.itemPrice * item.itemQty).toStringAsFixed(0)}",
                    style: AppTextStyle.regularTextstyle.copyWith(fontSize: 14),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Order information",
              style: AppTextStyle.semiBoldTextstyle,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              "Customer name :",
              orderController.customerName.value,
            ),
            _buildInfoRow(
              "Shipping Address:",
              orderController.shippingAddress.value,
            ),
            _buildInfoRow(
              "Payment method:",
              "${orderController.paymentMethod}",
            ),
            _buildInfoRow(
              "Total Amount:",
              "₹${orderController.totalPaidAmount.toStringAsFixed(0)}",
              isBold: true,
              fontSize: 16,
              color: Colors.black,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Change Status'),
              initialValue:
                  orderController.allStatus.contains(
                    orderController.orderStatus.value,
                  )
                  ? orderController.orderStatus.value
                  : null,
              items: orderController.allStatus.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status, style: AppTextStyle.regularTextstyle),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  orderController.changeStatus(value, orderID);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              orderController.razorpayOrderID.value,
              style: AppTextStyle.semiBoldTextstyle,
            ),
            SizedBox(height: 4.0),
            Text(
              'Status',
              style: AppTextStyle.semiBoldTextstyle.copyWith(fontSize: 14),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              orderController.orderDate.value.isNotEmpty
                  ? orderController.formatOrderDate(
                      orderController.orderDate.value,
                    )
                  : 'dd mm yyyy',
              style: AppTextStyle.regularTextstyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                orderController.orderStatus.value,
                style: AppTextStyle.regularTextstyle.copyWith(
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Widget? icon,
    bool isBold = false,
    double fontSize = 14,
    Color color = Colors.grey,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyle.lableStyle.copyWith(fontSize: fontSize),
            ),
          ),
          if (icon != null) ...[icon, const SizedBox(width: 6)],
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.lableStyle.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
