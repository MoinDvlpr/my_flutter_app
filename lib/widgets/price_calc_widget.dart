import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/purchase_order_controller.dart';

class PricingCalculatorWidget extends StatelessWidget {
  final PurchaseOrderController controller;

  final int index;

  PricingCalculatorWidget({
    Key? key,
    required this.controller,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing Calculator',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),

          // Cost Price Field
          TextField(
            controller: controller.costPriceController[index],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Cost Price (₹)',
              hintText: 'Enter cost per unit',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.money),
            ),
          ),
          const SizedBox(height: 12),

          // Market Price Field
          TextField(
            controller: controller.marketPriceController[index],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Market Price (₹)',
              hintText: 'Enter market price',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.store),
            ),
          ),
          const SizedBox(height: 12),

          // Discount Group Selector
          Obx(
                () => DropdownButtonFormField<int>(
              initialValue: controller.selectedDiscountGroup[index],
              decoration: InputDecoration(
                labelText: 'Discount Group',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.discount),
              ),
              items: controller.discountGroups.map((discount) {
                return DropdownMenuItem(
                  value: discount,
                  child: Text('$discount% Discount'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedDiscountGroup[index] = value;
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // Selling Price Field (Auto-filled)
          TextField(
            controller: controller.sellingPriceController[index],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Selling Price (₹)',
              hintText: 'Calculated automatically',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.currency_rupee),
              filled: true,
              fillColor: Colors.green.shade50,
            ),
          ),
          const SizedBox(height: 16),
          // Calculate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.calculateSellingPrice(
                autoFill: false,
                index: index,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA64D),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Calculate Selling Price',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
