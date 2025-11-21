// Updated InventoryController with Weighted Average Cost (WAC) calculation

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../dbservice/db_helper.dart';
import '../model/inventory_model.dart';
import '../model/product_model.dart';
import '../model/product_report_model.dart';
import '../screens/admin/inventory/inventory_screen.dart';
import '../widgets/app_snackbars.dart';

class InventoryController extends GetxController
    with GetTickerProviderStateMixin {
  /// PagingController for infinite scroll
  final PagingController<int, InventoryModel> pagingController =
      PagingController<int, InventoryModel>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchInventories(pageKey: pageKey),
      );

  final PagingController<int, ProductModel> pagingControllerForAllProducts =
      PagingController<int, ProductModel>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchProducts(pageKey: pageKey),
      );

  final PagingController<int, ProductModel> pagingControllerForSoldOuts =
      PagingController<int, ProductModel>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) =>
            fetchProducts(pageKey: pageKey, isForOutOfStock: true),
      );

  // Product data
  final productName = "".obs;
  final costPrice = 0.00.obs;
  final weightedAverageCost = 0.00.obs; // NEW: WAC value
  final marketPrice = 0.00.obs;
  final currentSellingPrice = 0.00.obs;
  Rx<double> profitMargin = 0.0.obs;
  Rx<double> maxProfit = 100.0.obs;

  // NEW: Store all inventory batches for the product
  List<InventoryModel> productInventoryBatches = [];
  int? currentProductId;

  // Reactive fields
  final priceController = TextEditingController();
  final newSellingPrice = RxnDouble();
  final profitAmount = RxnDouble();
  final profitPercent = RxnDouble();
  final statusMessage = RxnString();
  final statusColor = Rxn<Color>();
  final statusIcon = Rxn<IconData>();
  final showPriceStatus = false.obs;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animationController);

    priceController.addListener(calculatePriceFromTextField);
  }

  RxBool isLoading = false.obs;
  RxDouble percentageOfMargin = 50.0.obs;

  /// NEW: Calculate Weighted Average Cost
  double calculateWeightedAverageCost(List<InventoryModel> batches) {
    if (batches.isEmpty) return 0.0;

    double totalCost = 0.0;
    int totalRemaining = 0;

    for (var batch in batches) {
      if (batch.remaining > 0) {
        totalCost += (batch.costPerUnit * batch.remaining);
        totalRemaining += batch.remaining;
      }
    }

    if (totalRemaining == 0) return 0.0;
    return totalCost / totalRemaining;
  }

  /// NEW: Fetch all batches and calculate WAC-based pricing
  Future<void> fetchAndCalculateWACPricing(int productId) async {
    try {
      isLoading.value = true;
      currentProductId = productId;

      // Fetch all inventory batches for this product
      productInventoryBatches = await DatabaseHelper.instance
          .getInventoryByProductId(productId);

      if (productInventoryBatches.isEmpty) {
        AppSnackbars.error("Error", "No inventory found for this product");
        isLoading.value = false;
        return;
      }

      // Calculate Weighted Average Cost
      final wac = calculateWeightedAverageCost(productInventoryBatches);
      weightedAverageCost.value = wac;

      // Calculate recommended selling price using WAC
      final difference = marketPrice.value - wac;
      final recommendedPrice =
          wac + (difference * (percentageOfMargin.value / 100));

      newSellingPrice.value = recommendedPrice;
      priceController.text = recommendedPrice.toStringAsFixed(2);

      // Calculate profit margin based on WAC
      if (wac > 0) {
        profitMargin.value = ((marketPrice.value - wac) / wac) * 100;

        if (profitMargin.value > 100.0) {
          maxProfit.value = profitMargin.value;
        } else if (profitMargin.value < 0.0) {
          profitMargin.value = 0.0;
        }
      }

      // Trigger price calculation to show status
      calculatePriceFromTextField();

      isLoading.value = false;
    } catch (e) {
      AppSnackbars.error(
        "Error",
        "Failed to calculate pricing: ${e.toString()}",
      );
      isLoading.value = false;
    }
  }

  void setData({
    required InventoryModel inventory,
    bool isFromInventory = false,
  }) async {
    productName.value = inventory.productName ?? 'undefined';
    marketPrice.value = inventory.marketPrice ?? 0.0;
    currentSellingPrice.value = inventory.currentSellingPrice ?? 0.0;
    // Original logic for non-inventory flow
    costPrice.value = inventory.costPerUnit;
    // NEW: If from inventory, fetch all batches and calculate WAC
    if (inventory.productId != null) {
      await fetchAndCalculateWACPricing(inventory.productId!);
      return; // Early return as WAC calculation handles the rest
    }

    if (!(isFromInventory && inventory.sellingPrice == null)) {
      if (costPrice.value > 0) {
        profitMargin.value =
            ((marketPrice.value - costPrice.value) / costPrice.value) * 100;

        if (profitMargin.value > 100.0) {
          maxProfit.value = profitMargin.value;
        } else if (profitMargin.value < 0.0) {
          profitMargin.value = 0.0;
        }
      }

      if (!isFromInventory) {
        final difference = marketPrice.value - costPrice.value;
        newSellingPrice.value =
            costPrice.value + (difference * (percentageOfMargin.value / 100));
        priceController.text = newSellingPrice.value!.toStringAsFixed(2);
      } else {
        if (currentSellingPrice.value > 0) {
          newSellingPrice.value = null;
          priceController.text = "";
        }
      }
    } else {
      profitMargin.value = 0;
    }
  }

  /// Clamp value between min and max
  double _clampValue(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Called when user manually changes the price in TextField
  void calculatePriceFromTextField() {
    final input = priceController.text.trim();
    if (input.isEmpty) {
      showPriceStatus.value = false;
      return;
    }

    final price = double.tryParse(input);

    if (price == null || price < 0) {
      Get.snackbar(
        "Invalid Input",
        "Please enter a valid price",
        backgroundColor: Colors.red.withValues(alpha: 0.2),
      );
      return;
    }

    newSellingPrice.value = price;
    // Use WAC (which is stored in costPrice) for profit calculations
    profitAmount.value = price - costPrice.value;
    profitPercent.value = (profitAmount.value! / costPrice.value) * 100;

    // Update maxProfit if needed
    if ((profitPercent.value ?? 0.0) > maxProfit.value) {
      maxProfit.value = profitPercent.value ?? 100.0;
    }

    // Clamp and update the profit margin slider to reflect the new price
    double clampedMargin = _clampValue(
      profitPercent.value ?? 0.0,
      0.0,
      maxProfit.value,
    );
    profitMargin.value = clampedMargin;

    // Determine status
    if (price < costPrice.value) {
      statusMessage.value = "Loss! Price is below weighted average cost.";
      statusColor.value = Colors.red;
      statusIcon.value = Icons.trending_down;
    } else if (price > marketPrice.value) {
      statusMessage.value = "Above market price, might affect sales.";
      statusColor.value = Colors.blue;
      statusIcon.value = Icons.info;
    } else if ((profitPercent.value ?? 0.0) < 5) {
      statusMessage.value = "Very low margin, consider increasing.";
      statusColor.value = Colors.orange;
      statusIcon.value = Icons.warning;
    } else if ((profitPercent.value ?? 0.0) <= 20) {
      statusMessage.value = "Balanced and competitive.";
      statusColor.value = Colors.green;
      statusIcon.value = Icons.check_circle;
    } else {
      statusMessage.value = "Good profit margin.";
      statusColor.value = Colors.green;
      statusIcon.value = Icons.trending_up;
    }

    showPriceStatus.value = true;
    if (!animationController.isAnimating) {
      animationController.forward(from: 0.0);
    }
  }

  /// Called when user changes the slider
  void onSliderChanged(double value) {
    // Clamp the value to ensure it's within valid range
    double clampedValue = _clampValue(value, 0.0, maxProfit.value);
    profitMargin.value = clampedValue;

    // Calculate selling price based on profit margin percentage (using WAC)
    final sellingPrice = costPrice.value * (1 + (clampedValue / 100));
    newSellingPrice.value = sellingPrice;

    // Update text field without triggering listener
    priceController.removeListener(calculatePriceFromTextField);
    priceController.text = sellingPrice.toStringAsFixed(2);
    priceController.addListener(calculatePriceFromTextField);

    // Calculate profit amount and percent
    profitAmount.value = sellingPrice - costPrice.value;
    profitPercent.value = clampedValue;

    // Update price status
    calculatePrice();
  }

  void calculatePrice() {
    final price = newSellingPrice.value ?? 0.0;
    final profit = profitPercent.value ?? 0.0;

    // Determine status
    if (price < costPrice.value) {
      statusMessage.value = "Loss! Price is below cost.";
      statusColor.value = Colors.red;
      statusIcon.value = Icons.trending_down;
    } else if (price > marketPrice.value) {
      statusMessage.value = "Above market price, might affect sales.";
      statusColor.value = Colors.blue;
      statusIcon.value = Icons.info;
    } else if (profit < 5) {
      statusMessage.value = "Very low margin, consider increasing.";
      statusColor.value = Colors.orange;
      statusIcon.value = Icons.warning;
    } else if (profit <= 20) {
      statusMessage.value = "Balanced and competitive.";
      statusColor.value = Colors.green;
      statusIcon.value = Icons.check_circle;
    } else {
      statusMessage.value = "Good profit margin.";
      statusColor.value = Colors.green;
      statusIcon.value = Icons.trending_up;
    }

    showPriceStatus.value = true;
    if (!animationController.isAnimating) {
      animationController.forward(from: 0.0);
    }
  }

  /// NEW: Update price for all batches of the product
  Future<void> updatePrice(
    InventoryModel inventory, {
    bool isFromInventory = false,
  }) async {
    if (newSellingPrice.value == null) {
      AppSnackbars.error("Error", "Please enter a valid price first");
      return;
    }
    isLoading.value = true;
    try {
      // If we have multiple batches (from WAC calculation), update all of them
      if (productInventoryBatches.isNotEmpty && currentProductId != null) {
        int successCount = 0;

        for (var batch in productInventoryBatches) {
          if (batch.remaining > 0) {
            batch.sellingPrice = newSellingPrice.value;
            batch.isReadyForSale = true;
            final result = await DatabaseHelper.instance.updateInventory(batch);
            if (result != 0) {
              successCount++;
            }
          }
        }

        if (successCount > 0) {
          final isDone = await DatabaseHelper.instance
              .updateProductPriceAndStock(
                prodcutID: inventory.productId,
                qty: inventory.remaining,
                newPrice: newSellingPrice.value ?? 0.0,
              );
          if (isDone != 0) {
            pagingController.refresh();
            pagingControllerForAllProducts.refresh();
            Get.back(result: true);
            Get.back(result: true);
            if (!isFromInventory) {
              Get.off(() => InventoryScreen());
            }
            AppSnackbars.success(
              "Success",
              "Selling price updated for $successCount batch(es)",
            );
          }
        } else {
          AppSnackbars.error("Error", "Failed to update selling price");
        }
      } else {
        // Single batch update (original logic)
        inventory.sellingPrice = newSellingPrice.value;
        final result = await DatabaseHelper.instance.updateInventory(inventory);

        if (result != 0) {
          pagingController.refresh();
          pagingControllerForAllProducts.refresh();
          Get.back(result: true);
          Get.off(() => InventoryScreen());
          AppSnackbars.success("Success", "Selling price updated successfully");
        } else {
          AppSnackbars.error("Error", "Failed to update selling price");
        }
      }
    } catch (e) {
      AppSnackbars.error("Error", "Failed to update: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      priceController.clear();
      newSellingPrice.value = null;
      showPriceStatus.value = false;
      animationController.reverse();
    });
  }

  // get all inventory
  static Future<List<InventoryModel>> fetchInventories({
    required int pageKey,
    bool? isInsale,
  }) async {
    return await DatabaseHelper.instance.getInventories(
      offset: (pageKey - 1) * 20,
      isInSale: isInsale,
    );
  }

  // for displaying info
  ProductReportModel? report;

  // reactive variables
  // list for filling report items
  RxList<ReportItemModel> reportItems = <ReportItemModel>[].obs;

  //// fetch out of stock products
  static Future<List<ProductModel>> fetchProducts({
    required int pageKey,
    bool isForOutOfStock = false,
  }) async {
    return await DatabaseHelper.instance.getProducts(
      limit: 20,
      offset: (pageKey - 1) * 20,
      forOutOfStock: isForOutOfStock,
    );
  }

  RxInt totalSoldUnits = 0.obs;
  RxDouble totalRevenue = 0.0.obs;
  RxInt totalRemaining = 0.obs;
  RxDouble totalCost = 0.0.obs;

  /// get product report
  fetchProductReport(int productID) async {
    // fetch product report
    report = await DatabaseHelper.instance.getProductReport(productID);
    totalRevenue.value = report!.totalRevenue;
    totalRemaining.value = report!.totalRemaining;
    totalCost.value = report!.totalCost;

    if (report != null) {
      reportItems.assignAll(report!.reportItems);
    }
  }

  void reset() {
    priceController.clear();
    newSellingPrice.value = null;
    productName.value = "";
    costPrice.value = 0.00;
    weightedAverageCost.value = 0.00;
    marketPrice.value = 0.00;
    currentSellingPrice.value = 0.00;
    profitMargin.value = 0.0;
    maxProfit.value = 100.0;

    profitAmount.value = null;
    profitPercent.value = null;
    statusMessage.value = null;
    statusColor.value = null;
    statusIcon.value = null;
    showPriceStatus.value = false;

    productInventoryBatches = [];
    currentProductId = null;
  }

  RxBool showProceedButton = false.obs;

  void startProceedDelay(bool isFromInventory) {
    if (isFromInventory) {
      showProceedButton.value = true;
      return;
    }

    showProceedButton.value = false;
    Future.delayed(const Duration(seconds: 3), () {
      showProceedButton.value = true;
    });
  }

  @override
  void onClose() {
    priceController.dispose();
    animationController.dispose();
    super.onClose();
  }
}
