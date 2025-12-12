import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import '../../../controllers/order_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../model/order_model.dart';
import '../../../model/usermodel.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';
import '../order/order_details.dart';

class UserOrdersScreen extends StatelessWidget {
  final UserModel user;
  UserOrdersScreen({super.key, required this.user});
  final userController = Get.find<UserController>();
  final orderController = Get.put(OrderController());
  final PagingController<int, OrderModel> pagingController =
      PagingController<int, OrderModel>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) =>
            Get.find<UserController>().fetchUsersOrders(page: pageKey),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders History', style: AppTextStyle.semiBoldTextstyle),
        backgroundColor: bg,
        elevation: 0,
      ),
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.userName,
                  style: AppTextStyle.boldTextstyle.copyWith(fontSize: 18),
                ),
                Text(user.email, style: AppTextStyle.lableStyle),
              ],
            ),
          ),
          Expanded(
            child: PagingListener(
              builder: (context, state, fetchNextPage) =>
                  PagedListView<int, OrderModel>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    builderDelegate: PagedChildBuilderDelegate<OrderModel>(
                      itemBuilder: (context, order, index) {
                        return _orderCard(order);
                      },
                      firstPageErrorIndicatorBuilder: (context) => Center(
                        child: Text(
                          'Failed to load orders',
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
                              'No orders found',
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

  Widget _orderCard(OrderModel order) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final orderDate = DateTime.tryParse(order.orderDate);

    Color statusColor;
    switch (order.orderStatus.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () async {
        Get.to(() => OrderDetails(order: order, orderID: order.orderId!));
        await orderController.fetchOrderByID(order.orderId!);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderId}',
                  style: AppTextStyle.semiBoldTextstyle,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.orderStatus,
                    style: AppTextStyle.regularTextstyle.copyWith(
                      color: statusColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: grey),
                const SizedBox(width: 6),
                Text(
                  orderDate != null
                      ? dateFormat.format(orderDate)
                      : order.orderDate,
                  style: AppTextStyle.lableStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 14, color: grey),
                const SizedBox(width: 6),
                Text(
                  '${order.totalQuantity} items',
                  style: AppTextStyle.lableStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payment, size: 14, color: grey),
                const SizedBox(width: 6),
                Text(
                  order.paymentMethod,
                  style: AppTextStyle.lableStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount', style: AppTextStyle.lableStyle),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: AppTextStyle.boldTextstyle.copyWith(
                    fontSize: 16,
                    color: primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
