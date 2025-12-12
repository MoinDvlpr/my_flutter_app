import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:my_flutter_app/model/inventory_item_model.dart';
import 'package:my_flutter_app/model/purchase_item_model.dart';
import 'package:my_flutter_app/utils/app_constant.dart';
import '../dbservice/db_helper.dart';
import '../model/inventory_model.dart';
import '../model/product_model.dart';
import '../model/purchase_order_model.dart';
import '../screens/admin/new arrivals/calculate_price.dart';
import '../utils/dialog_utils.dart';
import '../utils/selling_price_confirm_dialogue.dart';
import '../utils/sr_generator.dart';
import '../widgets/app_snackbars.dart';
import 'inventory_controller.dart';

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
  RxList<InventoryItemModel> poItems = <InventoryItemModel>[].obs;

  /// fetch po items
  Future<void> assignSR(PurchaseOrderModel po) async {
    try {
      int length = po.totalQty;
      poItems.clear();
      final product = await DatabaseHelper.instance.getProductByID(
        productID: po.productID,
      );
      for (int i = 1; i <= length; i++) {
        final item = InventoryItemModel(
          productName: po.productName,
          costPerUnit: po.costPerUnit,
          marketPrice: product?[MARKET_RATE],
          currentSellingPrice: product?[PRICE],
          productId: po.productID,
          isSold: false,
          serialNumber: 'not defined',
        );
        String sr = SRGenerator.generateSR(po.productID, po.id!, i);
        // Create a new copy of the item with unique serial number
        InventoryItemModel newItem = item.copyWith(serialNumber: sr);
        poItems.add(newItem);
      }
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
  int? productID;
  int? supplierID;
  final selectedDate = Rxn<DateTime>();
  RxString supplierName = "".obs;

  /// loading var
  RxBool isLoading = false.obs;

  /// add to database
  Future<void> addOREditPO({int? poID, int isReceived = 0}) async {
    try {
      if (productID == null) return;
      if (supplierID != null) {
        isLoading.value = true;
        if (poID == null) {
          if (productID == null) return;

          totalQuantity.value = int.parse(
            itemQuantityController.text.toString(),
          );
          totalCost.value =
              double.parse(itemCostPriceController.text.toString()) *
              totalQuantity.value;

          final po = PurchaseOrderModel(
            supplierId: supplierID!,
            isReceived: isReceived,
            productID: productID!,
            costPerUnit: double.parse(itemCostPriceController.text.toString()),
            orderDate: selectedDate.value ?? DateTime.now(),
            totalQty: totalQuantity.value,

            totalCost: totalCost.value,
            isPartiallyReceived: 0,
          );
          final result = await DatabaseHelper.instance.insertPO(po);
          if (result != 0) {
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
            productID: productID!,
            costPerUnit: double.parse(itemCostPriceController.text.toString()),
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

  /// Save to db and increase product quantity in products
  Future<void> saveToDB({required PurchaseOrderModel po}) async {
    try {
      isLoading.value = true;
      final db = DatabaseHelper.instance;
      int batch = await db.getProductLastBatch(productID: po.productID);
      if (batch <= 0) {
        return;
      }
      final inventory = InventoryModel(
        costPerUnit: po.costPerUnit,
        productBatch: batch + 1,
        isReadyForSale: true,
        remaining: po.totalQty,
        productId: po.productID,
        purchaseOrderID: po.id,
        purchaseDate: po.orderDate,
      );
      final result = await db.insertInventory(inventory);
      InventoryItemModel? invItem;
      if (result != 0) {
        final invController = Get.find<InventoryController>();
        bool hasError = false;
        for (var item in poItems) {
          item.inventoryID = result;
          invItem = item;
          final itemResult = await db.insertInventoryItem(item);
          if (!(itemResult != 0)) {
            hasError = true;
            break;
          }
        }
        if (!hasError) {
          po.isReceived = 1;
          po.isPartiallyReceived = 0;
          final isPoUpdate = await db.updatePO(po);
          pagingController.refresh();
          if (isPoUpdate != 0) {
            isLoading.value = false;
            poItems.clear();

            if (invItem != null) {
              invController.reset();
              inventory.id = result;
              inventory.productName = invItem.productName;
              inventory.currentSellingPrice = invItem.currentSellingPrice;
              inventory.marketPrice = invItem.marketPrice;

              Get.off(() => CalculatePrice(inv: inventory));
              Get.closeAllSnackbars();
              AppSnackbars.success('Success!', "Order received successfully!");
              final confirmController = Get.put(ConfirmPriceController());
              invController.setData(inventory: inventory);
              confirmController.startDelayedConfirm(
                delay: const Duration(seconds: 3),
                onAccept: () {
                  Get.closeAllSnackbars();
                  AppSnackbars.success('Success', 'price accepted by user.');
                },
                onCancel: () {
                  Get.closeAllSnackbars();
                  AppSnackbars.error('Canceled', 'price is canceled by user.');
                  invController.priceController.clear();
                  invController.newSellingPrice.value = null;
                  invController.profitMargin.value = 0.0;
                },
              );
            }
          } else {
            isLoading.value = false;
            DialogUtils.showFullScreenDialog(
              title: 'Error!',
              message: "Failed to receive order. Please try again.",
            );
          }
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

  clearControllers() {
    supplierID = null;
    supplierName.value = "";
    selectedDate.value = DateTime.now();
    supplierNameController.clear();
    productID == null;
    itemNameController.clear();
    itemCostPriceController.clear();
    itemQuantityController.clear();
  }
}
