import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import '../dbservice/db_helper.dart';
import '../model/order_item_model.dart';
import '../model/order_model.dart';
import '../utils/app_constant.dart';
import '../widgets/app_snackbars.dart' show AppSnackbars;
import 'dashboard_controller.dart';

class OrderController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static final controller = Get.find<OrderController>();

  // PagingController for infinite scroll

  // fetch all orders (admin)
  final PagingController<int, OrderModel> pagingControllerForAllOrders =
      PagingController<int, OrderModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllOrders(page: pageKey),
      );

  // Fetch paid orders (admin)
  final PagingController<int, OrderModel> pagingControllerForPaid =
      PagingController<int, OrderModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllPaidOrders(page: pageKey),
      );

  // Fetch Processing orders (admin)
  final PagingController<int, OrderModel> pagingControllerForProcessing =
      PagingController<int, OrderModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllProcessingOrders(page: pageKey),
      );

  // Fetch Shipped orders (admin)
  final PagingController<int, OrderModel> pagingControllerForShipped =
      PagingController<int, OrderModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllShippedOrders(page: pageKey),
      );

  // Fetch delivered orders (admin)
  final PagingController<int, OrderModel> pagingControllerForDelivered =
      PagingController<int, OrderModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllDeliveredOrders(page: pageKey),
      );

  // Fetch cancelled orders (admin)
  final PagingController<int, OrderModel> pagingControllerForCencelled =
      PagingController<int, OrderModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllCancelledOrders(page: pageKey),
      );

  // fetch all orders (user)
  final PagingController<int, OrderModel> pagingControllerForUserOrders =
      PagingController<int, OrderModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllUserOrders(page: pageKey),
      );

  // Fetch delivered orders (user)
  final PagingController<int, OrderModel> pagingControllerForUserDelivered =
      PagingController<int, OrderModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchDeliveredOrders(page: pageKey),
      );

  late TabController tabController;
  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: storage.read(ROLE) == "admin" ? 6 : 2,
      vsync: this,
    );
  }

  @override
  void onClose() {
    pagingControllerForUserOrders.dispose();
    pagingControllerForUserDelivered.dispose();
    pagingControllerForAllOrders.dispose();
    pagingControllerForPaid.dispose();
    pagingControllerForProcessing.dispose();
    pagingControllerForShipped.dispose();
    pagingControllerForDelivered.dispose();
    pagingControllerForCencelled.dispose();
    super.onClose();
  }

  GetStorage storage = GetStorage();
  String formatOrderDate(String rawDate) {
    DateTime parsedDate = DateTime.parse(rawDate);
    return DateFormat('d MMMM yyyy').format(parsedDate);
  }

  RxBool isLoading = false.obs;
  RxList<OrderModel> orders = <OrderModel>[].obs;
  RxList<OrderItemModel> orderItems = <OrderItemModel>[].obs;
  RxList<OrderModel> userOrders = <OrderModel>[].obs;
  RxList<String> allStatus = [
    PAID,
    PROCESSING,
    SHIPPED,
    DELIVERED,
    CANCELLED,
  ].obs;

  // fetch all orders
  int currentPage = 0;
  int pageSize = 10;
  int totalPages = 0;

  static Future<List<OrderModel>> fetchAllOrders({required int page}) async {
    try {
      controller.isLoading.value = true;
      final newOrders = await DatabaseHelper.instance.getAllOrders(
        limit: controller.pageSize,
        offset: (page - 1) * controller.pageSize,
      );
      return newOrders;
    } catch (e) {
      log("error (fetchAllOrders) : : : :${e.toString()}");
      return [];
    } finally {
      controller.isLoading.value = false;
    }
  }

  // fetch all user orders
  static Future<List<OrderModel>> fetchAllUserOrders({
    required int page,
  }) async {
    try {
      controller.isLoading.value = true;
      final newOrders = await DatabaseHelper.instance.getAllUserOrders(
        controller.storage.read(USERID),
        limit: controller.pageSize,
        offset: (page - 1) * controller.pageSize,
      );

      return newOrders;
    } catch (e) {
      log("error (fetchAllUserOrders) : : : :${e.toString()}");
      return [];
    } finally {
      controller.isLoading.value = false;
    }
  }

  final dashboardController = Get.put(DashboardController());

  /// change order status
  Future<void> changeStatus(String status, int orderID) async {
    try {
      var result = await DatabaseHelper.instance.updateStatus(
        orderID: orderID,
        status: status,
      );
      Get.closeAllSnackbars();
      if (result != null && result != 0) {
        final oldStatus = orderStatus.value;
        AppSnackbars.success("Success!", "status updated successfully!");
        orderStatus.value = status;

        pagingControllerForAllOrders.refresh();
        switch (oldStatus) {
          case PAID:
            pagingControllerForPaid.refresh();

            break;
          case PROCESSING:
            pagingControllerForProcessing.refresh();
            break;
          case SHIPPED:
            pagingControllerForShipped.refresh();
            break;
          case DELIVERED:
            pagingControllerForDelivered.refresh();
            break;
          case CANCELLED:
            pagingControllerForCencelled.refresh();
            break;
        }
        switch (status) {
          case PAID:
            pagingControllerForPaid.refresh();

            break;
          case PROCESSING:
            pagingControllerForProcessing.refresh();
            break;
          case SHIPPED:
            pagingControllerForShipped.refresh();
            break;
          case DELIVERED:
            pagingControllerForDelivered.refresh();
            break;
          case CANCELLED:
            pagingControllerForCencelled.refresh();
            break;
        }
        // await fetchAllOrders();
        await dashboardController.fetchDashboardData();
      } else {
        AppSnackbars.error("Failed!", "Failed to update status!");
      }
    } catch (e) {
      AppSnackbars.warning("Oops!", "Something went wrong!");
    }
  }

  RxList<OrderModel> deliveredOrders = <OrderModel>[].obs;
  RxList<OrderModel> cancelledOrders = <OrderModel>[].obs;

  // fetch delivered orders by user id and status
  int currentDeliverPage = 0;
  int deliverPageSize = 5;
  int totalDeliverPages = 0;
  RxBool isDeliverLoading = false.obs;
  static Future<List<OrderModel>> fetchDeliveredOrders({
    required int page,
  }) async {
    try {
      controller.isDeliverLoading.value = true;
      final newOrders = await DatabaseHelper.instance.getUsersOrdersByStatus(
        controller.storage.read(USERID),
        DELIVERED,
        limit: controller.deliverPageSize,
        offset: (page - 1) * controller.deliverPageSize,
      );

      return newOrders;
    } catch (e) {
      log("error (fetchDeliveredOrders) : : : : ${e.toString()}");
      return [];
    } finally {
      controller.isDeliverLoading.value = false;
    }
  }

  // fetch orders by status for admin
  RxList<OrderModel> allPaidOrders = <OrderModel>[].obs;
  RxList<OrderModel> allProcessingOrders = <OrderModel>[].obs;
  RxList<OrderModel> allShippedOrders = <OrderModel>[].obs;
  RxList<OrderModel> allDeliveredOrders = <OrderModel>[].obs;
  RxList<OrderModel> allCancelledOrders = <OrderModel>[].obs;

  // fetch paid
  int currentPaidPage = 0;
  int paidPageSize = 5;
  int totalPaidPages = 0;
  RxBool isPaidLoading = false.obs;
  static Future<List<OrderModel>> fetchAllPaidOrders({
    required int page,
  }) async {
    try {
      controller.isPaidLoading.value = true;
      final newOrders = await DatabaseHelper.instance.getOrdersByStatus(
        PAID,
        limit: controller.paidPageSize,
        offset: (page - 1) * controller.paidPageSize,
      );
      return newOrders;
    } catch (e) {
      log("error (fetchAllPaidOrders) : : : : ${e.toString()}");
      return [];
    } finally {
      controller.isPaidLoading.value = false;
    }
  }

  // fetch processing
  int currentProcessingPage = 0;
  int processingPageSize = 5;
  int totalProcessingPages = 0;
  RxBool isProcessingLoading = false.obs;
  static Future<List<OrderModel>> fetchAllProcessingOrders({
    required int page,
  }) async {
    try {
      controller.isProcessingLoading.value = true;
      final newOrders = await DatabaseHelper.instance.getOrdersByStatus(
        PROCESSING,
        limit: controller.processingPageSize,
        offset: (page - 1) * controller.processingPageSize,
      );

      return newOrders;
    } catch (e) {
      log("error (fetchAllProcessingOrders) : : : : ${e.toString()}");
      return [];
    } finally {
      controller.isProcessingLoading.value = false;
    }
  }

  // fetch shipped
  int currentShippedPage = 0;
  int shippedPageSize = 5;
  int totalShippedPages = 0;
  RxBool isShippedLoading = false.obs;
  static Future<List<OrderModel>> fetchAllShippedOrders({
    required int page,
  }) async {
    try {
      controller.isShippedLoading.value = true;
      final newOrders = await DatabaseHelper.instance.getOrdersByStatus(
        SHIPPED,
        limit: controller.shippedPageSize,
        offset: (page - 1) * controller.shippedPageSize,
      );
      return newOrders;
    } catch (e) {
      log("error (fetchAllShippedOrders) : : : : ${e.toString()}");
      return [];
    } finally {
      controller.isShippedLoading.value = false;
    }
  }

  // fetch delivered
  static Future<List<OrderModel>> fetchAllDeliveredOrders({
    required int page,
  }) async {
    try {
      controller.isDeliverLoading.value = true;
      final newOrders = await DatabaseHelper.instance.getOrdersByStatus(
        DELIVERED,
        limit: controller.deliverPageSize,
        offset: (page - 1) * controller.deliverPageSize,
      );
      return newOrders;
    } catch (e) {
      log("error (fetchAllDeliveredOrders) : : : : ${e.toString()}");
      return [];
    } finally {
      controller.isDeliverLoading.value = false;
    }
  }

  // fetch cancelled
  int currentCancelledPage = 0;
  int cancelledPageSize = 5;
  int totalCancelledPages = 0;
  RxBool isCancelledLoading = false.obs;
  static Future<List<OrderModel>> fetchAllCancelledOrders({
    required int page,
  }) async {
    try {
      controller.isCancelledLoading.value = true;
      final newOrders = await DatabaseHelper.instance.getOrdersByStatus(
        CANCELLED,
        limit: controller.cancelledPageSize,
        offset: (page - 1) * controller.cancelledPageSize,
      );
      return newOrders;
    } catch (e) {
      log("error (fetchAllCancelledOrders) : : : : ${e.toString()}");
      return [];
    } finally {
      controller.isCancelledLoading.value = false;
    }
  }

  // fetch order for detail
  RxString razorpayOrderID = "".obs;
  RxString shippingAddress = "".obs;
  RxString customerName = "".obs;
  RxString orderDate = "".obs;
  RxString paymentMethod = "".obs;
  RxDouble totalPaidAmount = 0.0.obs;
  RxString orderStatus = "".obs;
  RxDouble deliveryCharge = 0.0.obs;

  // fetch order by id
  Future<void> fetchOrderByID(int orderID) async {
    try {
      var result = await DatabaseHelper.instance.getOrderByID(orderID);
      orderItems.value = await DatabaseHelper.instance.getOrderItemsByOrderID(
        orderID,
      );
      if (result != null) {
        razorpayOrderID.value = result.paymentIntentId ?? 'Undefined';
        shippingAddress.value = result.shippingAddress;
        orderDate.value = result.orderDate;
        customerName.value = result.customerName;
        paymentMethod.value = result.paymentMethod;
        totalPaidAmount.value = result.totalAmount;
        orderStatus.value = result.orderStatus;
        deliveryCharge.value = result.deliveryCharge;
      }
    } catch (e) {
      log("error (fetchOrderByID) : : : : : ${e.toString()} ");
    }
  }
}
