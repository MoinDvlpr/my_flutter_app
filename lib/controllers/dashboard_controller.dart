import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_app/utils/app_constant.dart';
import '../dbservice/db_helper.dart';
import '../model/order_model.dart';
import '../model/product_model.dart';
import '../model/profitdatamodel.dart';

class DashboardController extends GetxController {
  @override
  void onInit() {
    fetchDashboardData();
    fetchProfitLossData();
    fetchMostSellingProducts(isInitial: true);

    fetchTopProfitProducts();
    fetchTopLossProducts();
    _loadOrderLocations(); // Load order locations on init
    log(":::: :::: :::: :::: ::: ::: ::: ::: on init called");
    super.onInit();
  }

  // Observable lists
  final topRevenueProducts = <ProductModel>[].obs;
  final topLossProducts = <ProductModel>[].obs;

  // Fetch profit products
  Future<void> fetchTopProfitProducts() async {
    try {
      // Try the simple version first as it's more reliable
      final products = await DatabaseHelper.instance
          .getTop5ProfitProductsSimple();

      if (products.isEmpty) {
        // If simple version returns nothing, try the complex version
        final productsComplex = await DatabaseHelper.instance
            .getTop5ProfitProducts();
        topRevenueProducts.value = productsComplex;
      } else {
        topRevenueProducts.value = products;
      }

      log('Fetched ${topRevenueProducts.length} profit products');
    } catch (e) {
      log('Error fetching profit products: $e');
      topRevenueProducts.value = [];
    }
  }

  // Fetch loss products
  Future<void> fetchTopLossProducts() async {
    try {
      // Try the simple version first
      final products = await DatabaseHelper.instance
          .getTop5LossProductsSimple();

      if (products.isEmpty) {
        // If simple version returns nothing, try the complex version
        final productsComplex = await DatabaseHelper.instance
            .getTop5LossProducts();
        topLossProducts.value = productsComplex;
      } else {
        topLossProducts.value = products;
      }

      log('Fetched ${topLossProducts.length} loss products');
    } catch (e) {
      log('Error fetching loss products: $e');
      topLossProducts.value = [];
    }
  }

  RxList<ProfitLossData> chartData = <ProfitLossData>[].obs;
  var startDate = DateTime(DateTime.now().year, 1, 1).obs;
  var endDate = DateTime.now().obs;

  Future<void> pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      initialDateRange: DateTimeRange(
        start: startDate.value,
        end: endDate.value,
      ),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;
      await fetchProfitLossData();
    }
  }

  Future<void> fetchProfitLossData() async {
    final data = await DatabaseHelper.instance.getProfitLossReport(
      startDate.value.toIso8601String(),
      endDate.value.toIso8601String(),
    );
    chartData.assignAll(data);
    for (var data in chartData) {
      log("date ${data.date} profit ${data.profit} loss ${data.loss}");
    }
  }

  RxInt totalUsers = 0.obs;
  RxInt totalProducts = 0.obs;
  int totalOrders = 0;
  RxDouble paid = 0.0.obs;
  RxDouble processing = 0.0.obs;
  RxDouble shipped = 0.0.obs;
  RxDouble delivered = 0.0.obs;
  RxDouble cancelled = 0.0.obs;
  RxList<ProductModel> topProducts = <ProductModel>[].obs;
  RxMap<String, int> orderSummary = <String, int>{}.obs;

  // Fetch dashboard data
  Future<void> fetchDashboardData() async {
    try {
      var db = DatabaseHelper.instance;
      totalUsers.value = await db.getTotalUsers();
      totalProducts.value = await db.getTotalProducts();
      totalOrders = await db.getAllOrdersCounts();
      orderSummary.value = await db.getOrderStatusSummary();

      if (totalOrders != 0) {
        paid.value = ((orderSummary['Paid'] ?? 0.0) / totalOrders) * 100.0;
        processing.value =
            ((orderSummary['Processing'] ?? 0.0) / totalOrders) * 100.0;
        shipped.value =
            ((orderSummary['Shipped'] ?? 0.0) / totalOrders) * 100.0;
        delivered.value =
            ((orderSummary['Delivered'] ?? 0.0) / totalOrders) * 100.0;
        cancelled.value =
            ((orderSummary['Cancelled'] ?? 0.0) / totalOrders) * 100.0;
      }
    } catch (e) {
      log("error (fetchDashboardData) : : : : ${e.toString()}");
    }
  }

  final Completer<GoogleMapController> mapController = Completer();
  void onMapCreated(GoogleMapController controller) {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
      log("Map created with ID: ${controller.mapId}");
    }
  }

  // Observable for markers and orders to update UI
  RxSet<Marker> markers = <Marker>{}.obs;
  RxList<OrderModel> orders = <OrderModel>[].obs;

  Future<void> _loadOrderLocations() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final orderData = await dbHelper.getOrderLocations(
        statusFilter: DELIVERED,
      );
      log("Fetched orders: $orderData");

      // Convert List<Map<String, dynamic>> to List<OrderModel>
      final orderModels = orderData;
      log(":::: :::: ::: ::: ::: locations ${orderModels.length}");
      // Clear and populate markers
      markers.clear();
      for (var order in orderData) {
        markers.add(
          Marker(
            markerId: MarkerId(order.orderId.toString()),
            position: LatLng(order.latitude, order.longitude),
            infoWindow: InfoWindow(
              title: order.customerName,
              snippet: '${order.shippingAddress} (${order.orderStatus})',
            ),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      }
      log("Markers created: ${markers.length}");

      // Update observable orders
      orders.value = orderModels;
      _fitMarkersToScreen();
    } catch (e) {
      log("error (_loadOrderLocations) : : : : ${e.toString()}");
    }
  }

  void _fitMarkersToScreen() async {
    if (markers.isNotEmpty && mapController.isCompleted) {
      final controller = await mapController.future;
      double minLat = 8.0; // India's southern bound
      double maxLat = 37.0; // India's northern bound
      double minLng = 68.0; // India's western bound
      double maxLng = 97.0; // India's eastern bound

      for (var marker in markers) {
        minLat = marker.position.latitude < minLat
            ? marker.position.latitude
            : minLat;
        maxLat = marker.position.latitude > maxLat
            ? marker.position.latitude
            : maxLat;
        minLng = marker.position.longitude < minLng
            ? marker.position.longitude
            : minLng;
        maxLng = marker.position.longitude > maxLng
            ? marker.position.longitude
            : maxLng;
      }

      // Handle case where all markers are at the same point
      if (minLat == maxLat || minLng == maxLng) {
        minLat -= 0.01;
        maxLat += 0.01;
        minLng -= 0.01;
        maxLng += 0.01;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50), // 50px padding
      );
      log(
        "Map moved to bounds: southwest ($minLat, $minLng), northeast ($maxLat, $maxLng)",
      );
    } else {
      log(
        "No markers or map controller not ready: markers=${markers.length}, mapController.isCompleted=${mapController.isCompleted}",
      );
    }
  }

  // Fetch most selling products
  int currentPage = 0;
  int totalPages = 0;
  int pageSize = 5;
  RxBool isLoading = false.obs;
  Future<void> fetchMostSellingProducts({bool isInitial = false}) async {
    try {
      if (isInitial) {
        topProducts.clear();
        currentPage = 0;
      }
      isLoading.value = true;
      final prods = await DatabaseHelper.instance.getMostSellingProduct(
        limit: 5,
        offset: currentPage * pageSize,
      );
      totalPages = await DatabaseHelper.instance
          .getMostSellingProductTotalPages(pageSize: pageSize);
      if (currentPage != totalPages) {
        topProducts.addAll(prods);
        currentPage++;
      }
    } catch (e) {
      log("error (fetchMostSellingProducts) : : : : ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
