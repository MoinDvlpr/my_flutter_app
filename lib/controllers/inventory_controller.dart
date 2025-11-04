import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryController extends GetxController with GetTickerProviderStateMixin {
  // Product data (you can later set dynamically)
  final productName = "".obs;
  final batchId = "".obs;
  final costPrice = 0.00.obs;
  final marketPrice = 0.00.obs;
  final currentSellingPrice = 0.00.obs;

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
    fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);

    priceController.addListener(_calculatePrice);
  }

  void _calculatePrice() {
    final input = priceController.text.trim();
    if (input.isEmpty) {
      showPriceStatus.value = false;
      return;
    }

    final price = double.tryParse(input);
    if (price == null || price < 0) {
      Get.snackbar("Invalid Input", "Please enter a valid price",
          backgroundColor: Colors.red.withOpacity(0.2));
      return;
    }

    newSellingPrice.value = price;
    profitAmount.value = price - costPrice.value;
    profitPercent.value = (profitAmount.value! / costPrice.value) * 100;

    // Determine status
    if (price < costPrice.value) {
      statusMessage.value = "Loss! Price below cost.";
      statusColor.value = Colors.red;
      statusIcon.value = Icons.trending_down;
    } else if (profitPercent.value! < 5) {
      statusMessage.value = "Very low margin, consider increasing.";
      statusColor.value = Colors.orange;
      statusIcon.value = Icons.warning;
    } else if (profitPercent.value! <= 20) {
      statusMessage.value = "Balanced and competitive.";
      statusColor.value = Colors.green;
      statusIcon.value = Icons.check_circle;
    }

    else {
      statusMessage.value = "Above market price, might affect sales.";
      statusColor.value = Colors.blue;
      statusIcon.value = Icons.info;
    }

    showPriceStatus.value = true;
    if (!animationController.isAnimating) {
      animationController.forward(from: 0.0);
    }
  }

  void updatePrice() {
    if (newSellingPrice.value == null) {
      Get.snackbar("Error", "Please enter a valid price first",
          backgroundColor: Colors.red.withOpacity(0.2));
      return;
    }

    Get.snackbar(
      "Success",
      "Selling price updated to ₹${newSellingPrice.value!.toStringAsFixed(2)}",
      backgroundColor: Colors.green.withOpacity(0.2),
      snackPosition: SnackPosition.BOTTOM,
    );

    // Reset after update
    Future.delayed(const Duration(milliseconds: 500), () {
      priceController.clear();
      newSellingPrice.value = null;
      showPriceStatus.value = false;
      animationController.reverse();
    });
  }

  @override
  void onClose() {
    priceController.dispose();
    animationController.dispose();
    super.onClose();
  }
}
