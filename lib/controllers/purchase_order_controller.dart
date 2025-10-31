import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_flutter_app/model/inventory_item_model.dart';
import 'package:my_flutter_app/model/purchase_item_model.dart';
import '../dbservice/db_helper.dart';
import '../model/product_model.dart';
import '../model/purchase_order_model.dart';
import '../utils/dialog_utils.dart';
import '../utils/selling_price_confirm_dialogue.dart';
import '../utils/sr_generator.dart';
import '../widgets/app_snackbars.dart';

class PurchaseOrderController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// PagingController for infinite scroll
  final PagingController<int, PurchaseOrderModel> pagingController =
      PagingController<int, PurchaseOrderModel>(
        // Start with page 1
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => fetchAllReadyForReceivePOs(pageKey: pageKey),
      );


  final PagingController<int, PurchaseOrderModel> pagingControllerForReceived =
  PagingController<int, PurchaseOrderModel>(
    // Start with page 1
    getNextPageKey: (state) =>
    state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => fetchAllReceivePOs(pageKey: pageKey),
  );
  @override
  void onInit() {
    _confirmationTimer?.cancel();
    for (var controller in costPriceController) {
      controller.dispose();
    }
    for (var controller in marketPriceController) {
      controller.dispose();
    }
    for (var controller in sellingPriceController) {
      controller.dispose();
    }
    super.onInit();
  }

  /// on close
  @override
  void onClose() {
    pagingController.dispose();
    pagingControllerForReceived.dispose();
    super.onClose();
  }

  /// reactive variables
  RxList<PurchaseOrderItemModel> items = <PurchaseOrderItemModel>[].obs;

  /// PO items
  RxList<PurchaseOrderItemModel> poItems = <PurchaseOrderItemModel>[].obs;

  /// fetch po items
  Future<void> fetchAllPOItemsByPOID(int poID) async {
    try {
      _clearPricingFields();
      final orderItems = await DatabaseHelper.instance.getPOItemsByPOID(poID);
      costPriceController = List.generate(
        orderItems.length,
        (index) => TextEditingController(),
      );
      marketPriceController = List.generate(
        orderItems.length,
        (index) => TextEditingController(),
      );
      sellingPriceController = List.generate(
        orderItems.length,
        (index) => TextEditingController(),
      );
      confirmPriceController = List.generate(
        orderItems.length,
            (index) => TextEditingController(),
      );

      for (int i = 0; i < orderItems.length; i++) {
        var item = orderItems[i];
        selectedDiscountGroup[i] = 5;
        costPriceController[i].text = item.costPerUnit.toString();
        item.marketPrice = await fetchMarketPriceOfProduct(item.productId);
        marketPriceController[i].text = item.marketPrice.toString();

        if (item.srNo == null) {
          item.srNo = SRGenerator.generateSR(item.productId, poID);
          await DatabaseHelper.instance.updatePOItem(item);
        }

        calculateSellingPrice(autoFill: true, index: i);
      }
      poItems.assignAll(orderItems);
    } catch (e) {
      log("error (fetchAllPOItemsByPOID) ::: :::: :::: ${e.toString()}");
    }
  }

  /// fetch total quantity
  RxInt totalQuantity = 0.obs;
  RxDouble totalCost = 0.0.obs;

  /// editing controller
  final supplierNameController = TextEditingController();
  final itemNameController = TextEditingController();
  final itemCostPriceController = TextEditingController();
  final itemQuantityController = TextEditingController();
  int? itemID;
  int? supplierID;
  final selectedDate = Rxn<DateTime>();
  RxString supplierName = "".obs;

  /// add to list
  addToList() {
    int quantity = int.parse(itemQuantityController.text.toString());
    String productName = itemNameController.text.trim();
    double costPrice = double.parse(itemCostPriceController.text.toString());

    if (itemID != null) {
      /// check for duplicate
      int index = items.indexWhere((element) => element.productId == itemID);
      if (index == -1) {
        var poItem = PurchaseOrderItemModel(
          productId: itemID!,
          itemName: productName,
          costPerUnit: costPrice,
          quantity: quantity,
          isReceived: 0,
        );
        items.add(poItem);
      } else {
        items[index].quantity += quantity;
        items[index].costPerUnit = costPrice;
      }
    }
    calculateTotal();
    clearControllers();
  }

  /// remove item
  removeItem(int index) {
    items.removeAt(index);
    calculateTotal();
  }

  /// calculate totals
  void calculateTotal() {
    totalCost.value = 0.0;
    totalQuantity.value = 0;
    for (var item in items) {
      int quantity = item.quantity;
      totalQuantity.value += quantity;
      totalCost.value += item.costPerUnit * quantity;
    }
  }

  /// loading var
  RxBool isLoading = false.obs;
  /// add to database
  Future<void> addOREditPO({int? poID, int isReceived = 0}) async {
    try {
      if (supplierID != null) {
        isLoading.value = true;
        if (poID == null) {
          final po = PurchaseOrderModel(
            supplierId: supplierID!,
            isReceived: isReceived,
            orderDate: selectedDate.value ?? DateTime.now(),
            totalQty: totalQuantity.value,
            totalCost: totalCost.value,

            isPartiallyReceived: 0
          );
          final result = await DatabaseHelper.instance.insertPO(po);
          if (result != 0) {
            await addItemsToDB(result);
            pagingController.refresh();
            isLoading.value = false;
            Get.back();
            Get.closeAllSnackbars();
            AppSnackbars.success(
              'Success',
              'Purchase order created successfully',
            );
            items.clear();
          }
        } else {
          final po = PurchaseOrderModel(
            id: poID,
            isReceived: isReceived,
            supplierId: supplierID!,
            orderDate: selectedDate.value ?? DateTime.now(),
            totalQty: totalQuantity.value,
            totalCost: totalCost.value,

            isPartiallyReceived: 0,
          );

          final result = await DatabaseHelper.instance.updatePO(po);
          if (result != 0) {
            isLoading.value = false;
            Get.back();
            Get.closeAllSnackbars();
            AppSnackbars.success(
              'Success',
              'Purchase order received successfully',
            );
            items.clear();
          }
        }
      }
    } catch (e) {
      isLoading.value = false;
      log("error (addOREditPO) : : :: :: : : : ${e.toString()}");
    }
  }

  /// update purchase order items
  Future<void> updatePOItems() async {
    try {
      for (var item in poItems) {
        await DatabaseHelper.instance.updatePOItem(item);
      }
    } catch (e) {
      log("error (updatePOItems) :::: ::: ::: ${e.toString()} ");
    }
  }

  /// add order items
  Future<void> addItemsToDB(int poID) async {
    try {
      for (PurchaseOrderItemModel item in items) {
        item.purchaseOrderId = poID;
        await DatabaseHelper.instance.insertPOrderItem(item);
      }
    } catch (e) {
      log("error (addItemsToDB) :::: ::: ::: ${e.toString()} ");
    }
  }

  /// fill purchase order for edit
  Future<void> fillDataForEdit(
    PurchaseOrderModel po,
    List<PurchaseOrderItemModel> items,
  ) async {
    supplierID = po.supplierId;
    totalCost.value = po.totalCost;
    totalQuantity.value = po.totalQty;
    selectedDate.value = po.orderDate;
    final poItems = await DatabaseHelper.instance.getPOItemsByPOID(po.id!);
    items.assignAll(poItems);
  }

  /// get all purchase order ready for receiving
  final pageSize = 20;
  static Future<List<PurchaseOrderModel>> fetchAllReadyForReceivePOs({
    required int pageKey,
  }) async {
    try {
      final controller = Get.find<PurchaseOrderController>();
      final newPOs = await DatabaseHelper.instance.getPOs(
        isReceived: 0,
        limit: controller.pageSize,
        offset: (pageKey - 1) * controller.pageSize, // Offset for pagination
      );
      return newPOs;
    } catch (e) {
      log("error (getAllReadyForReceivePOs) :::: ::: :::: ${e.toString()}");
      return [];
    }
  }

  /// get all received purchase order
  static Future<List<PurchaseOrderModel>> fetchAllReceivePOs({
    required int pageKey,
  }) async {
    try {
      final controller = Get.find<PurchaseOrderController>();
      final newPOs = await DatabaseHelper.instance.getPOs(
        isReceived: 1,
        limit: controller.pageSize,
        offset: (pageKey - 1) * controller.pageSize, // Offset for pagination
      );
      return newPOs;
    } catch (e) {
      log("error (getAllReadyForReceivePOs) :::: ::: :::: ${e.toString()}");
      return [];
    }
  }

  /// fetch market price of product
  Future<double> fetchMarketPriceOfProduct(int productID) async {
    try {
      final modelData = await DatabaseHelper.instance.getProductByID(
        productID: productID,
      );
      if (modelData != null) {
        final product = ProductModel.fromMap(modelData);
        return product.marketPrice;
      }
      return 0.0;
    } catch (e) {
      log("error (fetchMarketPriceOfProduct) :::: ::: :::: ${e.toString()}");
      return 0.0;
    }
  }

  /// Text controllers for pricing
  List<TextEditingController> costPriceController = [];
  List<TextEditingController> marketPriceController = [];
  List<TextEditingController> discountController = [];
  List<TextEditingController> sellingPriceController = [];
  List<TextEditingController> confirmPriceController = [];

  /// Observable variables
  RxMap<int, dynamic> calculatedSellingPrice = <int, dynamic>{}.obs;
  RxMap<int, dynamic> profitMargin = <int, dynamic>{}.obs;
  RxMap<int, dynamic> profitAmount = <int, dynamic>{}.obs;
  RxMap<int, dynamic> pricingStatus =
      <int, dynamic>{}.obs; // 'success', 'warning', 'error'
  RxMap<int, dynamic> pricingMessage = <int, dynamic>{}.obs;
  RxMap<int, dynamic> selectedDiscountGroup =
      <int, dynamic>{}.obs;

  /// Available discount groups
  final List<int> discountGroups = [0, 5, 10, 15, 20, 25, 30, 40, 50];

  /// Timer for delayed confirmation
  Timer? _confirmationTimer;
  final confirmController = Get.put(ConfirmPriceController());

  /// Minimum acceptable profit margin (%)
  final double minimumProfitMargin = 5.0;

  /// Calculate selling price based on cost, market price, and discount
  // void calculateSellingPrice({bool autoFill = false, required int index}) {
  //   final cost = double.tryParse(costPriceController[index].text) ?? 0.0;
  //   final market = double.tryParse(marketPriceController[index].text) ?? 0.0;
  //   final discount = selectedDiscountGroup[index] ?? 0;
  //
  //   if (cost <= 0 || market <= 0) return;
  //
  //   final discountedPrice = market * (1 - discount / 100);
  //   final profit = discountedPrice - cost;
  //   final margin = (profit / cost) * 100;
  //
  //   calculatedSellingPrice[index] = discountedPrice;
  //   profitAmount[index] = profit;
  //   profitMargin[index] = margin;
  //
  //   _evaluatePricingScenario(cost, market, discountedPrice, margin, index);
  //
  //   if (autoFill) {
  //     sellingPriceController[index].text = discountedPrice.toStringAsFixed(2);
  //     confirmPriceController[index].text = discountedPrice.toStringAsFixed(2);
  //     _startDelayedConfirmation();
  //   } else {
  //     sellingPriceController[index].text = discountedPrice.toStringAsFixed(2);
  //     confirmPriceController[index].text = discountedPrice.toStringAsFixed(2);
  //   }
  // }

  void calculateSellingPrice({bool autoFill = false, required int index}) {
    final cost = double.tryParse(costPriceController[index].text) ?? 0.0;
    final market = double.tryParse(marketPriceController[index].text) ?? 0.0;
    double discount = double.tryParse( selectedDiscountGroup[index].toString()) ?? 0.0;

    if (cost <= 0 || market <= 0) return;

    double discountedPrice;
    double profit;
    double margin;

    if (cost > market) {
      // Case 1: Cost is higher than market — still ensure minimum profit
      discountedPrice = cost * (1 + minimumProfitMargin / 100);
      profit = discountedPrice - cost;
      margin = (profit / cost) * 100;

      pricingStatus[index] = 'warning';
      pricingMessage[index] =
      'Cost (₹${cost.toStringAsFixed(2)}) exceeds market (₹${market.toStringAsFixed(2)}). '
          'Auto-adjusted selling price to ₹${discountedPrice.toStringAsFixed(2)} '
          'to maintain minimum ${margin.toStringAsFixed(1)}% profit.';
    } else if ((market - cost) / cost < 0.02) {
      // Case 2: Market is only slightly higher than cost (<2% difference)
      discountedPrice = cost * (1 + minimumProfitMargin / 100);
      profit = discountedPrice - cost;
      margin = (profit / cost) * 100;

      pricingStatus[index] = 'warning';
      pricingMessage[index] =
      'Market price (₹${market.toStringAsFixed(2)}) is very close to cost '
          '(₹${cost.toStringAsFixed(2)}). Auto-adjusted selling price to ₹${discountedPrice.toStringAsFixed(2)} '
          'to ensure minimum ${margin.toStringAsFixed(1)}% profit.';
    } else {
      // Case 3: Normal — Market ≥ Cost and sufficient difference
      discountedPrice = market * (1 - discount / 100);
      profit = discountedPrice - cost;
      margin = (profit / cost) * 100;

      _evaluatePricingScenario(cost, market, discountedPrice, margin, index);
    }

    // Update computed values
    calculatedSellingPrice[index] = discountedPrice;
    profitAmount[index] = profit;
    profitMargin[index] = margin;

    // Update text fields
    sellingPriceController[index].text = discountedPrice.toStringAsFixed(2);
    confirmPriceController[index].text = discountedPrice.toStringAsFixed(2);

    // Auto-fill confirmation if needed
    if (autoFill) {
      _startDelayedConfirmation();
    }
  }



  /// check for confirm price is not getting loss
  void checkConfirmPrice(int index){
    final cost = double.tryParse(costPriceController[index].text) ?? 0.0;
    final market = double.tryParse(marketPriceController[index].text) ?? 0.0;
    final confirmPrice = double.tryParse(confirmPriceController[index].text) ?? 0.0;

    if (cost <= 0 || market <= 0) return;

    final profit = confirmPrice - cost;
    final margin = (profit / cost) * 100;
    profitAmount[index] = profit;
    profitMargin[index] = margin;
    _evaluatePricingScenario(cost, market, confirmPrice, margin, index);
  }

  /// Evaluate pricing scenario and set status/message
  void _evaluatePricingScenario(
      double cost,
      double market,
      double sellingPrice,
      double margin,
      int index,
      ) {
    if (cost > market) {
      if (sellingPrice >= cost) {
        /// Case: cost > market but still profitable
        pricingStatus[index] = 'warning';
        pricingMessage[index] =
        'Cost price (₹${cost.toStringAsFixed(2)}) exceeds market price '
            '(₹${market.toStringAsFixed(2)}), but you are selling above cost '
            '(₹${sellingPrice.toStringAsFixed(2)}). '
            'Profit margin: ${margin.toStringAsFixed(1)}%.';
      } else {
        /// Case: cost > market and selling below cost → true loss
        pricingStatus[index] = 'error';
        pricingMessage[index] =
        'Selling below cost! Cost (₹${cost.toStringAsFixed(2)}) > Market (₹${market.toStringAsFixed(2)}). '
            'Selling price ₹${sellingPrice.toStringAsFixed(2)} will incur a loss.';
      }
    } else if (sellingPrice < cost) {
      /// CRITICAL: Selling price below cost
      final maxDiscount = ((market - cost) / market) * 100;
      pricingStatus[index] = 'error';
      pricingMessage[index] =
      'Selling price (₹${sellingPrice.toStringAsFixed(2)}) is below cost! '
          'You will lose ₹${(cost - sellingPrice).toStringAsFixed(2)} per unit. '
          'Maximum safe discount: ${maxDiscount.toStringAsFixed(1)}%.';
    } else if (margin < minimumProfitMargin) {
      /// WARNING: Low profit margin
      pricingStatus[index] = 'warning';
      pricingMessage[index] =
      'Low profit margin (${margin.toStringAsFixed(1)}%). Consider '
          'reducing discount or negotiating better cost prices.';
    } else if (margin > 50) {
      /// SUCCESS: High profit margin
      pricingStatus[index] = 'success';
      pricingMessage[index] =
      'Excellent profit margin (${margin.toStringAsFixed(1)}%)! '
          'You have room for competitive pricing or increased marketing.';
    } else {
      /// SUCCESS: Healthy profit margin
      pricingStatus[index] = 'success';
      pricingMessage[index] =
      'Healthy profit margin (${margin.toStringAsFixed(1)}%). '
          'Sustainable pricing strategy.';
    }
  }


  /// Reset all pricing data
  void _resetPricingData() {
    calculatedSellingPrice.clear();
    for(var c in sellingPriceController) {
      c.clear();
    }
    isCalcVisible.updateAll((key, value) => false,);
    isManualPrice.updateAll((key, value) => false,);
    profitMargin.clear();
    profitAmount.clear();
    pricingStatus.clear();
    pricingMessage.clear();
  }

  /// Start delayed confirmation dialog
  void _startDelayedConfirmation() {
    _confirmationTimer?.cancel();

    confirmController.startDelayedConfirm(
      onAccept: () {
        /// User accepted the calculated price
        log("Price accepted by user");

        AppSnackbars.success(
          'Price Confirmed',
          'Selling price has been applied successfully',
        );
      },
      onCancel: () {
        /// User cancelled - clear all fields
        _resetPricingData();
        AppSnackbars.error(
          'Price Cancelled',
          'All pricing fields have been cleared',
        );
      },
    );
  }

  /// Clear all pricing-related fields
  void _clearPricingFields() {
    for (var c in costPriceController) {
      c.clear();
    }
    for (var c in marketPriceController) {
      c.clear();
    }
    for (var c in discountController) {
      c.clear();
    }


    /// selectedDiscountGroup.value = 10;
    _resetPricingData();
  }

  /// Get maximum safe discount percentage
  double getMaxSafeDiscount(int index) {
    final cost = double.tryParse(costPriceController[index].text) ?? 0.0;
    final market = double.tryParse(marketPriceController[index].text) ?? 0.0;

    if (cost <= 0 || market <= 0 || cost >= market) return 0.0;

    /// Calculate discount that maintains minimum profit margin
    final minSellingPrice = cost * (1 + minimumProfitMargin / 100);
    final maxDiscount = ((market - minSellingPrice) / market) * 100;

    return maxDiscount.clamp(0.0, 100.0);
  }

  /// Suggest optimal discount based on market conditions
  int suggestOptimalDiscount(int index) {
    final maxSafe = getMaxSafeDiscount(index);

    /// Find the largest discount group that's still safe
    for (int i = discountGroups.length - 1; i >= 0; i--) {
      if (discountGroups[i] <= maxSafe) {
        return discountGroups[i];
      }
    }
    return 0;
  }

  /// clear controller
  clearControllers() {
    itemID = null;
    selectedDate.value = DateTime.now();
    itemNameController.clear();
    itemQuantityController.clear();
    itemCostPriceController.clear();
  }

  /// In your PurchaseOrderController
  RxMap<int, bool> isManualPrice = <int, bool>{}.obs;
  RxMap<int, bool> isCalcVisible = <int, bool>{}.obs;

  /// toggle manual price
  void toggleManualPrice(int index) {
    isManualPrice[index] = !(isManualPrice[index] ?? false);
    if(isManualPrice[index] ?? false){
    isCalcVisible[index] = false;
    }
  }

  /// toggle calculator
  void toggleCalcVisibility(int index) {
    isCalcVisible[index] = !(isCalcVisible[index] ?? false);
  }

  /// loading var


  /// Save to db and increase product quantity in products
  Future<void> saveToDB({required int purchaseOrderId, bool isAll = false}) async {
    if (selectedItems.isEmpty) return;

    try {
      isLoading.value = true;
      final db = DatabaseHelper.instance;
      int processedCount = 0;

      // Process only selected items
      final itemsToProcess = selectedItems.map((index) => poItems[index]).toList();

      // Batch operations for better performance
      for (var i = 0; i < itemsToProcess.length; i++) {
        final item = itemsToProcess[i];
        final index = selectedItems.elementAt(i);
        final priceText = confirmPriceController[index].text;

        if (priceText.isEmpty) continue;

        final sellingPrice = double.tryParse(priceText) ?? 0.0;

        // Create inventory model
        final modelData = InventoryItemModel(
          invQuantity: item.quantity,

          productId: item.productId,
          serialNumber: item.srNo!,
          sellingPrice: sellingPrice,
        );

        // Execute all operations for this item
        await db.insertInventory(modelData);
        await db.updateProductStock(
          productID: item.productId,
          sellingPrice: sellingPrice,
          quantity: item.quantity,
        );

        item.isReceived = 1;
        final result = await db.updatePOItem(item);


        if (result > 0) processedCount++;

      }

      // Update PO status based on completion
      if (processedCount > 0) {
        final isFullyReceived = selectedItems.length == poItems.length;
        final result = await db.updatePOStatus(
          poID: purchaseOrderId,
          isPartial: isFullyReceived ? 0 : 1,
          isReceived: isFullyReceived ? 1 : 0,
        );

        if (result > 0) {
          final message = isFullyReceived
              ? "Order fully received successfully"
              : "Order partially received successfully";


          if(isFullyReceived){
            poItems.clear();
            pagingController.refresh();
          } else {
            for(int i = 0;i<selectedItems.length;i++){
              poItems.removeAt(i);
            }
          }
          isSelectMode.value = false;
          isSelectAll.value = false;
          selectedItems.clear();

          DialogUtils.showFullScreenDialog(
            title: 'Success!',
            message: message,
          );
        }
      }
    } catch (e) {
      log("error (saveToDB): ${e.toString()}");
      // Consider showing error dialog to user
      DialogUtils.showFullScreenDialog(
        title: 'Error!',
        message: "Failed to save order. Please try again.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // selected item
RxList<int> selectedItems = <int>[].obs;



  // select mode toggle
RxBool isSelectMode = false.obs;
RxBool isSelectAll = false.obs;




}
