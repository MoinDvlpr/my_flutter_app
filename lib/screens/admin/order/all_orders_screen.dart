import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_flutter_app/utils/app_colors.dart';
import '../../../controllers/order_controller.dart';
import '../../../model/order_model.dart';
import '../../../utils/app_textstyles.dart';
import 'order_details.dart';

class AllOrdersScreen extends StatelessWidget {
  AllOrdersScreen({super.key});
  final OrderController orderController = Get.put(OrderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: orderController.tabController,
          isScrollable: true,
          labelColor: black,
          unselectedLabelColor: grey,
          indicatorColor: black,
          tabs: [
            Tab(text: 'All Orders'),
            Tab(text: 'Paid'),
            Tab(text: 'Processing'),
            Tab(text: 'Shipped'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: orderController.tabController,
        children: [
          buildOrderList(
            pageController: orderController.pagingControllerForAllOrders,
          ),
          buildOrderList(
            pageController: orderController.pagingControllerForPaid,
          ),
          buildOrderList(
            pageController: orderController.pagingControllerForProcessing,
          ),
          buildOrderList(
            pageController: orderController.pagingControllerForShipped,
          ),

          buildOrderList(
            pageController: orderController.pagingControllerForDelivered,
          ),
          buildOrderList(
            pageController: orderController.pagingControllerForCencelled,
          ),
        ],
      ),
    );
  }

  Widget buildOrderList({
    required PagingController<int, OrderModel> pageController,
  }) {
    return PagingListener(
      controller: pageController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, OrderModel>.separated(
            state: state,
            fetchNextPage: fetchNextPage,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Order ${order.razorpayOrderId ?? 'Undefined'}",
                            style: AppTextStyle.semiBoldTextstyle.copyWith(
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                        Text(
                          orderController.formatOrderDate(order.orderDate),
                          style: AppTextStyle.lableStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Quantity: ${order.totalQuantity}",
                      style: AppTextStyle.regularTextstyle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total Amount: ₹${order.totalAmount.toStringAsFixed(0)}",
                      style: AppTextStyle.semiBoldTextstyle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            if (order.orderId != null) {
                              Get.to(
                                () => OrderDetails(
                                  orderID: order.orderId!,
                                  order: order,
                                ),
                              );
                              await orderController.fetchOrderByID(
                                order.orderId!,
                              );
                            }
                          },
                          child: Text(
                            "Details",
                            style: AppTextStyle.regularTextstyle.copyWith(
                              fontSize: 14,
                            ),
                          ),
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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
          ),
    );
  }
}
