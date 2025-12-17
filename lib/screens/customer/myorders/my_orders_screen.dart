import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../controllers/order_controller.dart';
import '../../../model/order_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import 'order_detail_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  MyOrdersScreen({super.key});
  final OrderController orderController = Get.put(OrderController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),

        bottom: TabBar(
          controller: orderController.tabController,
          labelColor: black,
          unselectedLabelColor: grey,
          indicatorColor: black,
          tabs: [
            Tab(text: 'All Orders'),
            Tab(text: 'Delivered'),
          ],
        ),
      ),
      backgroundColor: bg,
      body: TabBarView(
        controller: orderController.tabController,
        children: [
          _buildOrderList(
            pageController: orderController.pagingControllerForUserOrders,
          ),

          _buildOrderList(
            pageController: orderController.pagingControllerForUserDelivered,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList({
    required PagingController<int, OrderModel> pageController,
  }) {
    return PagingListener(
      controller: pageController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, OrderModel>.separated(
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, order, index) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order ${order.paymentIntentId ?? 'Undefined'}",
                      style: AppTextStyle.semiBoldTextstyle.copyWith(
                        fontSize: 16,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orderController.formatOrderDate(order.orderDate),
                      style: AppTextStyle.lableStyle,
                    ),
                    const SizedBox(height: 4),
                    Text("Quantity: ${order.totalQuantity}"),
                    const SizedBox(height: 4),
                    Text(
                      "Total Amount: ₹${order.totalAmount.toStringAsFixed(0)}",
                      style: AppTextStyle.semiBoldTextstyle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            if (order.orderId != null) {
                              Get.to(() => OrderDetailScreen(order: order));
                              await orderController.fetchOrderByID(
                                order.orderId!,
                              );
                            }
                          },
                          child: Text("Details"),
                        ),
                        Text(
                          order.orderStatus,
                          style: AppTextStyle.semiBoldTextstyle.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            padding: EdgeInsets.all(12),

            separatorBuilder: (_, __) => const SizedBox(height: 12),
            fetchNextPage: fetchNextPage,
            state: state,
          ),
    );
  }
}
