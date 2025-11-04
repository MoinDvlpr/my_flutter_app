import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_textstyles.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  // Static data for inventory products
  late List<Map<String, dynamic>> products;

  @override
  void initState() {
    super.initState();
    products = [
      {
        'productName': 'Laptop Pro 15',
        'batchId': 'BATCH-001',
        'quantity': 25,
        'costPrice': 45000.00,
        'marketPrice': 65000.00,
        'currentSellingRate': 62000.00,
      },
      {
        'productName': 'Wireless Mouse',
        'batchId': 'BATCH-002',
        'quantity': 150,
        'costPrice': 500.00,
        'marketPrice': 1200.00,
        'currentSellingRate': 1100.00,
      },
      {
        'productName': 'USB-C Cable',
        'batchId': 'BATCH-003',
        'quantity': 300,
        'costPrice': 150.00,
        'marketPrice': 400.00,
        'currentSellingRate': 350.00,
      },
      {
        'productName': 'Mechanical Keyboard',
        'batchId': 'BATCH-004',
        'quantity': 45,
        'costPrice': 3500.00,
        'marketPrice': 7500.00,
        'currentSellingRate': 7000.00,
      },
      {
        'productName': 'Monitor 27"',
        'batchId': 'BATCH-005',
        'quantity': 18,
        'costPrice': 12000.00,
        'marketPrice': 18000.00,
        'currentSellingRate': 17500.00,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Inventory"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // List of Products Batch Wise
          Expanded(
            child: products.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 48, color: grey),
                  const SizedBox(height: 10),
                  Text(
                    "No products in inventory",
                    style:
                    AppTextStyle.lableStyle.copyWith(fontSize: 18),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductBatchCard(
                  context,
                  productName: product['productName'],
                  batchId: product['batchId'],
                  quantity: product['quantity'],
                  costPrice: product['costPrice'],
                  marketPrice: product['marketPrice'],
                  currentSellingRate: product['currentSellingRate'],
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductBatchCard(
      BuildContext context, {
        required String productName,
        required String batchId,
        required int quantity,
        required double costPrice,
        required double marketPrice,
        required double currentSellingRate,
        required int index,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header: Product Name with Batch ID and Quantity
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  radius: 18,
                  child: const Icon(
                    Icons.inventory_2,
                    color: primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Batch ID: $batchId",
                        style: AppTextStyle.lableStyle.copyWith(
                          fontSize: 13,
                          color: grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Qty: $quantity",
                    style: AppTextStyle.semiBoldTextstyle.copyWith(
                      fontSize: 14,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Second Row: Cost and Market Headings
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Cost",
                    style: AppTextStyle.lableStyle.copyWith(
                      fontSize: 13,
                      color: grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Market",
                    style: AppTextStyle.lableStyle.copyWith(
                      fontSize: 13,
                      color: grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Third Row: Cost Price and Market Price Values
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      "₹${costPrice.toStringAsFixed(2)}",
                      style: AppTextStyle.semiBoldTextstyle.copyWith(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      "₹${marketPrice.toStringAsFixed(2)}",
                      style: AppTextStyle.semiBoldTextstyle.copyWith(
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Fourth Row: Current Selling Rate (Highlighted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Selling Rate",
                        style: AppTextStyle.lableStyle.copyWith(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${currentSellingRate.toStringAsFixed(2)}",
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          fontSize: 16,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      showModifySellingRateDialog(productName,batchId,costPrice,currentSellingRate.toInt());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Modify",
                        style: AppTextStyle.semiBoldTextstyle.copyWith(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  void showModifySellingRateDialog(
      String productName,
      String batchId,
      double currentRate,
      int index,
      // RxList<Map<String, dynamic>> products, // Assuming products is reactive
      ) {
    final textController = TextEditingController(
      text: currentRate.toStringAsFixed(2),
    );

    Get.defaultDialog(
      title: "Modify Selling Rate",
      titleStyle: AppTextStyle.lableStyle.copyWith(fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$productName (Batch: $batchId)",
            style: AppTextStyle.lableStyle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: textController,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "New Selling Rate",
              prefixText: "₹ ",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: AppTextStyle.lableStyle,
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          final newRate = double.tryParse(textController.text) ?? 0.0;

          // Update the product rate
          products[index]['currentSellingRate'] = newRate;
          // products.refresh(); // refresh the UI

          Get.back(); // close dialog
          Get.snackbar(
            "Success",
            "Selling rate updated to ₹${newRate.toStringAsFixed(2)}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.2),
            colorText: Colors.black,
            duration: const Duration(seconds: 2),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
        ),
        child: const Text(
          "Update",
          style: TextStyle(color: Colors.white),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel"),
      ),
    );
  }
}